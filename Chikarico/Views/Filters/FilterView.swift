import SwiftUI

struct FilterView: View {
    @EnvironmentObject var persistence: PersistenceService
    @EnvironmentObject var router: Router
    @Binding var filter: FilterState
    @State private var localFilter: FilterState
    
    init(filter: Binding<FilterState>) {
        self._filter = filter
        self._localFilter = State(initialValue: filter.wrappedValue)
    }
    
    var visibleCategories: [Category] {
        persistence.appState.categories.categories.filter { !$0.isHidden }
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
                    Button(action: {
                        localFilter = filter
                        router.pop()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.textPrimary)
                    }
                    
                    Spacer()
                    
                    Text("Filters")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    if localFilter.isActive {
                        Button(action: {
                            localFilter = FilterState.empty
                        }) {
                            Text("Clear")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.accentPink)
                        }
                    } else {
                        Button(action: {}) {
                            Text("Clear")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.clear)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Status Filter
                        FilterSection(title: "Status") {
                            ForEach(CommitmentStatusFilter.allCases, id: \.self) { statusFilter in
                                FilterToggle(
                                    title: statusFilter.displayName,
                                    isSelected: localFilter.statuses.contains(statusFilter)
                                ) {
                                    if localFilter.statuses.contains(statusFilter) {
                                        localFilter.statuses.remove(statusFilter)
                                    } else {
                                        localFilter.statuses.insert(statusFilter)
                                    }
                                }
                            }
                        }
                        
                        // Category Filter
                        FilterSection(title: "Category") {
                            ForEach(visibleCategories) { category in
                                FilterToggle(
                                    title: category.name,
                                    isSelected: localFilter.categoryIds.contains(category.id),
                                    color: category.color.color
                                ) {
                                    if localFilter.categoryIds.contains(category.id) {
                                        localFilter.categoryIds.remove(category.id)
                                    } else {
                                        localFilter.categoryIds.insert(category.id)
                                    }
                                }
                            }
                        }
                        
                        // Cycle Filter
                        FilterSection(title: "Cycle") {
                            ForEach(CommitmentCycleFilter.allCases, id: \.self) { cycleFilter in
                                FilterToggle(
                                    title: cycleFilter.displayName,
                                    isSelected: localFilter.cycles.contains(cycleFilter)
                                ) {
                                    if localFilter.cycles.contains(cycleFilter) {
                                        localFilter.cycles.remove(cycleFilter)
                                    } else {
                                        localFilter.cycles.insert(cycleFilter)
                                    }
                                }
                            }
                        }
                        
                        // Reflection Filter
                        FilterSection(title: "Reflection") {
                            ForEach([ReflectionState.yes, .neutral, .no], id: \.self) { reflection in
                                FilterToggle(
                                    title: reflection.rawValue.capitalized,
                                    isSelected: localFilter.reflectionStates.contains(reflection)
                                ) {
                                    if localFilter.reflectionStates.contains(reflection) {
                                        localFilter.reflectionStates.remove(reflection)
                                    } else {
                                        localFilter.reflectionStates.insert(reflection)
                                    }
                                }
                            }
                        }
                        
                        // Amount Filter
                        FilterSection(title: "Amount") {
                            FilterToggle(
                                title: "With amount",
                                isSelected: localFilter.hasAmount == true
                            ) {
                                localFilter.hasAmount = localFilter.hasAmount == true ? nil : true
                            }
                            
                            FilterToggle(
                                title: "Without amount",
                                isSelected: localFilter.hasAmount == false
                            ) {
                                localFilter.hasAmount = localFilter.hasAmount == false ? nil : false
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
                
                // Apply Button
                VStack {
                    Button(action: {
                        filter = localFilter
                        router.pop()
                    }) {
                        Text("Apply Filters")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                ZStack {
                                    LinearGradient(
                                        colors: localFilter.isActive
                                            ? [.accentBlue, .accentPurple]
                                            : [.gray, .gray],
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
                            )
                            .cornerRadius(16)
                    }
                    .disabled(!localFilter.isActive && !filter.isActive)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .background(
                    LinearGradient(
                        colors: [
                            Color.backgroundPrimary.opacity(0.95),
                            Color.backgroundPrimary
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }
}

struct FilterSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 8) {
                content
            }
        }
    }
}

struct FilterToggle: View {
    let title: String
    let isSelected: Bool
    var color: Color? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : .textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 20))
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(16)
            .background(
                Group {
                    if isSelected {
                        if let color = color {
                            color
                        } else {
                            LinearGradient(colors: [.accentBlue, .accentPurple], startPoint: .leading, endPoint: .trailing)
                        }
                    } else {
                        LinearGradient(colors: [Color.cardBackground], startPoint: .leading, endPoint: .trailing)
                    }
                }
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected
                            ? AnyShapeStyle(Color.clear)
                            : AnyShapeStyle(LinearGradient(colors: [Color.textSecondary.opacity(0.2)], startPoint: .leading, endPoint: .trailing)),
                        lineWidth: 1
                    )
            )
        }
    }
}
