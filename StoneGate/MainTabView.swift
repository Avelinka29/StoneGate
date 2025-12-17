import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationStack {
            DashboardView()
                .navigationBarHidden(true)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager())
}
