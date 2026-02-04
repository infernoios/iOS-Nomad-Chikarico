import SwiftUI

struct CommitmentDetailView: View {
    let commitmentId: UUID
    @EnvironmentObject var persistence: PersistenceService
    @EnvironmentObject var router: Router
    @State private var showDeleteConfirmation = false
    
    var commitment: Commitment? {
        persistence.appState.commitments.commitments.first { $0.id == commitmentId }
    }
    
    var category: Category? {
        guard let commitment = commitment else { return nil }
        return persistence.appState.categories.categories.first { $0.id == commitment.categoryId }
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
            
            if let commitment = commitment {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Hero Card with Title and Category
                        heroCard(commitment: commitment)
                        
                        // Quick Stats Grid
                        quickStatsGrid(commitment: commitment)
                        
                        // Detailed Information Card
                        detailedInfoCard(commitment: commitment)
                        
                        // Timeline Section
                        timelineSection(commitment: commitment)
                        
                        // Lifecycle Section
                        lifecycleSection(commitment: commitment)
                        
                        // History Section
                        historySection(commitment: commitment)
                        
                        // Amount History (if applicable)
                        if commitment.amount != nil {
                            amountHistorySection(commitment: commitment)
                        }
                        
                        // Notes Section (if applicable)
                        if let notes = commitment.notes, !notes.isEmpty {
                            notesSection(notes: notes)
                        }
                        
                        // Notes History (if applicable)
                        if commitment.notes != nil {
                            notesHistorySection(commitment: commitment)
                        }
                        
                        // Milestones Section
                        milestonesSection(commitment: commitment)
                        
                        // Relationships Section
                        relationshipsSection(commitment: commitment)
                        
                        // Reflection Section
                        if shouldShowReflection(for: commitment) {
                            reflectionSection(commitment: commitment)
                        }
                        
                        // Projection Section
                        projectionSection(commitment: commitment)
                        
                        // Actions Section
                        actionsSection(commitment: commitment)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            } else {
                Text("Commitment not found")
                    .foregroundColor(.textSecondary)
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
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
                }
            }
            
            Spacer()
            
            Button(action: { 
                if let commitment = commitment {
                    router.push(.editCommitment(id: commitment.id))
                }
            }) {
                Text("Edit")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentBlue, .accentPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
        .safeAreaInset(edge: .top) {
            Color.clear.frame(height: 0)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Hero Card
    private func heroCard(commitment: Commitment) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 16) {
                // Category Badge
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    category?.color.color ?? .gray,
                                    (category?.color.color ?? .gray).opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .shadow(color: (category?.color.color ?? .gray).opacity(0.5), radius: 12, x: 0, y: 6)
                    
                    Image("icon_category_default")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(commitment.title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .lineLimit(3)
                    
                    Text(category?.name ?? "Unknown Category")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    category?.color.color ?? .gray,
                                    (category?.color.color ?? .gray).opacity(0.7)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                Spacer()
            }
            
            // Status Badge
            statusBadge(commitment.status)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
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
                
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                (category?.color.color ?? .gray).opacity(0.4),
                                (category?.color.color ?? .gray).opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            }
        )
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Quick Stats Grid
    private func quickStatsGrid(commitment: Commitment) -> some View {
        VStack(spacing: 12) {
            QuickStatCard(
                icon: "clock.fill",
                title: "Next Occurrence",
                value: commitment.nextOccurrenceDate.formattedRelative(),
                gradient: [.accentBlue, .accentPurple]
            )
            
            QuickStatCard(
                icon: "hourglass",
                title: "Duration",
                value: commitment.activeDurationString,
                gradient: [.accentGreen, .accentBlue]
            )
            
            if let amount = commitment.amount {
                QuickStatCard(
                    icon: "dollarsign.circle.fill",
                    title: "Amount",
                    value: formatAmount(amount, currency: commitment.currency),
                    gradient: [.accentOrange, .accentPink]
                )
            }
            
            QuickStatCard(
                icon: "arrow.triangle.2.circlepath",
                title: "Cycle",
                value: commitment.cycle.displayName,
                gradient: [.accentPurple, .accentPink]
            )
        }
    }
    
