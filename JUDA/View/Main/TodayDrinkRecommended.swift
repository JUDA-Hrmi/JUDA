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
                    do {
                        isLoading = true
                        if shouldFetchWeather() && authService.signInStatus {
                            await recommend.fetchDrinks()
                            // Request AI recommendation
                            let response = try await aiViewModel.requestToday(prompt: "Please recommend three drinks that go well with this weather. Please refer to the below list behind you . --weather: \(String(describing: weather?.main)) --drinks: \(recommend.recommend)")

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
                    } catch {
                        print("Error: \(error)")
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
        
        init(name: String) {
            self.name = name
        }
    }
    
    
    enum TestDrinkType: CaseIterable {
        case beer, traditionalLiquor, whiskey, wine
        
        var string: String {
            switch self {
            case .beer:
                return "Beer_food"
            case .traditionalLiquor:
                return "traditional_liqur_food"
            case .whiskey:
                return "test_whiskey"
            case .wine:
                return "test_wine"
            }
        }
    }
    struct Ai2Model: Decodable {
        let openai: String
    }
    
    
//    private func fetchWeather(latitude: Double, longitude: Double) async throws -> Weather {
//        let weather = await WeatherAPI.shared.getWeather(latitude: latitude, longitude: longitude)
//        if let weather = weather {
//            print("getWeather call22")
//            return weather
//        } else {
//            print("Weather data could not be fetched.")
//            throw NSError(domain: "WeatherErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Weather data could not be fetched."])
//        }
//    }
//
    
    
    
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
    private func shouldFetchWeather() -> Bool {
        guard let lastTimestamp = lastAPICallTimestamp else {
            return true
        }

        let currentTime = Date()
        let timeDifference = currentTime.timeIntervalSince(lastTimestamp)
        let minimumTimeDifference: TimeInterval = 300

        return timeDifference >= minimumTimeDifference
    }
}




 
