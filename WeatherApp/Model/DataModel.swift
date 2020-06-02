//
//  DataModel.swift
//  WeatherApp
//
//  Created by Minju on 30/05/2020.
//  Copyright © 2020 KimMinJu. All rights reserved.
//

import UIKit

struct PreviewDataModel: Codable {
    var location: LocationModel
    var weather: WeatherModel?
}

struct TimeDataModel: Codable {
    var city: City
    var list: [WeatherTimeModel]
}
