//
//  NetworkService.swift
//  WeatherApp
//
//  Created by Minju on 29/05/2020.
//  Copyright © 2020 KimMinJu. All rights reserved.
//

import UIKit
import SystemConfiguration

let URL_WEATHER         = "http://api.openweathermap.org/data/2.5/weather?lat={latitude}&lon={longtitude}&appid=dff9276e6dc2229f422fa84d397fd320&lang=kr"
let URL_WEATHER_DETAIL  = "http://api.openweathermap.org/data/2.5/forecast?lat={latitude}&lon={longtitude}&appid=dff9276e6dc2229f422fa84d397fd320&lang=kr"
let URL_WEATHER_IMAGE   = "http://openweathermap.org/img/wn/{id}@2x.png"

class NetworkService: NSObject {
    
    static func isReachability() -> Bool {
        var zeroAddr = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddr.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddr))
        zeroAddr.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroAddr in
                SCNetworkReachabilityCreateWithAddress(nil, zeroAddr)
            }
        }

        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }

        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0

        return (isReachable && !needsConnection)
    }

    static func getWeather(latitude: Double, longtitude: Double, completion: @escaping (WeatherModel) -> Void) {
        var urlString = URL_WEATHER.replacingOccurrences(of: "{latitude}", with: "\(latitude)")
        urlString = urlString.replacingOccurrences(of: "{longtitude}", with: "\(longtitude)")
        
        NetworkService.request(urlString: urlString, completion: { (data) in
            guard let responseData = data else {
                return
            }
            do {
                let weather = try JSONDecoder().decode(WeatherModel.self, from: responseData)
                completion(weather)
            } catch {
                print(error)
            }
        }) { (error) in
            print(error)
            showNetworkErrorMessage()
        }
    }
    
    static func getTimeBasedWeather(latitude: Double, longtitude: Double, completion: @escaping (TimeDataModel) -> Void) {
        var urlString = URL_WEATHER_DETAIL.replacingOccurrences(of: "{latitude}", with: "\(latitude)")
        urlString = urlString.replacingOccurrences(of: "{longtitude}", with: "\(longtitude)")
        
        NetworkService.request(urlString: urlString, completion: { (data) in
            guard let responseData = data else {
                return
            }
            do {
                let detailData = try JSONDecoder().decode(TimeDataModel.self, from: responseData)
                completion(detailData)
            } catch {
                print(error)
            }
        }) { (error) in
            print(error)
            showNetworkErrorMessage()
        }
    }
    
    static func getWeatherImg(id: String, completion: @escaping (UIImage?) -> Void) {
        let urlString = URL_WEATHER_IMAGE.replacingOccurrences(of: "{id}", with: id)
        
        NetworkService.request(urlString: urlString, completion: { (data) in
            guard let responseData = data else {
                return
            }
            if let image = UIImage(data: responseData) {
                completion(image)
            } else {
                completion(nil)
            }
        }) { (error) in
            print(error)
        }
    }
    
    static func request(urlString: String, completion: @escaping (Data?) -> Void, failureCompletion: @escaping (Error) -> Void) {
        let url = URL(string: urlString)!
        let urlRequest = URLRequest(url: url)
        let defaultSession = URLSession(configuration: .default)
            
        defaultSession.dataTask(with: urlRequest) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    failureCompletion(error)
                    return
                }
                completion(data)
            }
        }.resume()
    }
    
    static func showNetworkErrorMessage() {
        let alert = UIAlertController(title: "네트워크 오류", message: "네트워크 연결상태를 다시 확인해주세요.", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil)
        
        alert.addAction(action)
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
