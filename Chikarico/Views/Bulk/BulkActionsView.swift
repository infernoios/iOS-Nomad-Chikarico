import SwiftUI

struct BulkActionsView: View {
    @EnvironmentObject var persistence: PersistenceService
    @EnvironmentObject var router: Router
    @State private var selectedCommitmentIds: Set<UUID> = []
    @State private var showActionSheet = false
    @State private var showArchiveConfirmation = false
    @State private var showDeleteConfirmation = false
    
    var commitments: [Commitment] {
        persistence.appState.commitments.commitments
            .filter { !$0.isHidden && !$0.status.isArchived }
    }
    
    var allSelected: Bool {
        !commitments.isEmpty && selectedCommitmentIds.count == commitments.count
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
                            
                            Image("icon_back")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.textPrimary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("Bulk Actions")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.textPrimary, .accentOrange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("\(commitments.count) commitment\(commitments.count == 1 ? "" : "s")")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            if allSelected {
                                selectedCommitmentIds.removeAll()
                            } else {
                                selectedCommitmentIds = Set(commitments.map { $0.id })
                            }
                        }
                    }) {
                        Text(allSelected ? "Deselect" : "Select All")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.accentOrange, .accentPink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
                .padding(.horizontal, 20)
                .safeAreaInset(edge: .top) {
                    Color.clear.frame(height: 0)
                }
                .padding(.top, 8)
                .padding(.bottom, 20)
                
                // Selection Bar
                if !selectedCommitmentIds.isEmpty {
                    HStack(spacing: 16) {
                        HStack(spacing: 8) {
                            Image("icon_checkmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.accentOrange)
                            
                            Text("\(selectedCommitmentIds.count) selected")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.textPrimary)
                        }
                        
                        Spacer()
                        
                        // Quick Actions
                        HStack(spacing: 12) {
                            BulkActionButton(
                                icon: "pause.circle.fill",
                                color: .accentOrange,
                                action: bulkPause
                            )
                            
                            BulkActionButton(
                                icon: "archivebox.fill",
                                color: .accentPink,
                                action: { showArchiveConfirmation = true }
                            )
                            
                            BulkActionButton(
                                icon: "trash.fill",
                                color: .red,
                                action: { showDeleteConfirmation = true }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
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
                            .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
                
                // Commitments list
                if commitments.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(commitments) { commitment in
                                BulkActionCommitmentRow(
                                    commitment: commitment,
                                    isSelected: selectedCommitmentIds.contains(commitment.id)
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        if selectedCommitmentIds.contains(commitment.id) {
                                            selectedCommitmentIds.remove(commitment.id)
                                        } else {
                                            selectedCommitmentIds.insert(commitment.id)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .alert("Archive Commitments", isPresented: $showArchiveConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Archive") {
                bulkArchive()
            }
        } message: {
            Text("Archive \(selectedCommitmentIds.count) commitment(s)?")
        }
        .alert("Delete Commitments", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                bulkDelete()
            }
        } message: {
            Text("Permanently delete \(selectedCommitmentIds.count) commitment(s)? This cannot be undone.")
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.accentOrange.opacity(0.3), .accentPink.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image("icon_bulk_actions")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentOrange, .accentPink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 12) {
                Text("No Commitments")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Text("Add commitments to perform bulk actions")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 100)
    }
    
    // MARK: - Actions
    private func bulkPause() {
        for id in selectedCommitmentIds {
            if let index = persistence.appState.commitments.commitments.firstIndex(where: { $0.id == id }) {
                let oldStatus = persistence.appState.commitments.commitments[index].status
                persistence.appState.commitments.commitments[index].status = .paused(pausedAt: Date())
                persistence.appState.commitments.commitments[index].pausedAt = Date()
                HistoryService.recordStatusChange(&persistence.appState.commitments.commitments[index], from: oldStatus, to: .paused(pausedAt: Date()))
            }
        }
        withAnimation {
            selectedCommitmentIds.removeAll()
        }
    }
    
    private func bulkArchive() {
        for id in selectedCommitmentIds {
            if let index = persistence.appState.commitments.commitments.firstIndex(where: { $0.id == id }) {
                let oldStatus = persistence.appState.commitments.commitments[index].status
                persistence.appState.commitments.commitments[index].status = .archived
                HistoryService.recordStatusChange(&persistence.appState.commitments.commitments[index], from: oldStatus, to: .archived)
            }
        }
        withAnimation {
            selectedCommitmentIds.removeAll()
        }
    }
    
    private func bulkDelete() {
        persistence.appState.commitments.commitments.removeAll { selectedCommitmentIds.contains($0.id) }
        withAnimation {
            selectedCommitmentIds.removeAll()
        }
    }
}

// MARK: - Bulk Action Button
struct BulkActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    func actionIcon(for iconName: String) -> Image {
        switch iconName {
        case "pause.circle.fill": return Image("icon_pause_action")
        case "archivebox.fill": return Image("icon_archive_action")
        case "trash.fill": return Image("icon_delete")
        default: return Image(systemName: iconName)
        }
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
                
                actionIcon(for: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
        }
    }
}

// MARK: - Bulk Action Commitment Row
struct BulkActionCommitmentRow: View {
    let commitment: Commitment
    let isSelected: Bool
    let onToggle: () -> Void
    @EnvironmentObject var persistence: PersistenceService
    @EnvironmentObject var router: Router
    
    var category: Category? {
        persistence.appState.categories.categories.first { $0.id == commitment.categoryId }
    }
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            isSelected
                                ? LinearGradient(colors: [.accentOrange, .accentPink], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 28, height: 28)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    isSelected
                                        ? AnyShapeStyle(LinearGradient(colors: [Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        : AnyShapeStyle(LinearGradient(colors: [.textSecondary.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)),
                                    lineWidth: 2
                                )
                        )
                    
                    if isSelected {
                        Image("icon_checkmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                    }
                }
                
                // Category indicator
                RoundedRectangle(cornerRadius: 4)
                    .fill(category?.color.color ?? .gray)
                    .frame(width: 4, height: 40)
                
                // Commitment info
                VStack(alignment: .leading, spacing: 6) {
                    Text(commitment.title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                    
                    HStack(spacing: 16) {
                        Label(commitment.nextOccurrenceDate.formattedRelative(), systemImage: "clock.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textSecondary)
                        
                        if let category = category {
                            Label(category.name, systemImage: "folder.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                // Tap to view
                Button(action: {
                    router.push(.commitmentDetail(id: commitment.id))
                }) {
                    Image("icon_chevron_right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                }
            }
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            isSelected
                                ? LinearGradient(
                                    colors: [
                                        Color.accentOrange.opacity(0.15),
                                        Color.accentOrange.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
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
                            isSelected
                                ? LinearGradient(
                                    colors: [.accentOrange.opacity(0.4), .accentOrange.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [
                                        (category?.color.color ?? .gray).opacity(0.2),
                                        (category?.color.color ?? .gray).opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                            lineWidth: isSelected ? 2 : 1
                        )
                }
            )
            .shadow(
                color: isSelected
                    ? .accentOrange.opacity(0.2)
                    : .black.opacity(0.1),
                radius: isSelected ? 16 : 8,
                x: 0,
                y: isSelected ? 8 : 4
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
