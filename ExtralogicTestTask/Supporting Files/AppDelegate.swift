//
//  AppDelegate.swift
//  ExtralogicTestTask
//
//  Created by Илья Андреев on 18.04.2022.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().tintColor = .orange
        UIToolbar.appearance().tintColor = .orange
        CoreDataManager.shared.load()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: NotesListViewController())
        window?.makeKeyAndVisible()
        return true
    }
}
