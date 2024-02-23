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


struct TodayDrink: Identifiable, Hashable {
    let id = UUID()
    let image: String
    var words: [String]
}

var TodayDrinkData: [TodayDrink] = [
    TodayDrink(image:"jipyeong", words: []),
    TodayDrink(image:"jibibbo", words: []),
    TodayDrink(image:"jinro", words: [])
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
                            TodayDrinkRecommendedCell(isLoading: $isLoading, drink: drink)
                        }
                    } else {
                        TodayDrinkRecommendedCell(isLoading: $isLoading, drink: drink)
                    }
                }
            }
            .onAppear {
                Task {
                    if fetchTimeInterval() && authService.signInStatus {
                        do {
                            isLoading = true
                            await recommend.fetchDrinks()
                            // Request AI recommendation
                            let response = try await aiViewModel.requestToday(prompt: "Please recommend three drinks and category that go well with this weather. Please refer to the below list behind you . --weather: \(String(describing: weather?.main)) --drinks: \(recommend.recommend)")
                            print("\(recommend.recommend)")
                            // 텍스트 분할
                            let words = response.split(separator: ", ").map { String($0) }
                            let categories = words.map { $0.split(separator: "/").map { String($0) } }
                            let categoryValues = categories.map { $0[1] }
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
        //    let todayDrink: TodayDrink
        @ObservedObject var recommend = Recommend.shared
        @EnvironmentObject var locationManager: LocationManager
        @EnvironmentObject var aiViewModel: AiTodayViewModel
        @State private var weather: Weather?
        @EnvironmentObject private var authService: AuthService
        @State private var lastAPICallTimestamp: Date?
        @Binding var isLoading: Bool
        @State private var drinkImage: UIImage?
        let drink: TodayDrink
        
        var body: some View {
            VStack {
                if isLoading {
                    // TODO: - 나중에 창준햄 CircularLoaderView 사용하기
                    ProgressView()
                } else {
                    // 이미지
                    Image("jinro")
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
    }
    
    struct FirebaseDrink: Codable, Hashable {
        let name: String
        let category: String
        
        init(name: String, category: String) {
            self.name = name
            self.category = category
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
        func fetchDrinks() async {
            do {
                let drinksSnapshot = try await db.collection("drinks").getDocuments() // Firebase의 collection 이름으로 수정
                
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

enum DrinkTypes: String {
    case all = "전체"
    case traditional = "우리술"
    case beer = "맥주"
    case wine = "와인"
    case whiskey = "위스키"
}
private func getImageName(category: DrinkTypes, detailedCategory: String) -> String? {
    switch category {
        // 맥주
    case .beer:
        switch detailedCategory {
        case "흑맥주":
            return "darkBeer.png"
        case "논알콜":
            return "nonAlcoholBeer.png"
        case "과일", "기타":
            return nil
        default: // 나머지 모든 맥주
            return "beer_bottled.png"
        }
        // 우리술
    case .traditional:
        switch detailedCategory {
        case "탁주":
            return "makgeolli.png"
        case "증류주":
            return "distilledAlcohol.png"
        case "약주 청주":
            return "yakju_cheongju.png"
        default: // 기타주류, 과실주
            return nil // TODO: - 수정 필요.
        }
        // 위스키
    case .whiskey:
        return "whiskey.png"
        // 와인
    case .wine:
        switch detailedCategory {
        case "주정강화":
            return "fortifiedWine.png"
        case "로제":
            return "roseWine.png"
        case "스파클링":
            return "sparklingWine.png"
        case "화이트":
            return "whiteWine.png"
        case "레드":
            return "redWine.png"
        default: // 예외
            return nil
        }
    default:
        return nil
    }
}








// MARK: - 사진 뿌리기 방법
//1
//음료 이름 보내 -> 받아옴 -> 뿌려
//음료 이름 보내 -> 받아옴 -> (카테고리,이름) 파베에 있는거랑 비교 if == -> 출력
//아니다 -> 다시 받아옴


//2
