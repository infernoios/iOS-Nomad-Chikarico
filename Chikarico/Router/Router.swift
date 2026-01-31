import SwiftUI
import Combine

class Router: ObservableObject {
    @Published var navigationStack: [Route] = []
    
    var currentRoute: Route? {
        navigationStack.last
    }
    
    func push(_ route: Route) {
        withAnimation(.easeInOut(duration: 0.3)) {
            navigationStack.append(route)
        }
    }
    
    func pop() {
        guard !navigationStack.isEmpty else { return }
        _ = withAnimation(.easeInOut(duration: 0.3)) {
            navigationStack.removeLast()
        }
    }
    
    func setRoot(_ route: Route) {
        withAnimation(.easeInOut(duration: 0.3)) {
            navigationStack = [route]
        }
    }
    
    func popToRoot() {
        guard navigationStack.count > 1 else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            navigationStack = [navigationStack.first!]
        }
    }
}
