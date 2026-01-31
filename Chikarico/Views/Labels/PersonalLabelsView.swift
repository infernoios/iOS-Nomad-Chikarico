import SwiftUI

struct PersonalLabelsView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var persistence: PersistenceService
    @State private var showAddLabel = false
    
    var labels: [PersonalLabel] {
        persistence.appState.personalLabels.labels
    }
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color.gradientStart,
                    Color.gradientEnd,
                    Color.backgroundPrimary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { router.pop() }) {
                        ZStack {
                            Circle()
                                .fill(Color.cardBackground.opacity(0.6))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.textPrimary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("Personal Labels")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.textPrimary, .accentPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("\(labels.count) label\(labels.count == 1 ? "" : "s")")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    Button(action: { showAddLabel = true }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.accentPurple, .accentPink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 40, height: 40)
                                .shadow(color: .accentPurple.opacity(0.4), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 20)
                
                // Content
                if labels.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 12) {
                            ForEach(labels) { label in
                                LabelCard(label: label, persistence: persistence)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddLabel) {
            AddPersonalLabelView()
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.accentPurple.opacity(0.3), .accentPink.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image(systemName: "tag.fill")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentPurple, .accentPink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 12) {
                Text("No Labels Yet")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Text("Create custom labels to organize your commitments")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: { showAddLabel = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    Text("Create Label")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.accentPurple, .accentPink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .accentPurple.opacity(0.4), radius: 16, x: 0, y: 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 100)
    }
}

// MARK: - Personal Label Model
struct PersonalLabel: Identifiable, Codable {
    let id = UUID()
    var name: String
    var color: CategoryColor
    var icon: String
    var createdAt: Date
    
    init(name: String, color: Color, icon: String, createdAt: Date) {
        self.name = name
        self.color = CategoryColor(color)
        self.icon = icon
        self.createdAt = createdAt
    }
    
    var colorValue: Color {
        color.color
    }
}

// MARK: - Label Card
struct LabelCard: View {
    let label: PersonalLabel
    let persistence: PersistenceService
    @State private var showDeleteConfirmation = false
    
    var commitmentsCount: Int {
        persistence.appState.commitments.commitments.filter { commitment in
            // Check if commitment has this label (assuming labels are stored as tags or similar)
            // For now, we'll just show the label info
            true
        }.count
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                label.colorValue.opacity(0.3),
                                label.colorValue.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: label.colorValue.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: label.icon)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(label.colorValue)
            }
            
            VStack(spacing: 4) {
                Text(label.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text("Created \(label.createdAt.formattedRelative())")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.cardBackground,
                                Color.cardBackground.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                label.colorValue.opacity(0.4),
                                label.colorValue.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Add Personal Label View
struct AddPersonalLabelView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var persistence: PersistenceService
    @State private var name: String = ""
    @State private var selectedColor: Color = .accentBlue
    @State private var selectedIcon: String = "tag.fill"
    
    let colors: [Color] = [.accentBlue, .accentPurple, .accentPink, .accentOrange, .accentGreen, .yellow, .red]
    let icons: [String] = ["tag.fill", "star.fill", "heart.fill", "flag.fill", "bookmark.fill", "pin.fill", "sparkles", "bolt.fill"]
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.gradientStart,
                        Color.gradientEnd,
                        Color.backgroundPrimary
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Label Name")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.textSecondary)
                            
                            TextField("e.g., Important", text: $name)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Color
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Color")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.textSecondary)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                ForEach(colors, id: \.self) { color in
                                    Button(action: {
                                        selectedColor = color
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(color)
                                                .frame(width: 50, height: 50)
                                                .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
                                            
                                            if selectedColor == color {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 20, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Icon
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Icon")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.textSecondary)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                ForEach(icons, id: \.self) { icon in
                                    Button(action: {
                                        selectedIcon = icon
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(
                                                    selectedIcon == icon
                                                        ? selectedColor.opacity(0.2)
                                                        : Color.cardBackground.opacity(0.5)
                                                )
                                                .frame(width: 50, height: 50)
                                            
                                            Image(systemName: icon)
                                                .font(.system(size: 24, weight: .semibold))
                                                .foregroundColor(
                                                    selectedIcon == icon
                                                        ? selectedColor
                                                        : .textSecondary
                                                )
                                        }
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    selectedIcon == icon
                                                        ? selectedColor.opacity(0.5)
                                                        : Color.clear,
                                                    lineWidth: 2
                                                )
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("New Label")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let label = PersonalLabel(
                            name: name,
                            color: selectedColor,
                            icon: selectedIcon,
                            createdAt: Date()
                        )
                        persistence.appState.personalLabels.labels.append(label)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
