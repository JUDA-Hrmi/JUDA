//
//  TodayDrinkRecommended.swift
//  JUDA
//
//  Created by 백대홍 on 1/31/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import OpenAI
import Kingfisher
import FirebaseStorage

@MainActor
final class TodayRecommendViewModel: ObservableObject {
    // 술 리스트
    
    // Drink 종류
    let typesOfDrink: [DrinkTypes] = [
        .all, .traditional, .wine, .whiskey, .beer
    ]
    // FireStore 기본 경로
    private let firestore = Firestore.firestore()
    private let drinkCollection = "drinks"
    
    // FireStorage 기본 경로
    private let storage = Storage.storage()
    private let drinkImagesPath = "drinkImages/"
    
}

struct TodayDrink: Identifiable, Hashable {
    let id = UUID()
    let image: String
    var words: [String]
}

var TodayDrinkData: [TodayDrink] = [
    TodayDrink(image:"", words: []),
    TodayDrink(image:"", words: []),
    TodayDrink(image:"", words: [])
]

// MARK: - 오늘의 추천 술 이미지 + 이름

struct TodayDrinkRecommended: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject var aiViewModel: AiTodayViewModel
    @ObservedObject var recommend = Recommend.shared
    @EnvironmentObject var locationManager: LocationManager
    @State private var weather: Weather?
    @State private var lastAPICallTimestamp: Date?
    @State private var isLoading = false
    @State var todayDrink: [TodayDrink] = TodayDrinkData
    @State private var categoryValues: String = ""
    @Binding var weatherAndFoodData: String
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 20) {
                ForEach(todayDrink, id: \.self) { drink in
                    if authService.signInStatus {
                        // TODO: NavigationLink - value 로 수정
                        NavigationLink {
                            DrinkDetailView(drink: Wine.wineSample01) // 임시 더미데이터
                                .modifier(TabBarHidden())
                        } label: {
                            TodayDrinkRecommendedCell(isLoading: $isLoading, drink: drink, categoryValues: $categoryValues)
                        }
                    } else {
                        TodayDrinkRecommendedCell(isLoading: $isLoading, drink: drink, categoryValues: $categoryValues)
                    }
                }
            }
            .onAppear {
                Task {
                    if fetchTimeInterval() && authService.signInStatus {
                        do {
                            isLoading = true
                            await recommend.fetchDrinks(weatherAndFoodData: weatherAndFoodData)
                        
                            // Request AI recommendation
                            let response = try await aiViewModel.requestToday(prompt: "Please recommend three drinks and category that go well with this weather. Please refer to the below list behind you . --drinks: \(recommend.recommend)")
                            print("\(response)")
                            // 텍스트 분할
                            let words = response.split(separator: ", ").map { String($0) }
                            print("카테고리: \(categoryValues)")
                            // 단어수 검사 3개가 아니면 에러처리
                            // TODO: - 에러처리 이후에 다시 API 호출 하도록 수정 필요
                            guard words.count == todayDrink.count else {
                                print("The number of words does not match the number of drinks.")
                                return
                            }
                            // 출력
                            for (index, word) in words.enumerated() {
                                todayDrink[index].words = [word]
                            }
                            
                            lastAPICallTimestamp = Date()
                            print("결과값: \(aiViewModel.respondToday)")
                        }
                        catch {
                            print("Error: \(error)")
                        }
                    }
                    isLoading = false
                }
            }
        }
        
    }
    
    // MARK: - 오늘의 추천 술 셀
    struct TodayDrinkRecommendedCell: View {
        @ObservedObject var recommend = Recommend.shared
        @EnvironmentObject var locationManager: LocationManager
        @EnvironmentObject var aiViewModel: AiTodayViewModel
        @State private var weather: Weather?
        @EnvironmentObject private var authService: AuthService
        @State private var lastAPICallTimestamp: Date?
        @Binding var isLoading: Bool
        @State private var drinkImage: UIImage?
        let drink: TodayDrink
        @Binding var categoryValues: String
        private let drinkImagesPath = "drinkImages/"
        @State private var imageURL: URL?
        var body: some View {
            VStack {
                if isLoading {
                    // TODO: - CircularLoaderView later
                    ProgressView()
                } else {
                    // Image
                    if let imageURL = imageURL {
                        KFImage(imageURL)
                            .placeholder {
                                ProgressView()
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 103.48)
                            .padding(.bottom, 10)
                        //술 이름
                        ForEach(drink.words, id: \.self) { word in
                            Text(word)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .onAppear {
                fetchImage()
            }
        }
        
        private func getImageURL(for category: DrinkTypes) -> URL? {
            guard let detailedCategory = drink.words.last else { return nil }
            guard let imageName = getImageName(category: category, detailedCategory: detailedCategory) else { return nil }
            print("URL:\(drinkImagesPath)\(imageName)")
            return URL(string: "\(drinkImagesPath)\(imageName)")
        }
        
        
        
        
        private func fetchImage() {
            // Get the URL for the image
            guard let imageURL = getImageURL(for:.traditional) else {
                print("Error: Image URL is nil")
                return
            }
            
            // Access Firebase Storage to download image
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let imageRef = storageRef.child(imageURL.path)
            
            // Download the image using the obtained URL
            imageRef.downloadURL { url, error in
                if let error = error {
                    // Handle when an error occurs while downloading the image
                    print("Error downloading image: \(error.localizedDescription)")
                } else if let url = url {
                    // Update imageURL when image download is successful
                    self.imageURL = url
                }
            }
        }
    }
        struct FirebaseDrink: Codable, Hashable {
            let name: String
            let category: String
            //        let type: String
            
            init(name: String, category: String/*, type: String*/) {
                self.name = name
                self.category = category
                //            self.type = type
            }
        }
        
        struct Ai2Model: Decodable {
            let openai: String
        }
        
        
        
        class Recommend: ObservableObject {
            var openAI: OpenAI?
            static let shared = Recommend()
            private init() {}
            @Published var recommend = [FirebaseDrink]()
            
            let db = Firestore.firestore()
            private var listener: ListenerRegistration?
            
            @MainActor
            func fetchDrinks(weatherAndFoodData:String) async {
                do {
                    let drinksSnapshot = try await db.collection("drinks").whereField("category", isEqualTo: weatherAndFoodData).getDocuments() // Firebase의 collection 이름으로 수정
                    print("파베1 \(weatherAndFoodData)")
                    
                    print("파베2\(drinksSnapshot)")
                    for drinkDocument in drinksSnapshot.documents {
                        if let drink = try? drinkDocument.data(as: FirebaseDrink.self) {
                            self.recommend.append(drink)
                        }
                    }
                } catch {
                    print("Error fetching drinks:", error)
                }
                print("fetchDrinks")
            }
            
            // 실시간 관찰 중지
            func stopListening() {
                listener?.remove()
                print("stopListening")
            }
        }
        private func fetchTimeInterval() -> Bool {
            guard let lastTimestamp = lastAPICallTimestamp else {
                return true
            }
            
            let currentTime = Date()
            let timeDifference = currentTime.timeIntervalSince(lastTimestamp)
            let minimumTimeDifference: TimeInterval = 300
            
            return timeDifference >= minimumTimeDifference
        }
        
        
    }
    
    enum DrinkTypes: String,CaseIterable {
        case all = "전체"
        case traditional = "우리술"
        case beer = "맥주"
        case wine = "와인"
        case whiskey = "위스키"
    }
    private func getImageName(category: DrinkTypes, detailedCategory: String) -> String? {
        switch category {
        case .all:
            return "distilledAlcohol.png"
        case .beer:
            return "darkBeer.png"
            //        switch detailedCategory {
            //        case "":
            //            return "darkBeer.png"
            //        case "논알콜":
            //            return "nonAlcoholBeer.png"
            //        case "과일", "기타":
            //            return nil
            //        default: // 나머지 모든 맥주
            //            return "beer_bottled.png"
            //        }
        case .traditional:
            return "distilledAlcohol.png"
            //        switch detailedCategory {
            //        case "탁주":
            //            return "distilledAlcohol.png"
            //        case "증류주":
            //            return "distilledAlcohol.png"
            //        case "약주 청주":
            //            return "yakju_cheongju.png"
            //        default: // 기타주류, 과실주
            //            return nil // TODO: - 수정 필요.
            //        }
        case .whiskey:
            return "whiskey.png"
        case .wine:
            return "distilledAlcohol.png"
            //        switch detailedCategory {
            //        case "주정강화":
            //            return "fortifiedWine.png"
            //        case "로제":
            //            return "roseWine.png"
            //        case "스파클링":
            //            return "sparklingWine.png"
            //        case "화이트":
            //            return "whiteWine.png"
            //        case "레드":
            //            return "redWine.png"
            //        default: // 예외
            //            return nil
            //        }
        default:
            return nil
        }
    }
    
