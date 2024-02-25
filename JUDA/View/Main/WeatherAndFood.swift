//
//  WeatherAndFood.swift
//  FinalHrmiProjects
//
//  Created by 백대홍 on 1/31/24.
//

import SwiftUI

// MARK: - 날씨 & 술 + 음식 추천 뷰
struct WeatherAndFood: View {
    @EnvironmentObject private var authService: AuthService
    @State var weatherAndFoodData: String = ""
    let food: [String] = ["해물파전", "안주"]
    let drink: [String] = ["막걸리", "술"]
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var aiViewModel: AiViewModel
    @State private var isLoading: Bool = false
    @State private var weather: Weather?
    @State private var cityName: String?
    @State private var lastAPICallTimestamp: Date?
    
    // MARK: - 테스트 데이터
    let koreanSnacks = [
        "떡볶이","김치전","파전","오뎅탕","치킨","닭꼬치","곱창","삼겹살","피자","만두","라면","떡","호떡","순대","콘치즈","감자튀김","죽","밥버거","옥수수 떡볶이","계란빵",
    ]
    
    let beerNames = [
        "우리술", "맥주", "와인", "위스키"
    ]
    
    var body: some View {
        VStack(alignment: authService.signInStatus ? .leading : .center, spacing: 10) {
            VStack(alignment: authService.signInStatus ? .leading : .center) {
                // 날씨 애니메이션 뷰
                if let weather = weather {
                    LottieView(jsonName: getAnimationName(for: weather.main))
                        .aspectRatio(1.0, contentMode: .fit)
                        .frame(width: 180, height: 180)
                    if authService.signInStatus {
                        Text(getKoreanWeatherDescription(for: weather.main))
                            .font(.semibold18)
                            .frame(maxWidth: .infinity,
                                   alignment: authService.signInStatus ? .leading : .center)
                    } else {
                        Text("오늘의 날씨와 어울리는")
                            .font(.semibold18)
                            .frame(maxWidth: .infinity,
                                   alignment: authService.signInStatus ? .leading : .center)
                    }
                } else {
                    LottieView(jsonName: "Sun")
                        .frame(width: 180, height: 180)
                        .aspectRatio(1.0, contentMode: .fit)
                }
            }
            .onChange(of: locationManager.location) { location in
                if shouldFetchWeather() && authService.signInStatus {
                    if let location = location {
                        isLoading = true
                        Task {
                            do {
                                // Fetch weather data
                                let weatherData = try await fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                                weather = weatherData
                                // Request
                                aiViewModel.respond = try await aiViewModel.request(prompt: "Please recommend snacks and drinks that go well with this weather. Please refer to the below list behind you for the sake of snacks. Please recommend one each for snacks and drinks. When printing snacks and drinks \(String(describing: weather?.main)) ---dish List: \(koreanSnacks) ---drink List:\(beerNames)")
//                                print("\(aiViewModel.respond)")
//                                let drinkword = aiViewModel.respond.split(separator: " + ").map({String($0)})
//                                weatherAndFoodData = drinkword[1]
//                                print("\(weatherAndFoodData)")
                                
                                lastAPICallTimestamp = Date()
                            } catch {
                                print("Error: \(error)")
                            }
                            isLoading = false
                        }
                    }
                }
            }
            VStack(alignment: .leading) {
                if isLoading {
                    ProgressView()
                } else {
                    if authService.signInStatus {
                        VStack(alignment: .leading) {
                            Text(aiViewModel.respond)
                                .foregroundStyle(.mainAccent03)
                            Text("한 잔 어때요?")
                        }
                    } else {
                        VStack(alignment: .center, spacing: 10) {
                            VStack {
                                Text("오늘의 날씨에 맞는")
                                HStack {
                                    Text("술과 안주")
                                        .foregroundStyle(.mainAccent03)
                                    Text("를 추천 받고 싶다면?")
                                }
                            }
                            .font(.medium18)
                            // TODO: NavigationLink - value 로 수정
                            NavigationLink {
                                LogInView()
                                    .modifier(TabBarHidden())
                            } label: {
                                HStack(alignment: .center) {
                                    Text("로그인 하러가기")
                                        .font(.semibold16)
                                        .foregroundStyle(.mainAccent03)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(.mainAccent03.opacity(0.2))
                                .clipShape(.rect(cornerRadius: 10))
                            }
                        }
                    }
                }
            }
        }
        .font(authService.signInStatus ? .bold28 : .bold22)
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
    
    // 날씨 정보 fetch
    // TODO: - 노션 참고 변경 사항
    private func fetchWeather(latitude: Double, longitude: Double) async throws -> Weather {
        let weather = await WeatherAPI.shared.getWeather(latitude: latitude, longitude: longitude)
        if let weather = weather {
            print("getWeather call")
            return weather
        } else {
            print("Weather data could not be fetched.")
            throw NSError(domain: "WeatherErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Weather data could not be fetched."])
        }
    }
    
    //날씨 정보 케이스 -> 날씨 설명 텍스트에서 사용
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
}
