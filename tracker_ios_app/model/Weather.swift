//
//  Weather.swift
//  tracker_ios_app
//
//  Created by macbook on 9/3/2024.
//

import Foundation

struct Weather: Decodable {
    let name: String
    let region: String
    let country: String
    let latitude: Double
    let longitude: Double
    
    let temp: Double
    let humidity: Double
    let condition: String
    let conditionIconUrl: URL
    let lastUpdate: String
 
    enum locationKeys: String, CodingKey {
        case name
        case region
        case country
        case latitude = "lat"
        case longitude = "lon"
    }
    
    enum conditionKeys: String, CodingKey {
        case text
        case icon
    }
    
    enum currentWeatherKeys: String, CodingKey {
        case temp_c
        case humidity
        case condition
        case last_updated
    }
    
    enum CodingKeys: String, CodingKey {
        case location
        case current
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let locationContainer = try container.nestedContainer(keyedBy: locationKeys.self, forKey: .location)
        let currentWeatherContainer = try container.nestedContainer(keyedBy: currentWeatherKeys.self, forKey: .current)
        let conditionContainer = try currentWeatherContainer.nestedContainer(keyedBy: conditionKeys.self, forKey: .condition)
        
        // for decoding json from the API
        name = try locationContainer.decode(String.self, forKey: .name)
        region = try locationContainer.decode(String.self, forKey: .region)
        country = try locationContainer.decode(String.self, forKey: .country)
        latitude = try locationContainer.decode(Double.self, forKey: .latitude)
        longitude = try locationContainer.decode(Double.self, forKey: .longitude)
        
        temp = try currentWeatherContainer.decode(Double.self, forKey: .temp_c)
        humidity = try currentWeatherContainer.decode(Double.self, forKey: .humidity)
        condition = try conditionContainer.decode(String.self, forKey: .text)
        conditionIconUrl = URL(string: "https:\(try conditionContainer.decode(String.self, forKey: .icon))")!
        lastUpdate = try currentWeatherContainer.decode(String.self, forKey: .last_updated)
    }
}
