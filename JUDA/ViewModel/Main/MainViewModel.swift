//
//  MainViewModel.swift
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
final class MainViewModel: ObservableObject {
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
    // Weather Service
    private let weatherService = WeatherService()
    // openAI Service
    private let aiService = AIService()
    // Firebase Post Service
    private let firestorePostService = FirestorePostService()
    // Firebase Drink Service
    private let firestoreDrinkService = FirestoreDrinkService()
}

// MARK: - Fetch
extension MainViewModel {
    // 인기 있는 drink 가져오기
    func getHottestDrinks() async {
        do {
            let hottestDrinksRef = firestore.collection(drinkCollection)
                .order(by: "rating", descending: true).limit(to: 3)
            // Drink 가져오는 함수 사용 - FirestoreDrinkService
            let hottestDrinks = try await firestoreDrinkService.fetchDrinkCollection(collection: hottestDrinksRef as! CollectionReference)
            drinks = hottestDrinks
        } catch {
            print("error :: getHottestDrinks", error.localizedDescription)
        }
    }
    
    // 인기 있는 post 가져오기
    func getHottestPosts() async {
        do {
            let hottestPostsRef = firestore.collection(postCollection)
                .order(by: "likedCount", descending: true).limit(to: 3)
            //  Post 가져오는 함수 사용 - FirestorePostService
            let hottestPosts = try await firestorePostService.fetchPostCollection(collection: hottestPostsRef as! CollectionReference)
            posts = hottestPosts
        } catch {
            print("error :: getHottestPosts", error.localizedDescription)
        }
    }
    
    // 날씨 & 음식 + 술 받아오기
    func getWeatherAndAIResponse(location: CLLocation) async {
        do {
            guard let lastTimestamp = lastAPICallTimestamp else { return }
            // Fetch weather data
            let weatherData = try await weatherService.fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, lastTimestamp: lastTimestamp)
            weather = weatherData
            // Request
            AIRespond = try await aiService.request(weatherString: String(describing: weather?.main))
            lastAPICallTimestamp = Date()
        } catch {
            print("error :: getWeatherAndAIResponse", error.localizedDescription)
        }
    }
}
