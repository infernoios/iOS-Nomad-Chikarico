import SwiftUI

struct FilterViewWrapper: View {
    @EnvironmentObject var persistence: PersistenceService
    @EnvironmentObject var router: Router
    
    var body: some View {
        FilterView(filter: Binding(
            get: { persistence.appState.filter },
            set: { persistence.appState.filter = $0 }
        ))
    }
}
