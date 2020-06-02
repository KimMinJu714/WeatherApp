//
//  WeatherPreviewVC.swift
//  WeatherApp
//
//  Created by Minju on 27/05/2020.
//  Copyright © 2020 KimMinJu. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherPreviewVC: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.rowHeight = UITableViewAutomaticDimension
        }
    }
    
    let MAX_LOCATION_COUNT = 20     // 지정 가능한 지역 최대 개수
    var locationManager: CLLocationManager = CLLocationManager()
    var previewDataList: [PreviewDataModel] = [PreviewDataModel]() {
        didSet {
            self.tableView.reloadData()
            saveData()
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        addObserver()
        getSavedData()
        setLocationManager()
    }

    deinit {
        removeObserver()
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
            // 외부 설정으로 gps 사용여부 변경 시 dataKind > gps인 데이터 제거
            previewDataList = previewDataList.filter{ $0.location.dataKind == DataKind.search.rawValue }
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        }
    }
    
    func saveData() {
        let data = previewDataList.filter{ $0.location.dataKind == DataKind.search.rawValue }
        var locationList = [LocationModel]()
        data.forEach { (data) in
            locationList.append(data.location)
        }
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(locationList) {
            UserDefaults.standard.set(encoded, forKey: "savedLocation")
        }
    }
    
    func getSavedData() {
        if let objects = UserDefaults.standard.value(forKey: "savedLocation") as? Data {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(Array.self, from: objects) as [LocationModel] {
                decoded.forEach { (location) in
                    self.previewDataList.append(PreviewDataModel(location: location, weather: nil))
                }
                requestAllWeatherData()
            }
        }
    }
    
    // MARK: - Networking
    func requestAllWeatherData() {
        for index in previewDataList.indices {
            let location = previewDataList[index].location
            requestWeatherData(location: location) { (weather) in
                self.previewDataList[index].weather = weather
            }
        }
    }
    
    func requestWeatherData(location: LocationModel,
                            completion: @escaping (WeatherModel) -> Void) {
        NetworkService.getWeather(latitude: location.latitude,
                                  longtitude: location.longtitude) { (weather) in
                                    completion(weather)
        }
    }
    
    // MARK: - Observer
    func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.receiveNotification),
                                               name: NSNotification.Name("timeChanged"),
                                               object: nil)
    }
        
    func removeObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name("timeChanged"),
                                                  object: nil)
    }
    
    @objc func receiveNotification(){
        if self.locationManager.delegate == nil {
            setLocationManager()
        } else {
            updateLocationManager()
        }
        requestAllWeatherData()
    }
    
    // MARK: - Action Event
    @IBAction func addBtnPressed(_ sender: Any) {
        if self.previewDataList.count <= MAX_LOCATION_COUNT {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LocationSearchVC") as! LocationSearchVC
            let navigationController = UINavigationController(rootViewController: vc)
            
            vc.completion = { (value) in
                NetworkService.getWeather(latitude: value.latitude,
                                          longtitude: value.longtitude) { (weather) in
                                            self.previewDataList.append(PreviewDataModel(location: value, weather: weather))
                }
            }

            self.navigationController?.present(navigationController, animated: true, completion: nil)
        }
    }
}

// MARK: - TableView
extension WeatherPreviewVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return previewDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherPreivewCell", for: indexPath) as? WeatherPreivewCell else {
            fatalError("This cell is not an instance of WeatherPreivewCell")
        }
        
        // data default setting
        cell.gpsImg.isHidden = true
        cell.locationLbl.text = "-"
        cell.timeLbl.text = "-"
        cell.temperatureLbl.text = "-°"
        cell.weatherImg.image = nil
        
        let item = previewDataList[indexPath.row]
        
        if let value = item.location.address as? String {
            cell.locationLbl.text = value
        }
        
        if let value = item.weather?.timezone as? Double {
            cell.timeLbl.text = value.toCurrentTime()
        }
        
        if let value = item.weather?.main.temp {
            cell.temperatureLbl.text = value.toCelcius()
        }
        
        if let value = item.location.dataKind as? Int {
            if value == DataKind.gps.rawValue { cell.gpsImg.isHidden = false }
        }
        
        if let value = item.weather?.weather.first?.icon {
            NetworkService.getWeatherImg(id: value) { (image) in
                cell.weatherImg.image = image
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = previewDataList[indexPath.row]
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WeatherDetailVC") as! WeatherDetailVC
        vc.weatherModel = item
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if previewDataList[indexPath.row].location.dataKind == DataKind.gps.rawValue {
            return false 
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.previewDataList.remove(at: indexPath.row)
        }
    }
}

// MARK: - Core Location
extension WeatherPreviewVC: CLLocationManagerDelegate {
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
            guard let placemark = placemarks else {
                return
            }
            if placemark.count > 0{
                let placemark = placemarks![0]
                let location: LocationModel = LocationModel(address: placemark.locality!,
                                                            latitude: locValue.latitude,
                                                            longtitude: locValue.longitude,
                                                            dataKind: DataKind.gps.rawValue)
                
                self.requestWeatherData(location: location) { (weather) in
                    // 이미 위치 정보 기반으로 한 데이터가 리스트에 존재하는 경우 해당 데이터와 교체
                    if let value = self.previewDataList.first?.location.dataKind {
                        if value == DataKind.gps.rawValue {
                            self.previewDataList[0] = PreviewDataModel(location: location,
                                                                       weather: weather)
                            return
                        }
                    }
                    let model = PreviewDataModel(location: location,
                                                 weather: weather)
                    self.previewDataList.insert(model, at: 0)
                }
            }
        }
    }
}
