import SwiftUI

struct AnniversariesView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var persistence: PersistenceService
    let commitments: [Commitment]
    
    var allAnniversaries: [Anniversary] {
        calculateAllAnniversaries()
    }
    
    var groupedAnniversaries: [String: [Anniversary]] {
        Dictionary(grouping: allAnniversaries) { anniversary in
            if anniversary.daysUntil == 0 {
                return "Today"
            } else if anniversary.daysUntil < 0 {
                return "Recent"
            } else if anniversary.daysUntil <= 7 {
                return "This Week"
            } else if anniversary.daysUntil <= 30 {
                return "This Month"
            } else {
                return "Upcoming"
            }
        }
    }
    
    var sortedGroups: [(String, [Anniversary])] {
        let order = ["Today", "This Week", "This Month", "Upcoming", "Recent"]
        return groupedAnniversaries.sorted { first, second in
            let firstIndex = order.firstIndex(of: first.key) ?? Int.max
            let secondIndex = order.firstIndex(of: second.key) ?? Int.max
            return firstIndex < secondIndex
        }
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
                        Text("Anniversaries")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.textPrimary, .accentPink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("\(allAnniversaries.count) milestone\(allAnniversaries.count == 1 ? "" : "s")")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Spacer for symmetry
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 20)
                
                // Content
                if allAnniversaries.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            ForEach(sortedGroups, id: \.0) { group, anniversaries in
                                AnniversaryGroupView(
                                    title: group,
                                    anniversaries: anniversaries.sorted { $0.daysUntil < $1.daysUntil }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.accentPink.opacity(0.3), .accentPink.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image(systemName: "gift.fill")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentPink, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 12) {
                Text("No Anniversaries Yet")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Text("Your commitment anniversaries will appear here")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 100)
    }
    
    // MARK: - Calculation
    private func calculateAllAnniversaries() -> [Anniversary] {
        let calendar = Calendar.current
        let today = Date()
        var anniversaries: [Anniversary] = []
        
        for commitment in commitments where commitment.status.isActive || commitment.status.isEnding {
            let startDate = commitment.startDate
            let yearsSinceStart = calendar.dateComponents([.year], from: startDate, to: today).year ?? 0
            
            // Calculate past anniversaries (last 30 days)
            // Only check past anniversaries if commitment has been active for at least 1 year
            if yearsSinceStart >= 1 {
                let minYear = max(1, yearsSinceStart - 1)
                let maxYear = yearsSinceStart
                for i in minYear...maxYear {
                    if let pastAnniversary = calendar.date(byAdding: .year, value: i, to: startDate) {
                        let daysSince = calendar.dateComponents([.day], from: pastAnniversary, to: today).day ?? 0
                        if daysSince >= 0 && daysSince <= 30 {
                            anniversaries.append(Anniversary(
                                commitment: commitment,
                                anniversaryDate: pastAnniversary,
                                years: i,
                                daysUntil: -daysSince
                            ))
                        }
                    }
                }
            }
            
            // Calculate upcoming anniversaries (next 90 days)
            for i in (yearsSinceStart + 1)...(yearsSinceStart + 2) {
                if let nextAnniversary = calendar.date(byAdding: .year, value: i, to: startDate) {
                    let daysUntil = calendar.dateComponents([.day], from: today, to: nextAnniversary).day ?? 0
                    if daysUntil >= 0 && daysUntil <= 90 {
                        anniversaries.append(Anniversary(
                            commitment: commitment,
                            anniversaryDate: nextAnniversary,
                            years: i,
                            daysUntil: daysUntil
                        ))
                    }
                }
            }
        }
        
        return anniversaries
    }
}

// MARK: - Anniversary Model
struct Anniversary: Identifiable {
    let id = UUID()
    let commitment: Commitment
    let anniversaryDate: Date
    let years: Int
    let daysUntil: Int // Negative for past, positive for future
}

