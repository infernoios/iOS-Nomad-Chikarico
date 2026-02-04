
import Foundation
import Combine
import SwiftUI

struct HomesView: View {
    @EnvironmentObject var persistence: PersistenceService
    @EnvironmentObject var router: Router
    @StateObject private var viewModel: HomeViewModel
    @State private var showQuickActions = false
    
    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel(persistence: PersistenceService()))
    }
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [Color.gradientStart, Color.gradientEnd, Color.backgroundPrimary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Enhanced Header
                    headerView
                    
                    // Quick Actions Bar
                    quickActionsBar
                    
                    // Main Navigation Grid
                    mainNavigationGrid
                    
                    // Content (Timeline)
                    contentView
                }
            }
            
            // Floating Action Button
            floatingActionButton
        }
        .onAppear {
            viewModel.updatePersistence(persistence)
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Spacer()
            
            // Action buttons
            HStack(spacing: 12) {
                // Search
                IconButton(iconName: "icon_search", gradient: [.accentOrange, .accentPink]) {
                    router.push(.search)
                }
                
                // Sort
                IconButton(iconName: "icon_sort", gradient: [.accentGreen, .accentBlue]) {
                    router.push(.sort)
                }
                
                // Filter
                IconButton(iconName: "icon_filter", gradient: [.accentPurple, .accentPink]) {
                    router.push(.filters)
                }
                
                // Settings
                IconButton(iconName: "icon_settings", gradient: [.gray, .gray.opacity(0.7)]) {
                    router.push(.settings)
                }
            }
        }
        .padding(.horizontal, 20)
        .safeAreaInset(edge: .top) {
            Color.clear.frame(height: 0)
        }
        .padding(.top, 8)
        .padding(.bottom, 20)
    }
    
    // MARK: - Quick Actions Bar
    private var quickActionsBar: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            QuickActionCard(
                iconName: "icon_quick_add",
                title: "Quick Add",
                gradient: [.accentBlue, .accentPurple]
            ) {
                router.push(.quickAdd)
            }
            
            QuickActionCard(
                iconName: "icon_templates",
                title: "Templates",
                gradient: [.accentPurple, .accentPink]
            ) {
                router.push(.templates)
            }
            
            QuickActionCard(
                iconName: "icon_bulk_actions",
                title: "Bulk Actions",
                gradient: [.accentOrange, .accentPink]
            ) {
                router.push(.bulkActions)
            }
            
            QuickActionCard(
                iconName: "icon_anniversaries",
                title: "Anniversaries",
                gradient: [.accentPink, .red]
            ) {
                router.push(.anniversaries)
            }
            
            QuickActionCard(
                iconName: "icon_highlights",
                title: "Highlights",
                gradient: [.accentOrange, .yellow]
            ) {
                router.push(.highlights)
            }
            
            QuickActionCard(
                iconName: "icon_focus",
                title: "Focus",
                gradient: [.accentGreen, .accentBlue]
            ) {
                router.push(.focusPeriods)
            }
            
            QuickActionCard(
                iconName: "icon_labels",
                title: "Labels",
                gradient: [.accentPurple, .accentPink]
            ) {
                router.push(.personalLabels)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    // MARK: - Main Navigation Grid
    private var mainNavigationGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            NavigationMenuCard(
                iconName: "icon_calendar",
                title: "Calendar",
                subtitle: "View by dates",
                gradient: LinearGradient(colors: [.accentBlue, .accentPurple], startPoint: .topLeading, endPoint: .bottomTrailing)
            ) {
                router.push(.calendar)
            }
            
            NavigationMenuCard(
                iconName: "icon_categories",
                title: "Categories",
                subtitle: "Organize",
                gradient: LinearGradient(colors: [.accentPurple, .accentPink], startPoint: .topLeading, endPoint: .bottomTrailing)
            ) {
                router.push(.categories)
            }
            
            NavigationMenuCard(
                iconName: "icon_insights",
                title: "Insights",
                subtitle: "Analytics",
                gradient: LinearGradient(colors: [.accentGreen, .accentBlue], startPoint: .topLeading, endPoint: .bottomTrailing)
            ) {
                router.push(.insights)
            }
            
            NavigationMenuCard(
                iconName: "icon_archived",
                title: "Archived",
                subtitle: "\(archivedCount)",
                gradient: LinearGradient(colors: [.accentOrange, .accentPink], startPoint: .topLeading, endPoint: .bottomTrailing)
            ) {
                router.push(.archived)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    // MARK: - Content
    private var contentView: some View {
        Group {
            if viewModel.timelineGroups.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 24) {
                    ForEach(viewModel.timelineGroups) { group in
                        TimelineGroupView(group: group, router: router, persistence: persistence)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
    }
    
    // MARK: - Floating Action Button
    private var floatingActionButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        router.push(.editCommitment(id: nil))
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.accentBlue, .accentPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 64, height: 64)
                            .shadow(color: .accentBlue.opacity(0.5), radius: 20, x: 0, y: 10)
                        
                        Image("icon_add_floating")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image("icon_calendar_add")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
            
            VStack(spacing: 12) {
                Text("No commitments yet")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Text("Start by adding your first commitment")
                    .font(.system(size: 16))
                    .foregroundColor(.textSecondary)
            }
            
            Button(action: {
                router.push(.editCommitment(id: nil))
            }) {
                HStack(spacing: 12) {
                    Image("icon_quick_add")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("Add Commitment")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.accentBlue, .accentPurple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .accentBlue.opacity(0.4), radius: 16, x: 0, y: 8)
            }
        }
        .frame(minHeight: 400)
        .padding(.vertical, 40)
    }
    
    private var archivedCount: Int {
        persistence.appState.commitments.commitments.filter { $0.status.isArchived }.count
    }
}

