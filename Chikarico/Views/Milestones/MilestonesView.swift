import SwiftUI

struct MilestonesView: View {
    let commitment: Commitment
    @State private var showAddMilestone = false
    
    var milestones: [Milestone] {
        // For now, we'll calculate milestones based on duration
        // In future, this could be stored in commitment model
        calculateMilestones()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Milestones")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button(action: { showAddMilestone = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.accentBlue)
                }
            }
            
            if milestones.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(milestones) { milestone in
                            MilestoneCard(milestone: milestone)
                        }
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
                                Color.accentOrange.opacity(0.3),
                                Color.accentOrange.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .sheet(isPresented: $showAddMilestone) {
            AddMilestoneView(commitment: commitment)
        }
    }
    
    private func calculateMilestones() -> [Milestone] {
        let duration = commitment.activeDuration
        let days = Int(duration / (24 * 3600))
        
        var milestones: [Milestone] = []
        
        // 1 week milestone
        if days >= 7 {
            milestones.append(Milestone(
                title: "1 Week",
                date: Calendar.current.date(byAdding: .day, value: 7, to: commitment.startDate) ?? commitment.startDate,
                achieved: true
            ))
        }
        
        // 1 month milestone
        if days >= 30 {
            milestones.append(Milestone(
                title: "1 Month",
                date: Calendar.current.date(byAdding: .day, value: 30, to: commitment.startDate) ?? commitment.startDate,
                achieved: true
            ))
        }
        
        // 3 months milestone
        if days >= 90 {
            milestones.append(Milestone(
                title: "3 Months",
                date: Calendar.current.date(byAdding: .day, value: 90, to: commitment.startDate) ?? commitment.startDate,
                achieved: true
            ))
        }
        
        // 6 months milestone
        if days >= 180 {
            milestones.append(Milestone(
                title: "6 Months",
                date: Calendar.current.date(byAdding: .day, value: 180, to: commitment.startDate) ?? commitment.startDate,
                achieved: true
            ))
        }
        
        // 1 year milestone
        if days >= 365 {
            milestones.append(Milestone(
                title: "1 Year",
                date: Calendar.current.date(byAdding: .day, value: 365, to: commitment.startDate) ?? commitment.startDate,
                achieved: true
            ))
        }
        
        return milestones.sorted { $0.date < $1.date }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "flag.checkered")
                .font(.system(size: 40))
                .foregroundColor(.textSecondary)
            
            Text("No milestones yet")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct Milestone: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let achieved: Bool
}

struct MilestoneCard: View {
    let milestone: Milestone
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        milestone.achieved
                            ? LinearGradient(colors: [.accentGreen, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.cardBackground, Color.cardBackground.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: milestone.achieved ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(milestone.achieved ? .white : .textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(milestone.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                Text(milestone.date.formattedShort())
                    .font(.system(size: 13))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            if milestone.achieved {
                Text("Achieved")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.accentGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentGreen.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.cardBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

struct AddMilestoneView: View {
    let commitment: Commitment
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var date: Date = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    TextField("Milestone title", text: $title)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Add Milestone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { dismiss() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
