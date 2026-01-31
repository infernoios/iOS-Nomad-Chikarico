import SwiftUI

struct CommitmentGrowthChart: View {
    let commitments: [Commitment]
    @State private var selectedMonths: Int = 12
    @State private var cachedGrowthData: [GrowthDataPoint] = []
    @State private var cachedMonths: Int = 0
    @State private var isDataLoaded = false
    
    var growthData: [GrowthDataPoint] {
        cachedGrowthData
    }
    
    var maxTotal: Int {
        growthData.map { $0.total }.max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Commitment Growth")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Picker("", selection: $selectedMonths) {
                    Text("6 months").tag(6)
                    Text("12 months").tag(12)
                    Text("24 months").tag(24)
                }
                .pickerStyle(.menu)
            }
            
            if growthData.isEmpty {
                emptyState
            } else {
                VStack(spacing: 16) {
                    // Chart
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .bottom, spacing: 12) {
                            ForEach(growthData) { point in
                                VStack(spacing: 8) {
                                    VStack(spacing: 4) {
                                        // Created bar
                                        if point.created > 0 {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [.accentGreen, .green],
                                                        startPoint: .bottom,
                                                        endPoint: .top
                                                    )
                                                )
                                                .frame(
                                                    width: 30,
                                                    height: max(4, CGFloat(point.created) / CGFloat(maxTotal) * 100)
                                                )
                                        }
                                        
                                        // Total bar
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(
                                                LinearGradient(
                                                    colors: [.accentBlue, .accentPurple],
                                                    startPoint: .bottom,
                                                    endPoint: .top
                                                )
                                            )
                                            .frame(
                                                width: 30,
                                                height: max(4, CGFloat(point.total) / CGFloat(maxTotal) * 100)
                                            )
                                        
                                        // Archived bar (negative)
                                        if point.archived > 0 {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [.accentPink, .red],
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                )
                                                .frame(
                                                    width: 30,
                                                    height: max(4, CGFloat(point.archived) / CGFloat(maxTotal) * 100)
                                                )
                                        }
                                    }
                                    
                                    Text(monthLabel(for: point.month))
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.textSecondary)
                                        .frame(width: 40)
                                        .rotationEffect(.degrees(-45))
                                        .offset(y: 20)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Legend
                    HStack(spacing: 20) {
                        LegendItem(color: .accentGreen, label: "Created")
                        LegendItem(color: .accentBlue, label: "Total")
                        LegendItem(color: .accentPink, label: "Archived")
                    }
                }
            }
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
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.accentBlue.opacity(0.3),
                                Color.accentBlue.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .onAppear {
            loadGrowthData()
        }
        .onChange(of: selectedMonths) { _ in
            loadGrowthData()
        }
        .onChange(of: commitments.count) { _ in
            loadGrowthData()
        }
    }
    
    private func loadGrowthData() {
        DispatchQueue.global(qos: .userInitiated).async {
            let data = AnalyticsService.commitmentGrowth(commitments: commitments, months: selectedMonths)
            DispatchQueue.main.async {
                self.cachedGrowthData = data
                self.cachedMonths = selectedMonths
                self.isDataLoaded = true
            }
        }
    }
    
    private func monthLabel(for monthKey: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        if let date = formatter.date(from: monthKey) {
            formatter.dateFormat = "MMM"
            return formatter.string(from: date)
        }
        return monthKey
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundColor(.textSecondary)
            
            Text("No growth data")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.textSecondary)
        }
    }
}