    // MARK: - Detailed Info Card
    private func detailedInfoCard(commitment: Commitment) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image("icon_info")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                Text("Details")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
            }
            
            VStack(spacing: 16) {
                DetailRow(label: "Start Date", value: commitment.startDate.formattedShort(), icon: "calendar")
                DetailRow(label: "Status", value: statusString(commitment.status), icon: "circle.fill")
                
                if let amount = commitment.amount {
                    DetailRow(label: "Amount", value: formatAmount(amount, currency: commitment.currency), icon: "dollarsign.circle.fill")
                }
                
                DetailRow(label: "Cycle", value: commitment.cycle.displayName, icon: "arrow.triangle.2.circlepath")
                DetailRow(label: "Next Occurrence", value: commitment.nextOccurrenceDate.formattedRelative(), icon: "clock.fill")
                DetailRow(label: "Active Duration", value: commitment.activeDurationString, icon: "hourglass")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(cardBackground)
        .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
    }
    
    // MARK: - Timeline Section
    private func timelineSection(commitment: Commitment) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image("icon_timeline")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                Text("Status Timeline")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
            }
            
            StatusTimelineView(commitment: commitment)
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(cardBackground)
                .cornerRadius(20)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Lifecycle Section
    private func lifecycleSection(commitment: Commitment) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image("icon_lifecycle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                Text("Lifecycle")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
            }
            
            LifecycleView(commitment: commitment)
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(cardBackground)
                .cornerRadius(20)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - History Section
    private func historySection(commitment: Commitment) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image("icon_history")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                Text("History")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
            }
            
            CommitmentHistoryView(
                commitment: commitment,
                categories: persistence.appState.categories.categories
            )
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(cardBackground)
            .cornerRadius(20)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Projection Section
    private func projectionSection(commitment: Commitment) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image("icon_projection")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                Text("Future Projection")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
            }
            
            CommitmentProjectionView(commitment: commitment)
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(cardBackground)
                .cornerRadius(20)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Amount History Section
    private func amountHistorySection(commitment: Commitment) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image("icon_amount")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                Text("Amount History")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
            }
            
            AmountHistoryView(commitment: commitment)
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(cardBackground)
                .cornerRadius(20)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Notes Section
    private func notesSection(notes: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image("icon_notes")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                Text("Notes")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
            }
            
            Text(notes)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
    }
    
    // MARK: - Notes History Section
    private func notesHistorySection(commitment: Commitment) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "note.text")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentPurple, .accentPink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Notes History")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
            }
            
            NotesHistoryView(commitment: commitment)
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(cardBackground)
                .cornerRadius(20)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Milestones Section
    private func milestonesSection(commitment: Commitment) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image("icon_milestones")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                Text("Milestones")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
            }
            
            MilestonesView(commitment: commitment)
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(cardBackground)
                .cornerRadius(20)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Relationships Section
    private func relationshipsSection(commitment: Commitment) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image("icon_relationships")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                Text("Related Commitments")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
            }
            
            CommitmentRelationshipsView(
                commitment: commitment,
                allCommitments: persistence.appState.commitments.commitments
            )
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(cardBackground)
            .cornerRadius(20)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Reflection Section
    private func reflectionSection(commitment: Commitment) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image("icon_reflection")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                Text("Reflection")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
            }
            
            VStack(spacing: 20) {
                ReflectionSummaryView(commitment: commitment)
                ReflectionHistoryView(commitment: commitment)
                ReflectionChangePointsView(commitment: commitment)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(cardBackground)
            .cornerRadius(20)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Actions Section
    private func actionsSection(commitment: Commitment) -> some View {
        VStack(spacing: 16) {
            if commitment.status.isActive {
                ActionButton(
                    title: "Pause",
                    icon: "pause.circle.fill",
                    gradient: [.accentOrange, .accentOrange.opacity(0.7)]
                ) {
                    pauseCommitment(commitment)
                }
                
                ActionButton(
                    title: "Mark as Ending",
                    icon: "flag.fill",
                    gradient: [.accentPink, .accentPink.opacity(0.7)]
                ) {
                    markAsEnding(commitment)
                }
            } else if commitment.status.isPaused {
                ActionButton(
                    title: "Resume",
                    icon: "play.circle.fill",
                    gradient: [.accentGreen, .accentGreen.opacity(0.7)]
                ) {
                    resumeCommitment(commitment)
                }
            }
            
            if !commitment.status.isActive {
                ActionButton(
                    title: "Archive",
                    icon: "archivebox.fill",
                    gradient: [.gray, .gray.opacity(0.7)],
                    isSecondary: true
                ) {
                    archiveCommitment(commitment)
                }
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Supporting Views
    private var cardBackground: some View {
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
                            (category?.color.color ?? .gray).opacity(0.2),
                            (category?.color.color ?? .gray).opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }
    
    private func statusBadge(_ status: CommitmentStatus) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor(status))
                .frame(width: 10, height: 10)
                .shadow(color: statusColor(status).opacity(0.6), radius: 4, x: 0, y: 0)
            
            Text(statusString(status))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(statusColor(status).opacity(0.15))
        )
    }
    
    private func statusColor(_ status: CommitmentStatus) -> Color {
        switch status {
        case .active: return .accentGreen
        case .paused: return .accentOrange
        case .ending: return .accentPink
        case .archived: return .gray
        }
    }
    
    // MARK: - Helper Functions
    private func shouldShowReflection(for commitment: Commitment) -> Bool {
        guard persistence.appState.preferences.showReflectionPrompts else { return false }
        return commitment.status.isActive || commitment.status.isEnding
    }
    
    private func statusString(_ status: CommitmentStatus) -> String {
        switch status {
        case .active: return "Active"
        case .paused: return "Paused"
        case .ending(let endDate): return "Ending on \(endDate.formattedShort())"
        case .archived: return "Archived"
        }
    }
    
    private func formatAmount(_ amount: Decimal, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency == "Other" ? "" : currency
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount) \(currency)"
    }
    
    private func pauseCommitment(_ commitment: Commitment) {
        guard let index = persistence.appState.commitments.commitments.firstIndex(where: { $0.id == commitment.id }) else { return }
        let oldStatus = persistence.appState.commitments.commitments[index].status
        persistence.appState.commitments.commitments[index].status = .paused(pausedAt: Date())
        persistence.appState.commitments.commitments[index].pausedAt = Date()
        HistoryService.recordStatusChange(&persistence.appState.commitments.commitments[index], from: oldStatus, to: .paused(pausedAt: Date()))
    }
    
    private func resumeCommitment(_ commitment: Commitment) {
        guard let index = persistence.appState.commitments.commitments.firstIndex(where: { $0.id == commitment.id }) else { return }
        let oldStatus = persistence.appState.commitments.commitments[index].status
        let today = Date()
        let nextDate = CommitmentCalculator.computeNextOccurrence(
            from: commitment.startDate,
            cycle: commitment.cycle,
            currentDate: today
        )
        
        if let pausedAt = commitment.pausedAt {
            let pausedDuration = today.timeIntervalSince(pausedAt)
            persistence.appState.commitments.commitments[index].totalPausedSeconds += pausedDuration
        }
        
        persistence.appState.commitments.commitments[index].status = .active
        persistence.appState.commitments.commitments[index].nextOccurrenceDate = nextDate
        persistence.appState.commitments.commitments[index].pausedAt = nil
        HistoryService.recordStatusChange(&persistence.appState.commitments.commitments[index], from: oldStatus, to: .active)
    }
    
    private func markAsEnding(_ commitment: Commitment) {
        let endDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        guard let index = persistence.appState.commitments.commitments.firstIndex(where: { $0.id == commitment.id }) else { return }
        let oldStatus = persistence.appState.commitments.commitments[index].status
        persistence.appState.commitments.commitments[index].status = .ending(endDate: endDate)
        HistoryService.recordStatusChange(&persistence.appState.commitments.commitments[index], from: oldStatus, to: .ending(endDate: endDate))
    }
    
    private func archiveCommitment(_ commitment: Commitment) {
        guard let index = persistence.appState.commitments.commitments.firstIndex(where: { $0.id == commitment.id }) else { return }
        let oldStatus = persistence.appState.commitments.commitments[index].status
        persistence.appState.commitments.commitments[index].status = .archived
        HistoryService.recordStatusChange(&persistence.appState.commitments.commitments[index], from: oldStatus, to: .archived)
        router.pop()
    }
}