// MARK: - Supporting Views
struct IconButton: View {
    let iconName: String
    let gradient: [Color]
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.cardBackground, Color.cardBackground.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.1)) { isPressed = true } }
                .onEnded { _ in withAnimation(.easeInOut(duration: 0.1)) { isPressed = false } }
        )
    }
}

struct QuickActionCard: View {
    let iconName: String
    let title: String
    let gradient: [Color]
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradient.map { $0.opacity(0.2) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
                
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
            }
            .frame(width: 90)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardBackground)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .highPriorityGesture(
            DragGesture(minimumDistance: 10)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.1)) { isPressed = true } }
                .onEnded { _ in withAnimation(.easeInOut(duration: 0.1)) { isPressed = false } }
        )
    }
}

struct NavigationMenuCard: View {
    let iconName: String
    let title: String
    var subtitle: String? = nil
    let gradient: LinearGradient
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(gradient.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .blur(radius: 10)
                    
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                }
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.cardBackground)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(gradient.opacity(0.4), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.1)) { isPressed = true } }
                .onEnded { _ in withAnimation(.easeInOut(duration: 0.1)) { isPressed = false } }
        )
    }
}

struct TimelineGroupView: View {
    let group: TimelineGroup
    let router: Router
    let persistence: PersistenceService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(group.title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.textPrimary, groupTitleColor(group.title)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Spacer()
                
                Text("\(group.commitments.count)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.cardBackground.opacity(0.5))
                    .cornerRadius(12)
            }
            
            VStack(spacing: 12) {
                ForEach(group.commitments) { commitment in
                    CommitmentCard(commitment: commitment, router: router, persistence: persistence)
                }
            }
        }
    }
    
    private func groupTitleColor(_ title: String) -> Color {
        switch title {
        case "Today": return .accentOrange
        case "This Week": return .accentBlue
        case "Next 30 Days": return .accentPurple
        default: return .accentGreen
        }
    }
}

struct CommitmentCard: View {
    let commitment: Commitment
    let router: Router
    let persistence: PersistenceService
    
    var category: Category? {
        persistence.appState.categories.categories.first { $0.id == commitment.categoryId }
    }
    
