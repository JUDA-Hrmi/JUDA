//
//  WeatherView.swift
//  FinalHrmiProjects
//
//  Created by 백대홍 on 1/31/24.
//

import SwiftUI

// MARK: - 날씨 + 메뉴 추천 뷰
struct WeatherView: View {
    @Binding var isLoggedIn: Bool
    let food: [String] = ["해물파전", "안주"]
    let sul: [String] = ["막걸리", "술"]
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var aiViewModel: AiViewModel
    @State private var isLoading: Bool = false
    @State private var weather: Weather?
    @State private var cityName: String?
    @State private var lastAPICallTimestamp: Date?
    let koreanSnacks = [
        "떡볶이",
        "김치전",
        "파전",
        "오뎅탕",
        "치킨",
        "닭꼬치",
        "곱창",
        "삼겹살",
        "피자",
        "만두",
        "라면",
        "떡",
        "호떡",
        "순대",
        "콘치즈",
        "감자튀김",
        "죽",
        "밥버거",
        "옥수수 떡볶이",
        "계란빵",
    ]
    
    let beerNames = [
        "하이네켄",
        "버드와이저",
        "기네스",
        "코로나",
        "스텔라",
        "인디아 페일 에일",
        "필스너 우르켈",
        "삿포로",
        "시메",
        "블루 문",
        "시에라 네바다",
        "새뮤얼 아담스",
        "벡스",
        "모델로",
        "아사히",
        "칭따오",
        "페로니",
        "미켈로브 울트라",
        "헤가든",
        "밀러 라이트",
    ]
    var body: some View {
        VStack {
            VStack {
                if let weather = weather {
                    LottieView(jsonName: getAnimationName(for: weather.main))
                        .frame(width: 200, height: 200)
                    Text(getKoreanWeatherDescription(for: weather.main))
                } else {
                    LottieView(jsonName: "Loading")
                }
            }
            .onReceive(locationManager.$location) { location in
                if shouldFetchWeather() { // Check if enough time has elapsed since the last API call
                    if let location = location {
                        isLoading = true // Set loading state before making API call
                        Task {
                            do {
                                // Fetch weather data
                                let weatherData = try await fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                                weather = weatherData
                                // Request AI recommendation
                                aiViewModel.respond = try await aiViewModel.request(prompt: "Please recommend snacks and drinks that go well with this weather. Please refer to the below list behind you for the sake of snacks. Please recommend one each for snacks and drinks. When printing snacks and drinks \(String(describing: weather?.main)) ---dish List: \(koreanSnacks) ---drink List:\(beerNames)")
                                lastAPICallTimestamp = Date() // Update the timestamp after a successful API call
                            } catch {
                                print("Error: \(error)")
                            }
                            isLoading = false // Reset loading state after API call completes
                        }
                    }
                }
            }
            Spacer().frame(height: 40)
            VStack(alignment:.leading) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("오늘의 추천 술")
                        .bold()
                        .font(.title2)
                    
                    HStack {
                        Text(aiViewModel.respond).foregroundStyle(.mainAccent03)
                        
                        Text("어때요?")
                    }
                }
            }
        }
    }
    
    private func shouldFetchWeather() -> Bool {
        guard let lastTimestamp = lastAPICallTimestamp else {
            return true // Fetch weather if no previous call timestamp exists
        }
        
        let currentTime = Date()
        let timeDifference = currentTime.timeIntervalSince(lastTimestamp)
        let minimumTimeDifference: TimeInterval = 300 // Minimum time difference in seconds (5 minutes)
        
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

       private func fetchWeather(latitude: Double, longitude: Double) async throws -> Weather {
           return try await withCheckedThrowingContinuation { continuation in
               WeatherAPI.shared.getWeather(latitude: latitude, longitude: longitude) { weather in
                   if let weather = weather {
                       continuation.resume(returning: weather)
                       print("getWeather call")
                   } else {
                       continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: nil))
                   }
               }
           }
       }

        private func getKoreanWeatherDescription(for weather: String) -> String { //날씨 정보 케이스 -> 날씨 설명 텍스트에서 사용
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
        
        private func getAnimationName(for weather: String) -> String {      //날씨에 따른 애니메이션 케이스
            switch weather {
            case "Clouds":
                return "Clouds"
            case "Clear":
                return "Snow"
            case "Rain":
                return "Rain"
            case "Snow":
                return "Sun"
//            case "Thunderstorm":
//                return "thunderstormAnimation"
            default:
                return "unknownWeatherAnimation"
            }
        }
    
}
//    var body: some View {
//        //        LottieView(jsonName: "Sun")
//        //            .frame(height: 200)
//        
//        VStack(alignment: .center, spacing: 10) {
//            Image("rain")
//                .resizable()
//				.aspectRatio(1.0, contentMode: .fill)
//                .frame(width: 200, height: 200)
//            
//            Text(isLoggedIn ? "오늘은 비가 와요." : "오늘의 날씨와 어울리는")
//                .multilineTextAlignment(.center)
//            
//            HStack(spacing: 3) {
//                Text(isLoggedIn ? food[0] : food[1])
//                    .foregroundColor(.mainAccent02)
//                Text(isLoggedIn ? " + " : "와 ")
//                    .font(.medium18)
//                Text(isLoggedIn ? sul[0] : sul[1])
//                    .foregroundColor(.mainAccent02)
//                Text(isLoggedIn ? "한 잔 어때요?" : "조합을 확인하세요.")
//                
//            }
//        }
//        .font(.medium18)
//    }
