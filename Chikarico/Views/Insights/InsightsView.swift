import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var persistence: PersistenceService
    @EnvironmentObject var router: Router
    
    // Cache computed values
    @State private var cachedActiveCommitments: [Commitment] = []
    @State private var cachedAllCommitments: [Commitment] = []
    @State private var cachedArchivedCommitments: [Commitment] = []
    @State private var isDataLoaded = false
    
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
                        Image("icon_back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                    }
                    
                    Spacer()
                    
                    Text("Insights")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.clear)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                if isDataLoaded {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            // Basic Stats
                            InsightCard(
                                title: "Active Commitments",
                                value: "\(activeCommitmentsCount)",
                                icon: "checkmark.circle.fill",
                                color: .accentGreen
                            )
                            
                            if let longest = longestRunningCommitment {
                                InsightCard(
                                    title: "Longest Running",
                                    value: longest.title,
                                    subtitle: longest.activeDurationString,
                                    icon: "clock.fill",
                                    color: .accentBlue
                                )
                            }
                            
                            if endingCommitmentsCount > 0 {
                                InsightCard(
                                    title: "Ending Soon",
                                    value: "\(endingCommitmentsCount)",
                                    icon: "flag.fill",
                                    color: .accentOrange
                                )
                            }
                        
                        // Activity Distribution
                        ActivityDistributionView(commitments: cachedActiveCommitments)
                        
                        // Category Trends
                        CategoryTrendsView(
                            commitments: cachedActiveCommitments,
                            categories: persistence.appState.categories.categories
                        )
                        
                        // Category Breakdown
                        CategoryBreakdownChart(
                            commitments: cachedActiveCommitments,
                            categories: persistence.appState.categories.categories
                        )
                        
                        // Growth Chart
                        CommitmentGrowthChart(commitments: cachedAllCommitments)
                        
                        // Activity Heatmap
                        ActivityHeatmapView(commitments: cachedActiveCommitments)
                        
                        // Duration Stats
                        DurationStatsView(commitments: cachedActiveCommitments)
                        
                        // Archived Insights
                        if !cachedArchivedCommitments.isEmpty {
                            ArchivedInsightsView(archivedCommitments: cachedArchivedCommitments)
                        }
                        
                        // Reflection Trends
                        ReflectionTrendsView(commitments: cachedActiveCommitments)
                        
                        // Future Commitments
                        FutureCommitmentsView(commitments: cachedActiveCommitments)
                        
                        // Seasonal Commitments
                        SeasonalCommitmentsView(commitments: cachedAllCommitments)
                        
                        // Currency Grouping
                        CurrencyGroupingView(commitments: cachedActiveCommitments)
                        
                        // Anniversaries
                        AnniversariesView(commitments: cachedActiveCommitments)
                        
                        // Quiet Highlights
                        QuietHighlightsView(commitments: cachedActiveCommitments)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                } else {
                    // Loading state
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading insights...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 100)
                }
            }
        }
        .onAppear {
            loadCachedData()
        }
        .onChange(of: persistence.appState.commitments.commitments.count) { _ in
            loadCachedData()
        }
    }
    
    private func loadCachedData() {
        // Load data on background thread for better performance
        DispatchQueue.global(qos: .userInitiated).async {
            let all = persistence.appState.commitments.commitments
            let active = all.filter { $0.status.isActive }
            let archived = all.filter { $0.status.isArchived }
            
            DispatchQueue.main.async {
                self.cachedAllCommitments = all
                self.cachedActiveCommitments = active
                self.cachedArchivedCommitments = archived
                self.isDataLoaded = true
            }
        }
    }
    
    private var activeCommitmentsCount: Int {
        cachedActiveCommitments.count
    }
    
    private var longestRunningCommitment: Commitment? {
        cachedActiveCommitments.max(by: { $0.activeDuration < $1.activeDuration })
    }
    
    private var endingCommitmentsCount: Int {
        cachedAllCommitments.filter { $0.status.isEnding }.count
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
                .frame(width: 60, height: 60)
                .background(color.opacity(0.2))
                .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(.textSecondary)
                
                Text(value)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}
