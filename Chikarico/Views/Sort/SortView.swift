import SwiftUI

struct SortView: View {
    @EnvironmentObject var persistence: PersistenceService
    @EnvironmentObject var router: Router
    @Binding var sort: SortState
    @State private var localSort: SortState
    
    init(sort: Binding<SortState>) {
        self._sort = sort
        self._localSort = State(initialValue: sort.wrappedValue)
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
                // Header with SafeArea
                HStack {
                    Button(action: {
                        localSort = sort
                        router.pop()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.textPrimary)
                    }
                    
                    Spacer()
                    
                    Text("Sort")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {
                        localSort = SortState.default
                    }) {
                        Text("Reset")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.accentPink)
                    }
                }
                .padding(.horizontal, 20)
                .safeAreaInset(edge: .top) {
                    Color.clear.frame(height: 0)
                }
                .padding(.top, 8)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Primary Sort
                        SortSection(title: "Primary Sort") {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                SortOptionButton(
                                    title: option.displayName,
                                    isSelected: localSort.primary == option
                                ) {
                                    localSort.primary = option
                                }
                            }
                            
                            // Direction
                            HStack(spacing: 16) {
                                SortDirectionButton(
                                    title: "Ascending",
                                    icon: "arrow.up",
                                    isSelected: localSort.primaryDirection == .ascending
                                ) {
                                    localSort.primaryDirection = .ascending
                                }
                                
                                SortDirectionButton(
                                    title: "Descending",
                                    icon: "arrow.down",
                                    isSelected: localSort.primaryDirection == .descending
                                ) {
                                    localSort.primaryDirection = .descending
                                }
                            }
                        }
                        
                        // Secondary Sort
                        SortSection(title: "Secondary Sort (Optional)") {
                            Button(action: {
                                localSort.secondary = nil
                            }) {
                                HStack {
                                    Text("None")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(localSort.secondary == nil ? .white : .textPrimary)
                                    
                                    Spacer()
                                    
                                    if localSort.secondary == nil {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(16)
                                .background(
                                    localSort.secondary == nil
                                        ? LinearGradient(colors: [.accentBlue, .accentPurple], startPoint: .leading, endPoint: .trailing)
                                        : LinearGradient(colors: [Color.cardBackground], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(12)
                            }
                            
                            ForEach(SortOption.allCases, id: \.self) { option in
                                if option != localSort.primary {
                                    SortOptionButton(
                                        title: option.displayName,
                                        isSelected: localSort.secondary == option
                                    ) {
                                        localSort.secondary = localSort.secondary == option ? nil : option
                                    }
                                }
                            }
                            
                            // Secondary Direction
                            if localSort.secondary != nil {
                                HStack(spacing: 16) {
                                    SortDirectionButton(
                                        title: "Ascending",
                                        icon: "arrow.up",
                                        isSelected: localSort.secondaryDirection == .ascending
                                    ) {
                                        localSort.secondaryDirection = .ascending
                                    }
                                    
                                    SortDirectionButton(
                                        title: "Descending",
                                        icon: "arrow.down",
                                        isSelected: localSort.secondaryDirection == .descending
                                    ) {
                                        localSort.secondaryDirection = .descending
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
                
                // Apply Button
                VStack {
                    Button(action: {
                        sort = localSort
                        router.pop()
                    }) {
                        Text("Apply Sort")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                ZStack {
                                    LinearGradient(
                                        colors: [.accentBlue, .accentPurple],
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

struct SortSection<Content: View>: View {
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

struct SortOptionButton: View {
    let title: String
    let isSelected: Bool
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
                }
            }
            .padding(16)
            .background(
                isSelected
                    ? LinearGradient(colors: [.accentBlue, .accentPurple], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [Color.cardBackground], startPoint: .leading, endPoint: .trailing)
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

struct SortDirectionButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isSelected
                    ? LinearGradient(colors: [.accentGreen, .accentBlue], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [Color.cardBackground], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(12)
        }
    }
}
