//
//  Double+Extension.swift
//  WeatherApp
//
//  Created by Minju on 29/05/2020.
//  Copyright © 2020 KimMinJu. All rights reserved.
//

import UIKit

extension Double {
    
    // 켈빈 >> 섭씨로 표기
    func toCelcius() -> String {
        let celciusUnit = UnitTemperature.celsius
        let celcius = Int(celciusUnit.converter.value(fromBaseUnitValue: self))
        return "\(celcius)°"
    }
    
    // 풍향 8방위로 표기
    func toWindDirection() -> String {
        switch self {
            case 360, 0..<1:
                return"북풍"
            case 1..<90:
                return "북동풍"
            case 90..<91:
                return "동풍"
            case 91..<180:
                return "남동풍"
            case 180..<181:
                return "남풍"
            case 181..<270:
                return "남서풍"
            case 270..<271:
                return "서풍"
            case 271..<360:
                return "북서풍"
            default:
                return ""
        }
    }
    
    // MARK: - Time Setting(UTC 기준)
    // 해당 지역 현재 시간으로 변환
    func toCurrentTime() -> String {
        let today = Date()
        let localDate = Date(timeInterval: TimeInterval(self), since: today)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        return dateFormatter.string(from: localDate)
    }
    
    // 해당 지역 특정 시간으로 변환
    func toSpecificTime(timeZone: Double, dateFormat: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let localDate = Date(timeInterval: TimeInterval(timeZone), since: date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        return dateFormatter.string(from: localDate)
    }
    
    // 해당 지역 요일 변환
    func toCurrentDay(_ nextDay: Int = 0) -> String {
        let today = Date()
        guard let date = Calendar.current.date(byAdding: .day, value: nextDay, to: today) else {
            return "-"
        }
        let localDate = Date(timeInterval: TimeInterval(self), since: date)
        
        guard let zone = TimeZone(abbreviation: "UTC") else {
            return "-"
        }
        var calendar = Calendar.current
        calendar.timeZone = zone

        switch calendar.component(.weekday, from: localDate) {
            case 1:
                return "일요일"
            case 2:
                return "월요일"
            case 3:
                return "화요일"
            case 4:
                return "수요일"
            case 5:
                return "목요일"
            case 6:
                return "금요일"
            case 7:
                return "토요일"
            default:
                return "-"
        }
    }

    
}
