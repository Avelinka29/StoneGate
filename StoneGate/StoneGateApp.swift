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

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    MainTabView()
                        .environmentObject(authManager)
                } else {
                    LoginView()
                        .environmentObject(authManager)
                }
            }
            .preferredColorScheme(.dark) // Темная тема по умолчанию
        }
    }
}
