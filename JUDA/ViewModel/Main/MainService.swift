//
//  MainService.swift
//  JUDA
//
//  Created by phang on 3/7/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import CoreLocation

// MARK: - Main ( 인기 술, 술상 / 날씨, 음식 & 술 )
@MainActor
final class MainService: ObservableObject {
    // 인기 있는 drink 리스트
    @Published var drinks = [Drink]()
    // 인기 있는 post 리스트
    @Published var posts = [Post]()
    // 날씨 및 데이터 받아오기 로딩 중
    @Published var isLoading: Bool = false
    // 받아온 날씨
    @Published var weather: Weather?
    // 받아온 음식, 술 추천
    @Published var AIRespond: String = ""
    // 마지막 날씨 API call 시간
    @Published var lastAPICallTimestamp: Date?
    // FireStore 기본 경로
    private let firestore = Firestore.firestore()
    private let drinkCollection = "drinks"
    private let postCollection = "posts"
    // Weather View Model
    private let weatherViewModel = WeatherViewModel()
    // openAI View Model
    private let aiViewModel = AIViewModel()

    
    // 인기 있는 drink 가져오기
    func getHottestDrinks() async {
        let hottestDrinksRef = firestore.collection(drinkCollection)
            .order(by: "rating", descending: true).limit(to: 3)
        // TODO: - Drink 가져오는 함수 사용 예정
    }
    
    // 인기 있는 post 가져오기
    func getHottestPosts() async {
        let hottestPostsRef = firestore.collection(postCollection)
            .order(by: "likedCount", descending: true).limit(to: 3)
        // TODO: - Post 가져오는 함수 사용 예정
    }
    
    // 날씨 & 음식 + 술 받아오기
    func getWeatherAndAIResponse(location: CLLocation) async {
        do {
            guard let lastTimestamp = lastAPICallTimestamp else { return }
            // Fetch weather data
            let weatherData = try await weatherViewModel.fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, lastTimestamp: lastTimestamp)
            weather = weatherData
            // Request
            AIRespond = try await aiViewModel.request(weatherString: String(describing: weather?.main))
            lastAPICallTimestamp = Date()
        } catch {
            print("error :: getWeatherAndAIResponse", error.localizedDescription)
        }
    }
}
