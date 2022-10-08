//
//  AppDelegate.swift
//  MetalProduct
//
//  Created by 王龙飞 on 2022/10/8.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        self.window?.rootViewController = UINavigationController(rootViewController: UIMetalMainVC())
        
        self.window?.makeKeyAndVisible()
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    


}

