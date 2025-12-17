//
//  ContentView.swift
//  StoneGate
//
//  Created by Vladislav Kravchuk on 16/12/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager()

    var body: some View {
        if authManager.isAuthenticated {
            MainTabView()
                .environmentObject(authManager)
        } else {
            LoginView()
                .environmentObject(authManager)
        }
    }
}

#Preview {
    ContentView()
}
