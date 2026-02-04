import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var persistence: PersistenceService
    @EnvironmentObject var router: Router
    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()
    
    private func changeMonth(by months: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: months, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with SafeArea
                HStack {
                    Button(action: { router.pop() }) {
                        Image("icon_back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                    }
                    
                    Spacer()
                    
                    Text("Calendar")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image("icon_back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .opacity(0)
                    }
                }
                .padding(.horizontal, 20)
                .safeAreaInset(edge: .top) {
                    Color.clear.frame(height: 0)
                }
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Calendar
                        CalendarMonthView(
                            month: $currentMonth,
                            commitments: persistence.appState.commitments.commitments,
                            categories: persistence.appState.categories.categories,
                            selectedDate: $selectedDate,
                            router: router
                        )
                        
                        // Selected date commitments section
                        VStack(alignment: .leading, spacing: 12) {
                            Text(selectedDate.formattedShort())
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                            
                            if !commitmentsForSelectedDate.isEmpty {
                                LazyVStack(spacing: 12) {
                                    ForEach(commitmentsForSelectedDate) { commitment in
                                        CommitmentCard(commitment: commitment, router: router, persistence: persistence)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                            } else {
                                // Empty state
                                VStack(spacing: 16) {
                                    Image("icon_empty_search")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .opacity(0.5)
                                    
                                    Text("No commitments on this date")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var commitmentsForSelectedDate: [Commitment] {
        let calendar = Calendar.current
        return persistence.appState.commitments.commitments.filter { commitment in
            guard !commitment.status.isPaused else { return false }
            if case .archived = commitment.status { return false }
            
            let commitmentDate = commitment.nextOccurrenceDate
            return calendar.isDate(commitmentDate, inSameDayAs: selectedDate)
        }
    }
}

struct CalendarMonthView: View {
    @Binding var month: Date
    let commitments: [Commitment]
    let categories: [Category]
    @Binding var selectedDate: Date
    let router: Router
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var daysInMonth: [Date] {
        guard let _ = calendar.dateInterval(of: .month, for: month),
              let firstDay = calendar.dateInterval(of: .month, for: month)?.start else {
            return []
        }
        
        let firstDayWeekday = calendar.component(.weekday, from: firstDay)
        let daysToSubtract = (firstDayWeekday - calendar.firstWeekday + 7) % 7
        
        guard let startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: firstDay) else {
            return []
        }
        
        var days: [Date] = []
        var currentDate = startDate
        
        for _ in 0..<42 {
            days.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return days
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Month header
            HStack {
                Button(action: {
                    if let prevMonth = calendar.date(byAdding: .month, value: -1, to: month) {
                        month = prevMonth
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.textPrimary)
                }
                
                Spacer()
                
                Text(dateFormatter.string(from: month))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button(action: {
                    if let nextMonth = calendar.date(byAdding: .month, value: 1, to: month) {
                        month = nextMonth
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.textPrimary)
                }
            }
            .padding(.horizontal, 20)
            
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { weekday in
                    Text(weekday)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        month: month,
                        commitments: commitments,
                        categories: categories,
                        selectedDate: $selectedDate,
                        router: router
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct CalendarDayView: View {
    let date: Date
    let month: Date
    let commitments: [Commitment]
    let categories: [Category]
    @Binding var selectedDate: Date
    let router: Router
    
    private let calendar = Calendar.current
    
    var isInCurrentMonth: Bool {
        calendar.isDate(date, equalTo: month, toGranularity: .month)
    }
    
    var isSelected: Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    var dayCommitments: [Commitment] {
        commitments.filter { commitment in
            guard !commitment.status.isPaused else { return false }
            if case .archived = commitment.status { return false }
            return calendar.isDate(commitment.nextOccurrenceDate, inSameDayAs: date)
        }
    }
    
    var commitmentDots: [(Color, Int)] {
        var categoryColors: [UUID: Color] = [:]
        for commitment in dayCommitments {
            if let category = categories.first(where: { $0.id == commitment.categoryId }) {
                categoryColors[category.id] = category.color.color
            }
        }
        
        let uniqueColors = Array(Set(categoryColors.values))
        let dots = Array(uniqueColors.prefix(3))
        let remaining = max(0, uniqueColors.count - 3)
        
        return dots.map { ($0, 0) } + (remaining > 0 ? [(Color.gray, remaining)] : [])
    }
    
    var body: some View {
        Button(action: {
            selectedDate = date
        }) {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                    .foregroundColor(
                        isInCurrentMonth
                            ? (isSelected ? .white : (isToday ? .blue : .textPrimary))
                            : .textSecondary.opacity(0.3)
                    )
                
                HStack(spacing: 2) {
                    ForEach(Array(commitmentDots.enumerated()), id: \.offset) { index, dot in
                        if dot.1 == 0 {
                            Circle()
                                .fill(dot.0)
                                .frame(width: 4, height: 4)
                        } else {
                            Text("+\(dot.1)")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                .frame(height: 6)
            }
            .frame(width: 44, height: 60)
            .background(
                isSelected
                    ? Color.blue
                    : (isToday ? Color.blue.opacity(0.2) : Color.clear)
            )
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
