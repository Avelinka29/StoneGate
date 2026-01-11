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
    @StateObject private var theme = Theme()

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    MainTabView()
                        .environmentObject(authManager)
                        .environment(\.theme, theme)
                } else {
                    LoginView()
                        .environmentObject(authManager)
                        .environment(\.theme, theme)
                }
            }
            .preferredColorScheme(theme.isDarkMode ? .dark : .light)
        }
    }
}
