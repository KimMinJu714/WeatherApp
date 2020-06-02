//
//  WeatherDataModel.swift
//  WeatherApp
//
//  Created by Minju on 29/05/2020.
//  Copyright © 2020 KimMinJu. All rights reserved.
//

import Foundation

struct WeatherModel: Codable {
    var weather: [Weather]
    var main: Main
    var wind: Wind
    var rain: Rain?
    var sys: System
    var timezone: Double
}

struct WeatherTimeModel: Codable {
    var dt: Double          // 해당 데이터 기준 시간
    var main: Main
    var weather: [Weather]
}

struct Weather: Codable {
    var main: String        // 날씨 설명
    var description: String // 날씨 상세설명
    var icon: String        // 날씨 이미지
}

struct Main: Codable {
    var temp: Double                 // 현재온도
    var sensibleTemperature: Double? // 체감온도
    var minTemperature: Double       // 최저온도
    var maxTemperature: Double       // 최고온도
    var pressure: Double?            // 기압
    var humidity: Double?            // 습도
    
    init(temp: Double, sensibleTemperature: Double, minTemperature: Double, maxTemperature: Double, pressure: Double, humidity: Double) {
        self.temp                   = temp
        self.sensibleTemperature    = sensibleTemperature
        self.minTemperature         = minTemperature
        self.maxTemperature         = maxTemperature
        self.pressure               = pressure
        self.humidity               = humidity
    }
    
    enum CodingKeys: String, CodingKey {
        case temp
        case sensibleTemperature    = "feels_like"
        case minTemperature         = "temp_min"
        case maxTemperature         = "temp_max"
        case pressure
        case humidity
    }
}

struct Wind: Codable {
    var speed: Double?       // 풍속
    var deg: Double?         // 풍향
}

struct Rain: Codable {
    var hour: Double?        // 1시간 이내 강수량
    
    init(hour: Double) {
        self.hour = hour
    }
    
    enum CodingKeys: String, CodingKey {
        case hour  = "1h"
    }
}

struct System: Codable {
    var sunrise: Double?     // 일출시각
    var sunset: Double?      // 일몰시각
}
