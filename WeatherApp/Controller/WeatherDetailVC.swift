//
//  WeatherDetailVC.swift
//  WeatherApp
//
//  Created by Minju on 27/05/2020.
//  Copyright © 2020 KimMinJu. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherDetailVC: UIViewController {

    @IBOutlet weak var addressLbl: UILabel!                         // 현재 날씨 상세 페이지 주소
    @IBOutlet weak var weatherDescriptionLbl: UILabel!              // 날씨 상태
    @IBOutlet weak var temperatureLbl: UILabel!                     // 현재 온도
    @IBOutlet weak var dayLbl: UILabel!                             // 요일
    @IBOutlet weak var maxTemperatureLbl: UILabel!                  // 최대 기온
    @IBOutlet weak var minTemperatureLbl: UILabel!                  // 최저 기온
    @IBOutlet weak var summaryLbl: UILabel!                         // 오늘 날씨 요약
    @IBOutlet weak var sunriseLbl: UILabel!                         // 일출
    @IBOutlet weak var sunsetLbl: UILabel!                          // 일몰
    @IBOutlet weak var precipitationLbl: UILabel!                   // 강수량
    @IBOutlet weak var humidLbl: UILabel!                           // 습도
    @IBOutlet weak var windLbl: UILabel!                            // 바람
    @IBOutlet weak var sensibleTemperatureLbl: UILabel!             // 체감온도
    @IBOutlet weak var pressureLbl: UILabel!                        // 기압
    @IBOutlet weak var weeklyViewHeightConst: NSLayoutConstraint!   // 테이블 뷰 height
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.rowHeight = UITableViewAutomaticDimension
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate   = self
            collectionView.dataSource = self
        }
    }
    
    let MAX_TIME_DATA_COUNT = 8     // "https://openweathermap.org/forecast5"에서 제공되는 24시간 데이터 최대 개수
    var weatherModel: PreviewDataModel?
    var timeDataModel: TimeDataModel?
    var timeWeatherList: [WeatherTimeModel]   = [WeatherTimeModel]()        // 시간별 일기예보 데이터
    var weeklyWeatherList: [[String:Any]] = [[String:Any]]()                // 시간 기반 주간별 일기예보 데이터
    var locationManager: CLLocationManager = CLLocationManager()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        viewSetting()
        addObserver()

        requestTimeBasedData()
    }
    
    deinit {
        removeObserver()
    }
    
    func viewSetting() {
        let location = weatherModel?.location
        let weather = weatherModel?.weather
        
        var summaryStr = "오늘 :"
        var windDirection = ""
        
        if let value = location?.address {
            self.addressLbl.text = value
        }
        
        if let value = weather?.weather.first?.main {
            self.weatherDescriptionLbl.text = value
            summaryStr = summaryStr + " 현재 날씨 \(value)."
        }
        
        if let value = weather?.main.temp {
            self.temperatureLbl.text = value.toCelcius()
        }
        
        if let value = weather?.timezone {
            self.dayLbl.text = value.toCurrentDay()
        }
        
        if let value = weather?.main.maxTemperature {
            self.maxTemperatureLbl.text = value.toCelcius()
            summaryStr = summaryStr + " 최고기온은 \(value.toCelcius())입니다."
        }
        
        if let value = weather?.main.minTemperature {
            self.minTemperatureLbl.text = value.toCelcius()
            summaryStr = summaryStr + " 최저기온은 \(value.toCelcius())입니다."
        }
        
        if let value = weather?.sys.sunrise,
            let timeZone = weather?.timezone {
            self.sunriseLbl.text = value.toSpecificTime(timeZone: timeZone, dateFormat: "HH:mm")
        }
        
        if let value = weather?.sys.sunset,
            let timeZone = weather?.timezone {
            self.sunsetLbl.text = value.toSpecificTime(timeZone: timeZone, dateFormat: "HH:mm")
        }
        
        if let value = weather?.rain?.hour {
            self.precipitationLbl.text = "\(value)mm"
        }
        
        if let value = weather?.main.humidity {
            self.humidLbl.text = "\(Int(value))%"
        }
        
        if let value = weather?.main.sensibleTemperature {
            self.sensibleTemperatureLbl.text = value.toCelcius()
        }
        
        if let value = weather?.main.pressure {
            self.pressureLbl.text = "\(Int(value))hPa"
        }
        
        if let value = weather?.wind.deg {
            windDirection = "\(value.toWindDirection()) "
        }
        
        if let value = weather?.wind.speed {
            self.windLbl.text = "\(windDirection)\(value)m/s"
        }
        
        self.summaryLbl.text = summaryStr
    }
    
    func setLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        updateLocationManager()
    }
    
    func updateLocationManager() {
        switch(CLLocationManager.authorizationStatus()) {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted, .denied:
            // not use GPS >> 이전에 업데이트 된 지역 정보로 날씨 데이터만 갱신
            requestWeatherData()
            break
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        }
    }
    
    func setTimeWeatherList() {
        if let timeDataModel = self.timeDataModel {
            if timeDataModel.list.count > MAX_TIME_DATA_COUNT {
                timeWeatherList = Array(timeDataModel.list[0..<8])
            } else {
                timeWeatherList = Array(timeDataModel.list[0..<timeDataModel.list.count])
            }
            collectionView.reloadData()
        }
    }
    
    func setWeeklyWeatherList() {
        if let timeDataModel = self.timeDataModel {
            var array = [[String:Any]]()
            for index in timeDataModel.list.indices {
                if index % 7 == 0 {
                    let item = timeDataModel.list[index]
                    let temperatureResult = setMaxAndMinTemperature(model: timeDataModel, comparedTime: item.dt)
                    if index == 0 { // 당일데이터
                        if (weatherModel?.weather?.main.maxTemperature ?? 0) < temperatureResult.0 {
                            weatherModel?.weather?.main.maxTemperature = temperatureResult.0
                        }
                        if (weatherModel?.weather?.main.minTemperature ?? 0) > temperatureResult.1 {
                            weatherModel?.weather?.main.minTemperature = temperatureResult.1
                        }
                        viewSetting()
                    } else {        // 주간데이터
                        array.append(["max" : temperatureResult.0,
                                      "min" : temperatureResult.1,
                                      "model" : item])
                    }
                }
            }
            
            weeklyWeatherList = array
            tableView.reloadData()
        }
    }
    
    // 해당 API가 정확한 일별 최저/최고 기온을 제공하지 않음 (현재 시점의 최저/최고 기온만 제공)
    // 1. 주간 최저/최고 기온 : 제공되는 3시간 간격 데이터를 기반으로 최저/최고 기온 지정
    // 2. 오늘 최저/최고 기온 : 제공되는 3시간 간격 데이터를 기반으로 최저/최고 기온 지정 후 현재 최저/최고 기온과 비교하여 지정
    func setMaxAndMinTemperature(model: TimeDataModel, comparedTime: Double) -> (Double, Double) {
        let timeZone = model.city.timezone
        let list = model.list.filter{ $0.dt.toSpecificTime(timeZone: timeZone, dateFormat: "yyyymmdd") == comparedTime.toSpecificTime(timeZone: timeZone, dateFormat: "yyyymmdd") }
        
        let maxTemperature = list.sorted(by: { $0.main.maxTemperature > $1.main.maxTemperature }).first?.main.maxTemperature ?? 0
        let minTemperature = list.sorted(by: { $0.main.minTemperature < $1.main.minTemperature }).first?.main.minTemperature ?? 0
        
        return (maxTemperature, minTemperature)
    }
    
    // MARK: - Networking
    func requestWeatherData() {
        if let location = weatherModel?.location {
            NetworkService.getWeather(latitude: location.latitude,
                                      longtitude: location.longtitude) { (weather) in
                                        self.weatherModel?.weather = weather
                                        self.viewSetting()
                                        self.requestTimeBasedData()
            }
        }
    }
    
    func requestTimeBasedData() {
        if let location = weatherModel?.location {
            NetworkService.getTimeBasedWeather(latitude: location.latitude,
                                            longtitude: location.longtitude) { (weather) in

                self.timeDataModel = weather
                self.setTimeWeatherList()
                self.setWeeklyWeatherList()
            }
        }
    }
    
    // MARK: - Observer
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNotification), name: NSNotification.Name("timeChanged"), object: nil)
        self.tableView.addObserver(self, forKeyPath: "contentSize",
                                   options: [.old, .new],
                                   context: nil)
    }
        
    func removeObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name("timeChanged"),
                                                  object: nil)
        self.tableView.removeObserver(self,
                                      forKeyPath: "contentSize")
    }
        
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let observedObject = object as? UITableView, observedObject == tableView {
            let contentSize = tableView.contentSize.height
            self.weeklyViewHeightConst.constant = contentSize
        }
    }
    
    @objc func receiveNotification(){
        if weatherModel?.location.dataKind == DataKind.gps.rawValue {
            if locationManager.delegate == nil {
                setLocationManager()
            } else {
                updateLocationManager()
            }
        } else {
            requestWeatherData()
        }
    }
    
    // MARK: - Action Event
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - CollectionView
extension WeatherDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeWeatherList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeWeatherCell", for: indexPath) as? TimeWeatherCell else {
            fatalError("This cell is not an instance of TimeWeatherCell")
        }
        
        let item = timeWeatherList[indexPath.row]
        
        if let value = item.dt as? Double,
            let timezone = self.timeDataModel?.city.timezone {
            cell.timeLbl.text = value.toSpecificTime(timeZone: timezone, dateFormat: "HH:mm")
        }
        
        if let value = item.main.temp as? Double {
            cell.temperatureLbl.text = value.toCelcius()
        }
        
        if let value = item.weather.first?.icon {
            NetworkService.getWeatherImg(id: value) { (image) in
                cell.weatherImg.image = image
            }
        }

        return cell
    }
}

