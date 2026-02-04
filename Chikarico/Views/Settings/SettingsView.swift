import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject var persistence: PersistenceService
    @EnvironmentObject var router: Router
    @State private var showExportSheet = false
    @State private var showImportPicker = false
    @State private var showResetConfirmation = false
    @State private var exportedData: Data?
    
    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with SafeArea
                HStack {
                    Button(action: { router.pop() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.textPrimary)
                    }
                    
                    Spacer()
                    
                    Text("Settings")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.clear)
                    }
                }
                .padding(.horizontal, 20)
                .safeAreaInset(edge: .top) {
                    Color.clear.frame(height: 0)
                }
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Preferences
                        SettingsSection(title: "Preferences") {
                            ToggleRow(
                                title: "Show Reflection Prompts",
                                isOn: Binding(
                                    get: { persistence.appState.preferences.showReflectionPrompts },
                                    set: { persistence.appState.preferences.showReflectionPrompts = $0 }
                                )
                            )
                        }
                        
                        // Data Management
                        SettingsSection(title: "Data Management") {
                            SettingsButton(
                                title: "Export Data",
                                icon: "square.and.arrow.up",
                                color: .blue
                            ) {
                                exportData()
                            }
                            
                            SettingsButton(
                                title: "Import Data",
                                icon: "square.and.arrow.down",
                                color: .green
                            ) {
                                showImportPicker = true
                            }
                            
                            SettingsButton(
                                title: "Reset All Data",
                                icon: "trash",
                                color: .red
                            ) {
                                showResetConfirmation = true
                            }
                        }
                        
                        // About
                        SettingsSection(title: "About") {
                            HStack {
                                Text("Version")
                                    .font(.system(size: 17))
                                    .foregroundColor(.textPrimary)
                                Spacer()
                                Text("1.0.0")
                                    .font(.system(size: 17))
                                    .foregroundColor(.textSecondary)
                            }
                            .padding(16)
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .fileExporter(
            isPresented: $showExportSheet,
            document: JSONDocument(data: exportedData ?? Data()),
            contentType: .json,
            defaultFilename: "chikarico_export.json"
        ) { result in
            if case .success = result {
                exportedData = nil
            }
        }
        .fileImporter(
            isPresented: $showImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result,
               let url = urls.first,
               let data = try? Data(contentsOf: url) {
                if persistence.importData(data) {
                    router.setRoot(.home)
                }
            }
        }
        .alert("Reset All Data", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                persistence.resetAllData()
                router.setRoot(.home)
            }
        } message: {
            Text("This will permanently delete all your commitments and categories. This action cannot be undone.")
        }
    }
    
    private func exportData() {
        if let data = persistence.exportData() {
            exportedData = data
            showExportSheet = true
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.textSecondary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.cardBackground)
            .cornerRadius(16)
        }
    }
}

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 17))
                .foregroundColor(.textPrimary)
            Spacer()
            Toggle("", isOn: $isOn)
        }
        .padding(16)
    }
}

struct SettingsButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 17))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
            }
            .padding(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct JSONDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}
