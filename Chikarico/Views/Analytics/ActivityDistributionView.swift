import SwiftUI

struct ActivityDistributionView: View {
    let commitments: [Commitment]
    @State private var selectedMonths: Int = 6
    @State private var cachedActivityData: [ActivityDataPoint] = []
    @State private var cachedMonths: Int = 0
    
    var activityData: [ActivityDataPoint] {
        cachedActivityData
    }
    
    var maxCount: Int {
        activityData.map { $0.count }.max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Activity Distribution")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Picker("", selection: $selectedMonths) {
                    Text("3 months").tag(3)
                    Text("6 months").tag(6)
                    Text("12 months").tag(12)
                }
                .pickerStyle(.menu)
            }
            
            if activityData.isEmpty {
                emptyState
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: 4) {
                        ForEach(activityData) { point in
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.accentBlue,
                                                Color.accentPurple
                                            ],
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                    )
                                    .frame(width: 8, height: max(4, CGFloat(point.count) / CGFloat(maxCount) * 120))
                                
                                if point.date.isToday() || Calendar.current.component(.day, from: point.date) == 1 {
                                    Text(dayLabel(for: point.date))
                                        .font(.system(size: 9))
                                        .foregroundColor(.textSecondary)
                                        .frame(width: 20)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                HStack {
                    Text("Max: \(maxCount) commitments")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    Text("Average: \(averageCount)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textSecondary)
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
            loadActivityData()
        }
        .onChange(of: selectedMonths) { _ in
            loadActivityData()
        }
        .onChange(of: commitments.count) { _ in
            loadActivityData()
        }
    }
    
    private func loadActivityData() {
        DispatchQueue.global(qos: .userInitiated).async {
            let data = AnalyticsService.activityDistribution(commitments: commitments, months: selectedMonths)
            DispatchQueue.main.async {
                self.cachedActivityData = data
                self.cachedMonths = selectedMonths
            }
        }
    }
    
    private var averageCount: Int {
        guard !activityData.isEmpty else { return 0 }
        let sum = activityData.reduce(0) { $0 + $1.count }
        return sum / activityData.count
    }
    
    private func dayLabel(for date: Date) -> String {
        let calendar = Calendar.current
        if date.isToday() {
            return "Today"
        } else if calendar.component(.day, from: date) == 1 {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            return formatter.string(from: date)
        }
        return ""
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar")
                .font(.system(size: 40))
                .foregroundColor(.textSecondary)
            
            Text("No activity data")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
