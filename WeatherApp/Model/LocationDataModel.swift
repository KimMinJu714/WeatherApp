//
//  LocationDataModel.swift
//  WeatherApp
//
//  Created by Minju on 29/05/2020.
//  Copyright © 2020 KimMinJu. All rights reserved.
//

import UIKit

// (gps/검색) 기반 데이터
enum DataKind:Int {
    case gps = 0
    case search
}

struct LocationModel: Codable {
    var address: String         // 주소명
    var latitude: Double        // 위도
    var longtitude: Double      // 경도
    var dataKind: Int
}

struct City: Codable {
    var timezone: Double        // 해당 도시 타임존
}
