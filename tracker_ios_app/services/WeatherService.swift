//
//  WeatherService.swift
//  tracker_ios_app
//
//  Created by macbook on 24/2/2024.
//

import Foundation


class WeatherService {
    func getWeatherFromAPI(latitude: Double, longitude: Double) async throws -> Weather {
        let API_KEY: String = "4eed27602ef8419c96b21526241003"
//        let weatherUrl: String = "https://api.weatherapi.com/v1/current.json?key=\(API_KEY)&q=\(city)&aqi=no"
        let weatherUrl: String = "https://api.weatherapi.com/v1/current.json?key=\(API_KEY)&q=\(latitude),\(longitude)&aqi=no"
        
        print("requesting weather from \(weatherUrl)")
        
        guard let apiURL = URL(string: weatherUrl) else {
            print("ERROR: Invalid url")
            throw URLError(.badURL)
        }
        
        
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Weather, Error>) in
            let request = URLRequest(url: apiURL)
            
            let task = URLSession.shared.dataTask(with: request) {
                (data:Data?, response, error:Error?) in
                
                
                guard error == nil else {
                    print("ERROR: Network error: \(error)")
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }
                
                do {
                    print("weather data is \(data)")
                    if let data = data, let decodedResponse = try? JSONDecoder().decode(Weather.self, from: data) {
                        print("decoded response is \(decodedResponse)")
                        continuation.resume(returning: decodedResponse)
                    }
                }
                catch let error {
                    print("ERROR: Cannot convert to JSON")
                    continuation.resume(throwing: error)
                }
            }
            task.resume()
        }
    }
}
