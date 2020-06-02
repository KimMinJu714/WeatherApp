//
//  AppDelegate.swift
//  WeatherApp
//
//  Created by Minju on 29/05/2020.
//  Copyright © 2020 KimMinJu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var timer: Timer = Timer()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        setTimer()
        if NetworkService.isReachability() {
            NotificationCenter.default.post(name: NSNotification.Name("timeChanged"), object: nil)
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        removeTimer()
    }
    
    func setTimer() {
        let now: Date = Date()
        let calendar: Calendar = Calendar.current
        let currentSeconds: Int = calendar.component(.second, from: now)
        
        // 정각기준으로 1분마다 데이터 갱신 요청
        timer = Timer(
            fire: now.addingTimeInterval(Double(60 - currentSeconds)),
            interval: 60,
            repeats: true,
            block: { (timer) in
                if NetworkService.isReachability() {
                    NotificationCenter.default.post(name: NSNotification.Name("timeChanged"), object: nil)
                }
        })

        RunLoop.main.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    func removeTimer() {
        timer.invalidate()
    }
}
