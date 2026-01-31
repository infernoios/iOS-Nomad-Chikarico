import SwiftUI

struct HomeView: View {
    @StateObject private var persistenceService = PersistenceService()
    @StateObject private var router = Router()
    
    var body: some View {
        ZStack {
            RouterView()
                .environmentObject(persistenceService)
                .environmentObject(router)
                .preferredColorScheme(nil)
        }
    }
}
