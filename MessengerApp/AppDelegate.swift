//
//  AppDelegate.swift
//  MessengerApp
//
//  Created by sixpep on 21/02/23.
//

// AppDelegate.swift
import UIKit
import FacebookCore
import FirebaseCore
import GoogleSignIn

@UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate {
func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    
    FirebaseApp.configure()
    ApplicationDelegate.shared.application(
        application,
        didFinishLaunchingWithOptions: launchOptions
    )

    return true
}
      
func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
) -> Bool {
    ApplicationDelegate.shared.application(
        app,
        open: url,
        sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
        annotation: options[UIApplication.OpenURLOptionsKey.annotation]
    )
    
    var handler: Bool
    
    handler = GIDSignIn.sharedInstance.handle(url)
    if handler {
        return true
    }
    
    return false
}
}
