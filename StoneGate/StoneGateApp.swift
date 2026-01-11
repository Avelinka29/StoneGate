//
//  StoneGateApp.swift
//  StoneGate
//
//  Created by Vladislav Kravchuk on 16/12/2025.
//

import SwiftUI

@main
struct StoneGateApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    MainTabView()
                        .environmentObject(authManager)
                        .environmentObject(themeManager)
                } else {
                    LoginView()
                        .environmentObject(authManager)
                        .environmentObject(themeManager)
                }
            }
            .preferredColorScheme(ThemeManager.shared.isDarkMode ? .dark : .light)
        }
    }
}
