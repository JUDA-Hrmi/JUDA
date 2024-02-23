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
                            let response = try await aiViewModel.requestToday(prompt: "Please recommend three drinks that go well with this weather. Please refer to the below list behind you . --weather: \(String(describing: weather?.main)) --drinks: \(recommend.recommend)")
                            print("\(recommend.recommend)")
                            // 텍스트 분할
                            let words = response.split(separator: ", ").map { String($0) }
                            
                            // 단어수 검사 3개가 아니면 에러처리
                            // TODO: - 에러처리 이후에 다시 API 호출 하도록 수정 필요
                            guard words.count == todayDrink.count else {
                                print("The number of words does not match the number of drinks.")
                                return
                            }
                            // 출력
                            for (index, word) in words.enumerated() {
                                todayDrink[index].words = [word]
                                lastAPICallTimestamp = Date()
                            }
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





// MARK: - 사진 뿌리기 방법
//1
//음료 이름 보내 -> 받아옴 -> 뿌려
//음료 이름 보내 -> 받아옴 -> (카테고리,이름) 파베에 있는거랑 비교 if == -> 출력
//아니다 -> 다시 받아옴


//2
