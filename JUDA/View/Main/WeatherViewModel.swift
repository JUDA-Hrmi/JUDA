//
//  WeatherViewModel.swift
//  FinalHrmiProjects
//
//  Created by 백대홍 on 2/7/24.
//

import SwiftUI
import CoreLocation

struct WeatherData: Decodable {
    let weather: [Weather]
    let name: String
}

struct Weather: Decodable {
    let main: String
    let description: String
}

class WeatherAPI {
    static let shared = WeatherAPI()
    let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    let apiKey = Bundle.main.apiKey  // OpenWeatherMap에서 발급받은 API
    
    func getWeather(latitude: Double, longitude: Double) async -> Weather? {
        let weatherURL = "\(baseURL)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)"
        
        guard let url = URL(string: weatherURL) else {
            return nil
        }
        
        do {
            let(data, response) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            if let weatherData = try? decoder.decode(WeatherData.self, from: data) {
                return weatherData.weather.first
            } else {
                return nil
            }
        } catch {
            return nil
        }
        print("API Call")
    }
}

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    var location: CLLocation?
    
    override init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
}

extension Bundle {
    
    var apiKey: String {
        guard let filePath = Bundle.main.path(forResource: "APIKEYS", ofType: "plist"),
              let plistDict = NSDictionary(contentsOfFile: filePath) else {
            fatalError("Couldn't find file 'APIKEYS.plist'.")
        }
        guard let value = plistDict.object(forKey: "API_KEY") as? String else {
            fatalError("Couldn't find key 'API_Key' in 'APIKEYS.plist'.")
        }
        
        return value
    }
}
