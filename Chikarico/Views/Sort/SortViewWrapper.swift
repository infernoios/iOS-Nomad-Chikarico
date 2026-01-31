import SwiftUI

struct SortViewWrapper: View {
    @EnvironmentObject var persistence: PersistenceService
    @EnvironmentObject var router: Router
    
    var body: some View {
        SortView(sort: Binding(
            get: { persistence.appState.sort },
            set: { persistence.appState.sort = $0 }
        ))
    }
}
