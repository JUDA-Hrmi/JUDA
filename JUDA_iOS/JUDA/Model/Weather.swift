//
//  Weather.swift
//  JUDA
//
//  Created by phang on 3/7/24.
//

import Foundation

// MARK: - 날씨 api 받아오는 모델
struct WeatherData: Decodable {
    let weather: [Weather]
    let name: String
}

// MARK: - 날씨 api 받아오는 모델
struct Weather: Decodable {
    let main: String
    let description: String
}
