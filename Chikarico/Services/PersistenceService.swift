import Foundation
import Combine
import SwiftUI

class PersistenceService: ObservableObject {
    @AppStorage("chikarico_data") private var dataString: String = ""
    
    private let stateSubject = PassthroughSubject<AppState, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var appState: AppState = AppState() {
        didSet {
            stateSubject.send(appState)
        }
    }
    
    init() {
        loadState()
        setupDebouncedSave()
    }
    
    private func setupDebouncedSave() {
        stateSubject
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .sink { [weak self] state in
                self?.saveState(state)
            }
            .store(in: &cancellables)
    }
    
    private func loadState() {
        guard !dataString.isEmpty,
              let data = dataString.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(AppState.self, from: data) else {
            // Start with empty state if no saved data exists
            appState = AppState()
            return
        }
        appState = decoded
        performMaintenance()
    }
    
    private func saveState(_ state: AppState) {
        guard let encoded = try? JSONEncoder().encode(state),
              let string = String(data: encoded, encoding: .utf8) else {
            return
        }
        dataString = string
    }
    
    private func performMaintenance() {
        var updated = false
        
        for i in appState.commitments.commitments.indices {
            if CommitmentCalculator.shouldAutoArchive(appState.commitments.commitments[i]) {
                appState.commitments.commitments[i].status = .archived
                updated = true
            }
        }
        
        if updated {
            saveState(appState)
        }
    }
    
    func exportData() -> Data? {
        return try? JSONEncoder().encode(appState)
    }
    
    func importData(_ data: Data) -> Bool {
        guard let decoded = try? JSONDecoder().decode(AppState.self, from: data) else {
            return false
        }
        appState = decoded
        saveState(appState)
        return true
    }
    
    func resetAllData() {
        appState = AppState()
        saveState(appState)
    }
}
