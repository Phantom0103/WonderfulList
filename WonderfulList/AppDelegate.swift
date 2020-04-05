//
//  AppDelegate.swift
//  WonderfulList
//
//  Created by 周伟 on 2020/3/5.
//  Copyright © 2020 周伟. All rights reserved.
//

import UIKit
import RealmSwift
//import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let defaults = UserDefaults.standard
    let realm = try! Realm()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 请求通知权限
        //UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (accepted, error) in}
        
        let hasLaunch = defaults.bool(forKey: UserDefaultsKeys.hasLaunch)
        if !hasLaunch {
            window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GuideVC")
            defaults.set(true, forKey: UserDefaultsKeys.hasLaunch)
        }
        
        resetTodayTag()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        resetTodayTag()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // 清空“新的一天”清单数据
    private func resetTodayTag() {
        let lastTs = defaults.double(forKey: UserDefaultsKeys.todayTagResetTs)
        
        // 获取当天0点时间戳
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date.init())
        let nowTs = calendar.date(from: components)!.timeIntervalSince1970
        
        if lastTs < nowTs {
            let tasks = realm.objects(ListTask.self).filter("today = true")
            if !tasks.isEmpty {
                try? realm.write {
                    tasks.setValue(false, forKey: "today")
                    tasks.setValue(Date.init(), forKey: "updateTime")
                }
            }
            
            defaults.set(Date.init().timeIntervalSince1970, forKey: UserDefaultsKeys.todayTagResetTs)
        }
    }
}

