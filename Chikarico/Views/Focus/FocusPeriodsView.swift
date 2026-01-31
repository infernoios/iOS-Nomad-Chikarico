import SwiftUI

struct FocusPeriodsView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var persistence: PersistenceService
    @State private var showAddPeriod = false
    
    var focusPeriods: [FocusPeriod] {
        persistence.appState.focusPeriods.focusPeriods
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
                        Text("Focus Periods")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.textPrimary, .accentGreen],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("\(focusPeriods.count) period\(focusPeriods.count == 1 ? "" : "s")")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    Button(action: { showAddPeriod = true }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.accentGreen, .accentBlue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 40, height: 40)
                                .shadow(color: .accentGreen.opacity(0.4), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 20)
                
                // Content
                if focusPeriods.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(focusPeriods) { period in
                                FocusPeriodCard(period: period, persistence: persistence)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddPeriod) {
            AddFocusPeriodView()
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.accentGreen.opacity(0.3), .accentBlue.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image(systemName: "target")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentGreen, .accentBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 12) {
                Text("No Focus Periods Yet")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Text("Create periods to focus on specific commitments")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: { showAddPeriod = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    Text("Create Focus Period")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.accentGreen, .accentBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .accentGreen.opacity(0.4), radius: 16, x: 0, y: 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 100)
    }
}

// MARK: - Focus Period Model
struct FocusPeriod: Identifiable, Codable {
    let id = UUID()
    var name: String
    var startDate: Date
    var endDate: Date
    var commitmentIds: [UUID]
    
    var isActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }
}

// MARK: - Focus Period Card
struct FocusPeriodCard: View {
    let period: FocusPeriod
    let persistence: PersistenceService
    @EnvironmentObject var router: Router
    @State private var showDeleteConfirmation = false
    
    var commitments: [Commitment] {
        period.commitmentIds.compactMap { id in
            persistence.appState.commitments.commitments.first { $0.id == id }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(period.name)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                    
                    HStack(spacing: 16) {
                        Label(period.startDate.formattedShort(), systemImage: "calendar")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textSecondary)
                        
                        Text("→")
                            .font(.system(size: 14))
                            .foregroundColor(.textSecondary)
                        
                        Label(period.endDate.formattedShort(), systemImage: "calendar")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
                
                if period.isActive {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.accentGreen)
                            .frame(width: 10, height: 10)
                            .shadow(color: .accentGreen.opacity(0.6), radius: 4, x: 0, y: 0)
                        
                        Text("Active")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.accentGreen)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.accentGreen.opacity(0.15))
                    .cornerRadius(12)
                }
            }
            
            if !commitments.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(commitments.count) commitment\(commitments.count == 1 ? "" : "s")")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.textSecondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(commitments.prefix(5)) { commitment in
                                Button(action: {
                                    router.push(.commitmentDetail(id: commitment.id))
                                }) {
                                    Text(commitment.title)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.textPrimary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.cardBackground.opacity(0.6))
                                        .cornerRadius(8)
                                }
                            }
                            
                            if commitments.count > 5 {
                                Text("+ \(commitments.count - 5) more")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.textSecondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                            }
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
                            colors: period.isActive
                                ? [Color.accentGreen.opacity(0.15), Color.accentGreen.opacity(0.05)]
                                : [Color.cardBackground, Color.cardBackground.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: period.isActive
                                ? [Color.accentGreen.opacity(0.4), Color.accentGreen.opacity(0.2)]
                                : [Color.textSecondary.opacity(0.2), Color.textSecondary.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: period.isActive ? 2 : 1
                    )
            }
        )
        .shadow(
            color: period.isActive
                ? .accentGreen.opacity(0.2)
                : .black.opacity(0.1),
            radius: period.isActive ? 16 : 8,
            x: 0,
            y: period.isActive ? 8 : 4
        )
    }
}

// MARK: - Add Focus Period View
struct AddFocusPeriodView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var persistence: PersistenceService
    @State private var name: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    @State private var selectedCommitmentIds: Set<UUID> = []
    
    var availableCommitments: [Commitment] {
        persistence.appState.commitments.commitments.filter { $0.status.isActive }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Period Name")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.textSecondary)
                            
                            TextField("e.g., Q1 Focus", text: $name)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Dates
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Start Date")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.textSecondary)
                                
                                DatePicker("", selection: $startDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .padding(16)
                                    .background(Color.cardBackground)
                                    .cornerRadius(12)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("End Date")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.textSecondary)
                                
                                DatePicker("", selection: $endDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .padding(16)
                                    .background(Color.cardBackground)
                                    .cornerRadius(12)
                            }
                        }
                        
                        // Commitments
                        if !availableCommitments.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Select Commitments")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.textSecondary)
                                
                                VStack(spacing: 8) {
                                    ForEach(availableCommitments) { commitment in
                                        CommitmentToggleRow(
                                            commitment: commitment,
                                            isSelected: selectedCommitmentIds.contains(commitment.id)
                                        ) {
                                            if selectedCommitmentIds.contains(commitment.id) {
                                                selectedCommitmentIds.remove(commitment.id)
                                            } else {
                                                selectedCommitmentIds.insert(commitment.id)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("New Focus Period")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let period = FocusPeriod(
                            name: name,
                            startDate: startDate,
                            endDate: endDate,
                            commitmentIds: Array(selectedCommitmentIds)
                        )
                        persistence.appState.focusPeriods.focusPeriods.append(period)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || endDate <= startDate)
                }
            }
        }
    }
}

struct CommitmentToggleRow: View {
    let commitment: Commitment
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .accentGreen : .textSecondary)
                
                Text(commitment.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            .padding(16)
            .background(
                isSelected
                    ? Color.accentGreen.opacity(0.1)
                    : Color.cardBackground.opacity(0.5)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.accentGreen.opacity(0.3) : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