// MARK: - TableView
extension WeatherDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weeklyWeatherList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeeklyWeatherCell", for: indexPath) as? WeeklyWeatherCell else {
            fatalError("This cell is not an instance of WeeklyWeatherCell")
        }
        
        guard let item = weeklyWeatherList[indexPath.row]["model"] as? WeatherTimeModel else {
            return cell
        }
        
        if let value = item.weather.first?.icon {
            NetworkService.getWeatherImg(id: value) { (image) in
                cell.weatherImg.image = image
            }
        }
        
        if let value = self.timeDataModel?.city.timezone {
            cell.dayLbl.text = value.toCurrentDay(indexPath.row + 1)
        }
        
        if let value = weeklyWeatherList[indexPath.row]["max"] as? Double {
            cell.maxTemperatureLbl.text = value.toCelcius()
        }
        
        if let value = weeklyWeatherList[indexPath.row]["min"] as? Double {
            cell.minTemperatureLbl.text = value.toCelcius()
        }
        
        return cell
    }
}

// MARK: - Core Location
extension WeatherDetailVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate

        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil

        let userLocation :CLLocation = locations[0] as CLLocation

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                print("error in reverseGeocode")
            }
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count>0{
                let placemark = placemarks![0]
                let location: LocationModel = LocationModel(address: placemark.locality!,
                                                            latitude: locValue.latitude,
                                                            longtitude: locValue.longitude,
                                                            dataKind: DataKind.gps.rawValue)
                
                self.weatherModel?.location = location
                self.requestWeatherData()
            }
        }
    }
}
