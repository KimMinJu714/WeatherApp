//
//  WeeklyWeatherCell.swift
//  WeatherApp
//
//  Created by Minju on 31/05/2020.
//  Copyright © 2020 KimMinJu. All rights reserved.
//

import UIKit

class WeeklyWeatherCell: UITableViewCell {

    @IBOutlet weak var dayLbl: UILabel!             // 요일
    @IBOutlet weak var weatherImg: UIImageView!     // 날씨 상태 이미지
    @IBOutlet weak var maxTemperatureLbl: UILabel!  // 최고 기온
    @IBOutlet weak var minTemperatureLbl: UILabel!  // 최저 기온
}
