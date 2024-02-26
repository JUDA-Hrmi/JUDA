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
    let snacks = [
        "치즈 플래터", "혼합 견과류", "브루스케타", "카프레제 샐러드", "새우 칵테일", "스시", "안티파스토 플래터", "야채 봄롤", "시저 샐러드", "마르게리타 피자",
        "훔모스와 피타 브레드", "데블드 에그", "시금치 아티초크 딥", "치즈 퐁듀", "랍스터 비스크", "포도주", "굴",
        "프레첼", "팝콘", "칩과 살사", "에다마메", "치킨 윙", "치즈버거 슬라이더", "피쉬 타코", "과아몰레와 토르티야 칩", "오징어 요리", "양파 링",
        "소고기 슬라이더", "슈아꼬테리 플래터", "데블드 에그", "시금치 아티초크 딥", "나쵸", "로드된 포테이토 스킨",
        "파전", "김치", "닭강정", "튀김", "떡볶이", "순대", "오뎅", "잡채", "김밥", "빈대떡", "족발",
        "혼합 견과류", "초콜릿 트러플", "연어 훈제", "소고기 저키", "숙성된 치즈", "다크 초콜릿", "베이컨 감자", "구운 아몬드", "캐비어", "구운 스테이크",
        "과일과 치즈 플래터", "카라멜 팝콘",
        "바비큐", "잡채", "떡볶이", "튀김", "김치전", "파전", "오징어 구이", "김밥", "매운 돼지 불고기", "찐만두", "매운 치킨 윙", "후라이드 치킨", "닭갈비",
        "새우 칵테일", "브루스케타", "치즈 플래터", "스테이크 버섯", "미니 퀴시", "세비체", "조개", "크랩 케이크", "고추 새우", "코코넛 새우", "과일 꼬치",
    ]
    
    
    let beerNames = [
        "크로넨버그 1664 로제","말표 청포도 에일","막시모40","맥매니스, 캘리포니아 피노 누아","산토리","1000억유산균막걸리","글렌고인 25년","블루문","발베니 툰","스텔라","엘리자베스 로제 샤도네이","트리폴라 피에몬테 로쏘","맥캘란 10년","문경주조오미자생막걸리","구기홍주14","공주애오디와인","매실향기담은술","백하우스, 피노 누아","매실원주15","1000억걸리프리바이오","33J0","경복궁","내장산복분자주","아케시 로사토 브뤼","크로넨버그 1664 라거","크로넨버그 1664 블랑"
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
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    LottieView(jsonName: "Sun")
                        .frame(width: 180, height: 180)
                        .aspectRatio(1.0, contentMode: .fit)
                }
            }
            .frame(maxWidth: .infinity, alignment: authService.signInStatus ? .leading : .center)
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
                                aiViewModel.respond = try await aiViewModel.request(prompt: "Please recommend snacks and drinks that go well with this weather. Please refer to the below list behind you for the sake of snacks. Please recommend one each for snacks and drinks. When printing snacks and drinks \(String(describing: weather?.main)) ---dish List: \(snacks) ---drink List:\(beerNames)")
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
            VStack(alignment: authService.signInStatus ? .leading : .center) {
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
                        VStack(alignment: .center, spacing: 20) {
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
            .frame(maxWidth: .infinity, alignment: authService.signInStatus ? .leading : .center)
        }
        .font(authService.signInStatus ? .bold28 : .bold22)
        .padding(.horizontal, 20)
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
