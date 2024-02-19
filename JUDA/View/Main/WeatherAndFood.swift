//
//  WeatherAndFood.swift
//  FinalHrmiProjects
//
//  Created by 백대홍 on 1/31/24.
//

import SwiftUI

// MARK: - 날씨 & 술 + 음식 추천 뷰
struct WeatherAndFood: View {
    @Binding var isLoggedIn: Bool
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
        "하이네켄","버드와이저","기네스","코로나","스텔라","인디아 페일 에일","필스너 우르켈","삿포로","시메","블루 문","시에라 네바다","새뮤얼 아담스","벡스","모델로","아사히","칭따오","페로니","미켈로브 울트라","헤가든","밀러 라이트",
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            VStack {
                // 날씨 애니메이션 뷰
                if let weather = weather {
                    LottieView(jsonName: getAnimationName(for: weather.main))
                        .aspectRatio(1.0, contentMode: .fit)
                        .frame(width: 200, height: 200)
                    if isLoggedIn {
                        Text(getKoreanWeatherDescription(for: weather.main))
                    } else {
                        Text("오늘의 날씨와 어울리는")
                    }
                } else {
                    LottieView(jsonName: "Sun")
                        .frame(width: 200, height: 200)
                        .aspectRatio(1.0, contentMode: .fit)
                }
            }
            .onReceive(locationManager.$location) { location in
                          if shouldFetchWeather() && isLoggedIn {
                              if let location = location {
                                  isLoading = true
                                  Task {
                                      do {
                                          // Fetch weather data
                                          let weatherData = try await fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                                          weather = weatherData
                                          // Request
                                          aiViewModel.respond = try await aiViewModel.request(prompt: "Please recommend snacks and drinks that go well with this weather. Please refer to the below list behind you for the sake of snacks. Please recommend one each for snacks and drinks. When printing snacks and drinks \(String(describing: weather?.main)) ---dish List: \(koreanSnacks) ---drink List:\(beerNames)")
                                          lastAPICallTimestamp = Date()
                                      } catch {
                                          print("Error: \(error)")
                                      }
                                      isLoading = false
                                  }
                              }
                          }
                      }

            VStack(alignment:.center) {
                if isLoading {
                    ProgressView()
                } else {
                    if isLoggedIn {
                        HStack {
                            Text(aiViewModel.respond)
                                .foregroundStyle(.mainAccent03)
                            Text("한 잔 어때요?")
                        }
                    } else {
                        HStack(spacing: 6) {
                            Text("안주")
                                .foregroundStyle(.mainAccent03)
                            Text("와")
                            Text("술")
                                .foregroundStyle(.mainAccent03)
                            Text("조합을 확인하세요.")
                        }
                    }
                }
            }
        }
        .font(isLoggedIn ? .bold22 : .bold20)
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



    

