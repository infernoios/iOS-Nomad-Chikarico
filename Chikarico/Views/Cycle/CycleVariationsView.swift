import SwiftUI

struct CycleVariationsView: View {
    @EnvironmentObject var persistence: PersistenceService
    @EnvironmentObject var router: Router
    @Binding var selectedCycle: CommitmentCycle
    
    var commonVariations: [CycleVariation] {
        [
            CycleVariation(name: "Every 2 Weeks", cycle: .custom(intervalDays: 14), icon: "calendar"),
            CycleVariation(name: "Every 3 Weeks", cycle: .custom(intervalDays: 21), icon: "calendar"),
            CycleVariation(name: "Bi-Monthly", cycle: .custom(intervalDays: 60), icon: "calendar"),
            CycleVariation(name: "Quarterly", cycle: .custom(intervalDays: 90), icon: "calendar"),
            CycleVariation(name: "Semi-Annual", cycle: .custom(intervalDays: 180), icon: "calendar"),
            CycleVariation(name: "Bi-Annual", cycle: .custom(intervalDays: 182), icon: "calendar"),
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Cycle Variations")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            // Standard cycles
            VStack(alignment: .leading, spacing: 12) {
                Text("Standard")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textSecondary)
                
                HStack(spacing: 12) {
                    CycleVariationButton(
                        title: "Weekly",
                        cycle: .weekly,
                        selectedCycle: $selectedCycle
                    )
                    CycleVariationButton(
                        title: "Monthly",
                        cycle: .monthly,
                        selectedCycle: $selectedCycle
                    )
                    CycleVariationButton(
                        title: "Yearly",
                        cycle: .yearly,
                        selectedCycle: $selectedCycle
                    )
                }
            }
            
            // Common variations
            VStack(alignment: .leading, spacing: 12) {
                Text("Common Variations")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textSecondary)
                
                VStack(spacing: 8) {
                    ForEach(commonVariations) { variation in
                        CycleVariationRow(
                            variation: variation,
                            selectedCycle: $selectedCycle
                        )
                    }
                }
            }
            
            // Custom cycle
            CustomCycleInput(selectedCycle: $selectedCycle)
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
    }
}

struct CycleVariation: Identifiable {
    let id = UUID()
    let name: String
    let cycle: CommitmentCycle
    let icon: String
}

struct CycleVariationButton: View {
    let title: String
    let cycle: CommitmentCycle
    @Binding var selectedCycle: CommitmentCycle
    
    var isSelected: Bool {
        switch (cycle, selectedCycle) {
        case (.weekly, .weekly), (.monthly, .monthly), (.yearly, .yearly):
            return true
        default:
            return false
        }
    }
    
    var body: some View {
        Button(action: {
            selectedCycle = cycle
        }) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : .textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    isSelected
                        ? LinearGradient(colors: [.accentBlue, .accentPurple], startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(colors: [Color.cardBackground], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(12)
        }
    }
}

struct CycleVariationRow: View {
    let variation: CycleVariation
    @Binding var selectedCycle: CommitmentCycle
    
    var isSelected: Bool {
        switch (variation.cycle, selectedCycle) {
        case (.custom(let d1), .custom(let d2)):
            return d1 == d2
        default:
            return false
        }
    }
    
    var body: some View {
        Button(action: {
            selectedCycle = variation.cycle
        }) {
            HStack(spacing: 12) {
                Image(systemName: variation.icon)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? .accentBlue : .textSecondary)
                    .frame(width: 30)
                
                Text(variation.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.accentBlue)
                }
            }
            .padding(14)
            .background(
                isSelected
                    ? LinearGradient(colors: [.accentBlue.opacity(0.2), .accentBlue.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [Color.cardBackground.opacity(0.5)], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.accentBlue.opacity(0.5) : Color.clear,
                        lineWidth: 1
                    )
            )
        }
    }
}

struct CustomCycleInput: View {
    @Binding var selectedCycle: CommitmentCycle
    @State private var customDays: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Custom Cycle")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.textSecondary)
            
            HStack(spacing: 12) {
                TextField("Days", text: $customDays)
                    .keyboardType(.numberPad)
                    .textFieldStyle(CustomTextFieldStyle())
                    .focused($isFocused)
                    .onChange(of: customDays) { newValue in
                        if let days = Int(newValue), days > 0 {
                            selectedCycle = .custom(intervalDays: days)
                        }
                    }
                
                Text("days")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            
            if case .custom(let days) = selectedCycle {
                Text("Every \(days) days")
                    .font(.system(size: 13))
                    .foregroundColor(.accentBlue)
            }
        }
        .padding(16)
        .background(Color.cardBackground.opacity(0.5))
        .cornerRadius(12)
        .onAppear {
            if case .custom(let days) = selectedCycle {
                customDays = String(days)
            }
        }
    }
}
