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
// MARK: - 오늘의 추천 술 데이터
struct TodayDrink: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let image: String
}

let TodayDrinkData: [TodayDrink] = [
    TodayDrink(title: "지평 막걸리", image:"jipyeong"),
    TodayDrink(title: "루나가이아 지비뽀", image:"jibibbo"),
    TodayDrink(title: "진로", image:"jinro"),
]

// MARK: - 오늘의 추천 술 이미지 + 이름

struct TodayDrinkRecommended: View {
    @Binding var isLoggedIn: Bool
    let todayDrink: [TodayDrink] = TodayDrinkData
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 20) {
                    if isLoggedIn {
                        // TODO: NavigationLink - value 로 수정
                        NavigationLink {
                            DrinkDetailView(drink: Wine.wineSample01) // 임시 더미데이터
                                .modifier(TabBarHidden())
                        } label: {
                            //                            TodayDrinkRecommendedCell(todayDrink: drink)
                            TestRecommend(isLoggedIn: $isLoggedIn)
                        }
                    } else {
                        TestRecommend(isLoggedIn: $isLoggedIn)
                    }
            }
        }
    }
}

#Preview {
    TodayDrinkRecommended(isLoggedIn: .constant(true))
}

// MARK: - 오늘의 추천 술 셀
struct TodayDrinkRecommendedCell: View {
    let todayDrink: TodayDrink
    
    var body: some View {
        VStack {
            // 이미지
            Image(todayDrink.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70, height: 103.48)
                .padding(.bottom, 10)
            // 술 이름
            Text(todayDrink.title)
                .font(.regular12)
                .foregroundStyle(.mainBlack)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(.top, 20)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    TodayDrinkRecommendedCell(todayDrink: TodayDrink(title: "지평 막걸리", image:"jipyeong"))
}


struct FirebaseDrink: Codable, Hashable {
    //    let category: String
    //    let type: String
    let name: String
    //    let amount: String
    //    let price: Int
    //    let alcohol: Double
    //    let country: String
    //    let province: String? // wine
    //    let aroma: [String]? // wine, beer, whishkey
    //    let taste: [String]? // wine, beer, whishkey
    //    let finish: [String]? // wine, beer, whishkey
    //    let sweet: Int? // traditional
    //    let sour: Int? // traditional
    //    let refresh: Int? // traditional
    //    let body: Int? // traditional
    //    let carbonated: Int? // traditional
    //    let wellMatched: [String]
    //    let rating: Double
    //    let countTagged: Int
    //    let agePreference: [Int: Int]
    //    let genderPreference: [String: Int]
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
             let drinksSnapshot = try await db.collection("testBeer").getDocuments() // Firebase의 collection 이름으로 수정
             
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

struct TestRecommend: View {
    @ObservedObject var recommend = Recommend.shared
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var aiViewModel: AiTodayViewModel
    @State private var weather: Weather?
    @Binding var isLoggedIn: Bool
    @State private var lastAPICallTimestamp: Date?
    @State private var isLoading = false
    var body: some View {
        VStack {
            HStack {
                Text("\(aiViewModel.respondToday)")
            }
        }
        .onAppear {
            Task {
                do {
                    await recommend.fetchDrinks()
                    guard let location = locationManager.location
                    else {
                        return
                    }
                    
                    // Fetch weather data
                    let weatherData = try await fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    weather = weatherData
                    
                    // Request AI recommendation
                    aiViewModel.respondToday = try await aiViewModel.requestToday(prompt: "Please recommend three drinks that go well with this weather. Please refer to the below list behind you .\(String(describing: weather?.main))  \(recommend.recommend)")
                    lastAPICallTimestamp = Date()
                    
                    print("\(aiViewModel.respondToday)")
                } catch {
                    print("Error: \(error)")
                }
            }
        }


            }
            
    
    
    // fetch타임 설정 TimeInterval 300 == 5분으로 설정
    private func shouldFetchWeather() -> Bool {
        guard let lastTimestamp = lastAPICallTimestamp else {
            return true
        }
        
        let currentTime = Date()
        let timeDifference = currentTime.timeIntervalSince(lastTimestamp)
        let minimumTimeDifference: TimeInterval = 300
        
        return timeDifference >= minimumTimeDifference
    }
    
    private func loadWeatherData() async {
        guard let location = locationManager.location else { return }
        do {
            self.weather = try await fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        } catch {
            print("Error: \(error)")
        }
    }
    private func getKoreanWeatherDescription(for weather: String) -> String {
        switch weather {
        case "Clouds":
            return "오늘은 흐림.."
        case "Clear":
            return "오늘은 굉장히 맑아요!"
        case "Rain":
            return "오늘은 비가 오네요.."
        case "Snow":
            return "와우~눈이 와요!"
        case "Thunderstorm":
            return "천둥 조심하세요!"
        default:
            return "알 수 없음"
        }
    }
    
    //날씨에 따른 애니메이션 케이스
    private func getAnimationName(for weather: String) -> String {
        switch weather {
        case "Clouds":
            return "Clouds"
        case "Clear":
            return "Sun"
        case "Rain":
            return "Rain"
        case "Snow":
            return "Snow"
        case "Thunderstorm":
            return "Thunder"
        default:
            return "Sun"
        }
    }
    
    private func fetchWeather(latitude: Double, longitude: Double) async throws -> Weather {
        return try await withCheckedThrowingContinuation { continuation in
            WeatherAPI.shared.getWeather(latitude: latitude, longitude: longitude) { weather in
                if let weather = weather {
                    continuation.resume(returning: weather)
                    print("getWeather call2")
                } else {
                    continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: nil))
                }
            }
        }
    }
    
}

// 날씨 정보 fetch



#Preview {
    TestRecommend(isLoggedIn: .constant(true))
}



//

