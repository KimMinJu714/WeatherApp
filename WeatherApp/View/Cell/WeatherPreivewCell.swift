//
//  WeatherPreivewCell.swift
//  WeatherApp
//
//  Created by Minju on 27/05/2020.
//  Copyright © 2020 KimMinJu. All rights reserved.
//

import UIKit

class WeatherPreivewCell: UITableViewCell {
    
    @IBOutlet weak var timeLbl: UILabel!              // 지역 기준 현재 시간
    @IBOutlet weak var locationLbl: UILabel!          // 지역명
    @IBOutlet weak var temperatureLbl: UILabel!       // 지역 기준 현재 온도
    @IBOutlet weak var gpsImg: UIImageView!           // gps 기반 데이터 표시
    @IBOutlet weak var weatherImg: UIImageView!       // 날씨 상태 이미지
}