    var categoryGradient: LinearGradient {
        let color = category?.color.color ?? .gray
        return LinearGradient(
            colors: [color, color.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                router.push(.commitmentDetail(id: commitment.id))
            }
        }) {
            HStack(spacing: 16) {
                // Category color indicator with glow
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(categoryGradient)
                        .frame(width: 4)
                        .shadow(color: (category?.color.color ?? .gray).opacity(0.5), radius: 8, x: 0, y: 0)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(categoryGradient)
                        .frame(width: 4)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(commitment.title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 6) {
                            Image("icon_clock")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                            Text(commitment.nextOccurrenceDate.formattedRelative())
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.textSecondary)
                        }
                        
                        if let amount = commitment.amount {
                            HStack(spacing: 6) {
                                Image("icon_amount")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 12, height: 12)
                                Text(formatAmount(amount, currency: commitment.currency))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.textPrimary)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Status indicator with animation
                statusIndicator
            }
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color.cardBackground, Color.cardBackground.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    (category?.color.color ?? .gray).opacity(0.3),
                                    (category?.color.color ?? .gray).opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
            .shadow(color: (category?.color.color ?? .gray).opacity(0.1), radius: 20, x: 0, y: 0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var statusIndicator: some View {
        ZStack {
            Circle()
                .fill(statusColor.opacity(0.2))
                .frame(width: 12, height: 12)
            
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
        }
        .shadow(color: statusColor.opacity(0.5), radius: 4, x: 0, y: 0)
    }
    
    private var statusColor: Color {
        switch commitment.status {
        case .active: return .accentGreen
        case .paused: return .accentOrange
        case .ending: return .accentPink
        case .archived: return .gray
        }
    }
    
    private func formatAmount(_ amount: Decimal, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency == "Other" ? "" : currency
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount) \(currency)"
    }
}

class HomeViewModel: ObservableObject {
    @Published var timelineGroups: [TimelineGroup] = []
    
    private var cancellables = Set<AnyCancellable>()
    var persistence: PersistenceService
    
    var filter: FilterState {
        get { persistence.appState.filter }
        set { persistence.appState.filter = newValue }
    }
    
    init(persistence: PersistenceService) {
        self.persistence = persistence
        setupObserver()
    }
    
    func updatePersistence(_ newPersistence: PersistenceService) {
        cancellables.removeAll()
        persistence = newPersistence
        setupObserver()
    }
    
    private func setupObserver() {
        persistence.$appState
            .map { [weak self] state in
                self?.buildTimelineGroups(from: state, filter: state.filter, sort: state.sort) ?? []
            }
            .assign(to: &$timelineGroups)
    }
    
    var sort: SortState {
        get { persistence.appState.sort }
        set { persistence.appState.sort = newValue }
    }
    
    private func buildTimelineGroups(from state: AppState, filter: FilterState, sort: SortState) -> [TimelineGroup] {
        let visibleCategories = state.categories.categories.filter { !$0.isHidden }
        let categoryMap = Dictionary(uniqueKeysWithValues: visibleCategories.map { ($0.id, $0) })
        
        var commitments = state.commitments.commitments
            .filter { commitment in
                // Filter out hidden commitments
                if commitment.isHidden { return false }
                // Filter out hidden categories
                if let category = categoryMap[commitment.categoryId], category.isHidden {
                    return false
                }
                // Filter out archived commitments (unless filtered)
                if case .archived = commitment.status {
                    if filter.statuses.isEmpty || !filter.statuses.contains(.archived) {
                        return false
                    }
                }
                // Filter out auto-archivable ending commitments
                if CommitmentCalculator.shouldAutoArchive(commitment) {
                    return false
                }
                return true
            }
        
        // Apply advanced filters
        if filter.isActive {
            commitments = FilterService.filterCommitments(
                commitments,
                with: filter,
                categories: state.categories.categories
            )
        }
        
        // Sort commitments
        commitments = SortService.sortCommitments(
            commitments,
            with: sort,
            categories: state.categories.categories
        )
        
        var groups: [TimelineGroup] = []
        var todayItems: [Commitment] = []
        var thisWeekItems: [Commitment] = []
        var next30DaysItems: [Commitment] = []
        
        for commitment in commitments {
            let date = commitment.nextOccurrenceDate
            if date.isToday() {
                todayItems.append(commitment)
            } else if date.isThisWeek() {
                thisWeekItems.append(commitment)
            } else if date.isInNext30Days() {
                next30DaysItems.append(commitment)
            }
        }
        
        if !todayItems.isEmpty {
            groups.append(TimelineGroup(title: "Today", commitments: todayItems))
        }
        if !thisWeekItems.isEmpty {
            groups.append(TimelineGroup(title: "This Week", commitments: thisWeekItems))
        }
        if !next30DaysItems.isEmpty {
            groups.append(TimelineGroup(title: "Next 30 Days", commitments: next30DaysItems))
        }
        
        return groups
    }
    
    private func statusPriority(_ status: CommitmentStatus) -> Int {
        switch status {
        case .active: return 0
        case .ending: return 1
        case .paused: return 2
        case .archived: return 3
        }
    }
}

struct TimelineGroup: Identifiable {
    var id: String { title }
    let title: String
    let commitments: [Commitment]
}