// MARK: - Supporting Components
struct QuickStatCard: View {
    let icon: String
    let title: String
    let value: String
    let gradient: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.textSecondary)
                
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                                gradient[0].opacity(0.3),
                                gradient[1].opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var icon: String? = nil
    
    func iconImage(for iconName: String) -> Image {
        switch iconName {
        case "calendar": return Image("icon_calendar_small")
        case "circle.fill": return Image("icon_status_active")
        case "dollarsign.circle.fill": return Image("icon_amount")
        case "arrow.triangle.2.circlepath": return Image("icon_cycle")
        case "clock.fill": return Image("icon_clock")
        case "hourglass": return Image("icon_hourglass")
        default: return Image(systemName: iconName)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                iconImage(for: icon)
                    .frame(width: 24, height: 24)
            }
            
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let gradient: [Color]
    var isSecondary: Bool = false
    let action: () -> Void
    
    func actionIconImage(for iconName: String) -> Image {
        switch iconName {
        case "pause.circle.fill": return Image("icon_pause_action")
        case "play.circle.fill": return Image("icon_resume_action")
        case "archivebox.fill": return Image("icon_archive_action")
        case "flag.fill": return Image("icon_status_ending")
        default: return Image(systemName: iconName)
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                actionIconImage(for: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            .foregroundColor(isSecondary ? .textSecondary : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                Group {
                    if isSecondary {
                        LinearGradient(
                            colors: [
                                Color.cardBackground,
                                Color.cardBackground.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        ZStack {
                            LinearGradient(
                                colors: gradient,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                    }
                }
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSecondary
                            ? AnyShapeStyle(Color.textSecondary.opacity(0.3))
                            : AnyShapeStyle(Color.clear),
                        lineWidth: isSecondary ? 1 : 0
                    )
            )
            .shadow(
                color: isSecondary
                    ? Color.clear
                    : gradient[0].opacity(0.5),
                radius: 16,
                x: 0,
                y: 8
            )
        }
    }
}
