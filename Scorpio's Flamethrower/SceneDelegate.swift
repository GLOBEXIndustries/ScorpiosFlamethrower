import UIKit
import SwiftUI // Critical for UIHostingController

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // 1. Initialize the UI we built in ContentView.swift
        let contentView = ContentView()

        // 2. Wrap it in a controller that UIKit understands
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            
            // 3. Make this window the one that actually shows up
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
