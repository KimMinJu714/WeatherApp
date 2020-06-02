//
//  TimeWeatherCell.swift
//  WeatherApp
//
//  Created by Minju on 31/05/2020.
//  Copyright © 2020 KimMinJu. All rights reserved.
//

import UIKit

class TimeWeatherCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLbl: UILabel!        // 시간
    @IBOutlet weak var weatherImg: UIImageView! // 날씨 상태 이미지
    @IBOutlet weak var temperatureLbl: UILabel! // 현재 온도
}
