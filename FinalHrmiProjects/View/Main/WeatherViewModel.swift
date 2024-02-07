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

    func getWeather(latitude: Double, longitude: Double, completion: @escaping (Weather?) -> Void) {
        let weatherURL = "\(baseURL)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)"
        
        guard let url = URL(string: weatherURL) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completion(nil)
                return
            }
            
            let decoder = JSONDecoder()
            if let weatherData = try? decoder.decode(WeatherData.self, from: data) {
                completion(weatherData.weather.first)
                print("API Call")
            } else {
                completion(nil)
            }
        }.resume()
    }
}

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?

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
            fatalError("Couldn't find file 'SecureAPIKeys.plist'.")
        }
        guard let value = plistDict.object(forKey: "API_KEY") as? String else {
            fatalError("Couldn't find key 'API_Key' in 'SecureAPIKeys.plist'.")
        }
        
        return value
    }
}
