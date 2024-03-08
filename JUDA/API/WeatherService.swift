//
//  WeatherService.swift
//  FinalHrmiProjects
//
//  Created by 백대홍 on 2/7/24.
//

import SwiftUI
import CoreLocation

// MARK: - Weather Service
@MainActor
final class WeatherService {
    // 날씨
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    private let apiKey = Bundle.main.apiKey  // OpenWeatherMap에서 발급받은 API

    // 날씨 정보 fetch
    func fetchWeather(latitude: Double, longitude: Double, lastTimestamp: Date) async throws -> Weather {
        guard shouldFetchWeather(lastTimestamp: lastTimestamp) else { 
            throw WeatherFetchError.shouldFetch
        }
        let weather = await getWeather(latitude: latitude, longitude: longitude)
        if let weather = weather {
            print("getWeather call")
            return weather
        } else {
            print("Weather data could not be fetched.")
            throw WeatherFetchError.fetchWeather
        }
    }
    
    // 날씨 정보 케이스 -> 날씨 설명 텍스트에서 사용
    func getKoreanWeatherDescription(for weather: String) -> String {
        switch weather {
        case "Clouds":
            return "오늘은 흐림.."
        case "Clear":
            return "오늘은 굉장히 맑아요!"
        case "Rain":
            return "오늘은 비가 오네요.."
        case "Snow":
            return "와우~ 눈이 와요!"
        case "Thunderstorm":
            return "천둥 조심하세요!"
        default:
            return "알 수 없음"
        }
    }
    
    // 날씨에 따른 애니메이션 케이스
    func getAnimationName(for weather: String) -> String {
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
    
    // 날씨 받아오기
    private func getWeather(latitude: Double, longitude: Double) async -> Weather? {
        let weatherURL = "\(baseURL)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)"
        
        guard let url = URL(string: weatherURL) else {
            return nil
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            if let weatherData = try? decoder.decode(WeatherData.self, from: data) {
                return weatherData.weather.first
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    // fetch타임 설정 TimeInterval 300 == 5분으로 설정
    private func shouldFetchWeather(lastTimestamp: Date) -> Bool {
        let currentTime = Date()
        let timeDifference = currentTime.timeIntervalSince(lastTimestamp)
        let minimumTimeDifference: TimeInterval = 300
        return timeDifference >= minimumTimeDifference
    }
}