// MARK: - Anniversary Group View
struct AnniversaryGroupView: View {
    let title: String
    let anniversaries: [Anniversary]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(groupGradient)
                    .frame(width: 4, height: 24)
                
                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(groupGradient)
                
                Spacer()
                
                Text("\(anniversaries.count)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.cardBackground.opacity(0.5))
                    .cornerRadius(12)
            }
            
            VStack(spacing: 12) {
                ForEach(anniversaries) { anniversary in
                    AnniversaryCard(anniversary: anniversary)
                }
            }
        }
    }
    
    private var groupGradient: LinearGradient {
        switch title {
        case "Today":
            return LinearGradient(colors: [.accentPink, .red], startPoint: .leading, endPoint: .trailing)
        case "This Week":
            return LinearGradient(colors: [.accentOrange, .accentPink], startPoint: .leading, endPoint: .trailing)
        case "This Month":
            return LinearGradient(colors: [.accentPurple, .accentPink], startPoint: .leading, endPoint: .trailing)
        case "Upcoming":
            return LinearGradient(colors: [.accentBlue, .accentPurple], startPoint: .leading, endPoint: .trailing)
        default:
            return LinearGradient(colors: [.gray, .gray.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
        }
    }
}

// MARK: - Anniversary Card
struct AnniversaryCard: View {
    let anniversary: Anniversary
    @EnvironmentObject var router: Router
    @EnvironmentObject var persistence: PersistenceService
    
    var category: Category? {
        persistence.appState.categories.categories.first { $0.id == anniversary.commitment.categoryId }
    }
    
    var isToday: Bool {
        anniversary.daysUntil == 0
    }
    
    var isPast: Bool {
        anniversary.daysUntil < 0
    }
    
    var body: some View {
        Button(action: {
            router.push(.commitmentDetail(id: anniversary.commitment.id))
        }) {
            HStack(spacing: 16) {
                // Years Badge
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: isToday
                                    ? [.accentPink, .red]
                                    : isPast
                                        ? [.gray.opacity(0.3), .gray.opacity(0.2)]
                                        : [.accentPink.opacity(0.3), .accentPink.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .shadow(
                            color: isToday
                                ? .accentPink.opacity(0.5)
                                : .clear,
                            radius: isToday ? 12 : 0,
                            x: 0,
                            y: isToday ? 6 : 0
                        )
                    
                    VStack(spacing: 2) {
                        Text("\(anniversary.years)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(isToday ? .white : (isPast ? .textSecondary : .accentPink))
                        
                        Text("year\(anniversary.years == 1 ? "" : "s")")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(isToday ? .white.opacity(0.9) : (isPast ? .textSecondary.opacity(0.7) : .accentPink.opacity(0.8)))
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(anniversary.commitment.title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        // Category badge
                        if let category = category {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(category.color.color)
                                    .frame(width: 8, height: 8)
                                
                                Text(category.name)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Date info
                        HStack(spacing: 6) {
                            Image(systemName: isPast ? "clock.arrow.circlepath" : "calendar")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(isToday ? .accentPink : .textSecondary)
                            
                            Text(dateString)
                                .font(.system(size: 14, weight: isToday ? .bold : .semibold))
                                .foregroundColor(isToday ? .accentPink : .textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textSecondary.opacity(0.5))
            }
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
                    
                    if isToday {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [.accentPink, .accentPink.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    } else if let category = category {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        category.color.color.opacity(0.3),
                                        category.color.color.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                }
            )
            .shadow(
                color: isToday
                    ? .accentPink.opacity(0.3)
                    : .black.opacity(0.1),
                radius: isToday ? 16 : 8,
                x: 0,
                y: isToday ? 8 : 4
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var dateString: String {
        if isToday {
            return "Today!"
        } else if anniversary.daysUntil == 1 {
            return "Tomorrow"
        } else if anniversary.daysUntil == -1 {
            return "Yesterday"
        } else if anniversary.daysUntil > 0 {
            return "In \(anniversary.daysUntil) days"
        } else {
            return "\(abs(anniversary.daysUntil)) days ago"
        }
    }
}
