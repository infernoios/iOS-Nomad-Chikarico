import SwiftUI

struct EditCommitmentView: View {
    let commitmentId: UUID?
    let templateId: UUID?
    @EnvironmentObject var persistence: PersistenceService
    @EnvironmentObject var router: Router
    
    init(commitmentId: UUID? = nil, templateId: UUID? = nil) {
        self.commitmentId = commitmentId
        self.templateId = templateId
    }
    
    @State private var title: String = ""
    @State private var selectedCategoryId: UUID?
    @State private var amount: String = ""
    @State private var selectedCurrency: String = "USD"
    @State private var cycle: CommitmentCycle = .monthly
    @State private var startDate: Date = Date()
    @State private var notes: String = ""
    @State private var tags: [String] = []
    @State private var customDays: String = "30"
    @State private var showCustomDaysPicker = false
    @State private var showCurrencyPicker = false
    @State private var showCycleVariations = false
    
    // Store original values for history tracking
    @State private var originalTitle: String = ""
    @State private var originalCategoryId: UUID?
    @State private var originalAmount: Decimal?
    @State private var originalCycle: CommitmentCycle = .monthly
    @State private var originalNotes: String?
    
    var isEditing: Bool {
        commitmentId != nil
    }
    
    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Button(action: { router.pop() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.textPrimary)
                        }
                        
                        Spacer()
                        
                        Text(isEditing ? "Edit Commitment" : "New Commitment")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                        
                        Button(action: saveCommitment) {
                            Text("Save")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(canSave ? .blue : .textSecondary)
                        }
                        .disabled(!canSave)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Form
                    VStack(spacing: 20) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.textSecondary)
                            
                            TextField("Enter title", text: $title)
                                .font(.system(size: 17))
                                .foregroundColor(.textPrimary)
                                .padding(16)
                                .background(Color.cardBackground)
                                .cornerRadius(12)
                        }
                        
                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.textSecondary)
                            
                            EditCategoryPicker(selectedCategoryId: $selectedCategoryId, persistence: persistence)
                        }
                        
                        // Amount (Optional)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Amount (Optional)")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.textSecondary)
                            
                            HStack(spacing: 12) {
                                TextField("0.00", text: $amount)
                                    .font(.system(size: 17))
                                    .foregroundColor(.textPrimary)
                                    .keyboardType(.decimalPad)
                                    .padding(16)
                                    .background(Color.cardBackground)
                                    .cornerRadius(12)
                                
                                Button(action: { showCurrencyPicker = true }) {
                                    HStack {
                                        Text(selectedCurrency)
                                            .font(.system(size: 17, weight: .medium))
                                            .foregroundColor(.textPrimary)
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12))
                                            .foregroundColor(.textSecondary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .background(Color.cardBackground)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        // Cycle with Variations
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Cycle")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.textSecondary)
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation {
                                        showCycleVariations.toggle()
                                    }
                                }) {
                                    Text(showCycleVariations ? "Standard" : "Variations")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.accentBlue)
                                }
                            }
                            
                            if showCycleVariations {
                                CycleVariationsView(selectedCycle: $cycle)
                                    .padding(.top, 8)
                            } else {
                                EditCyclePicker(
                                    selectedCycle: $cycle,
                                    customDays: $customDays,
                                    showCustomDaysPicker: $showCustomDaysPicker
                                )
                            }
                        }
                        
                        // Start Date
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
                        
                        // Tags
                        TagManagerView(selectedTags: $tags)
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (Optional)")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.textSecondary)
                            
                            TextEditor(text: $notes)
                                .font(.system(size: 17))
                                .foregroundColor(.textPrimary)
                                .frame(minHeight: 100)
                                .padding(12)
                                .background(Color.cardBackground)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showCurrencyPicker) {
            CurrencyPickerView(selectedCurrency: $selectedCurrency)
        }
        .sheet(isPresented: $showCustomDaysPicker) {
            CustomDaysPickerView(customDays: $customDays, cycle: $cycle)
        }
        .onAppear {
            loadCommitment()
        }
    }
    
    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedCategoryId != nil
    }
    
    private func loadCommitment() {
        // If editing existing commitment
        if let id = commitmentId,
           let commitment = persistence.appState.commitments.commitments.first(where: { $0.id == id }) {
            title = commitment.title
            originalTitle = commitment.title
            selectedCategoryId = commitment.categoryId
            originalCategoryId = commitment.categoryId
            if let amt = commitment.amount {
                amount = String(describing: amt)
                originalAmount = amt
            } else {
                originalAmount = nil
            }
            selectedCurrency = commitment.currency
            cycle = commitment.cycle
            originalCycle = commitment.cycle
            startDate = commitment.startDate
            notes = commitment.notes ?? ""
            originalNotes = commitment.notes
            tags = commitment.tags
            
            if case .custom(let days) = cycle {
                customDays = String(days)
            }
            return
        }
        
        // If creating from template
        if let templateId = templateId,
           let template = persistence.appState.templates.templates.first(where: { $0.id == templateId }) {
            title = template.title
            selectedCategoryId = template.categoryId
            if let amt = template.amount {
                amount = String(describing: amt)
            }
            selectedCurrency = template.currency
            cycle = template.cycle
            notes = template.notes ?? ""
            
            if case .custom(let days) = cycle {
                customDays = String(days)
            }
            return
        }
        
        // New commitment - set defaults
        if let firstCategory = persistence.appState.categories.categories.first(where: { !$0.isHidden }) {
            selectedCategoryId = firstCategory.id
        }
    }
    
    private func saveCommitment() {
        guard let categoryId = selectedCategoryId else { return }
        
        let amountValue: Decimal? = amount.isEmpty ? nil : Decimal(string: amount)
        let nextDate = CommitmentCalculator.computeNextOccurrence(
            from: startDate,
            cycle: cycle,
            currentDate: Date()
        )
        
        if let id = commitmentId,
           let index = persistence.appState.commitments.commitments.firstIndex(where: { $0.id == id }) {
            // Update existing with history tracking
            var commitment = persistence.appState.commitments.commitments[index]
            
            // Track title change
            if commitment.title != title {
                HistoryService.recordTitleChange(&commitment, from: originalTitle, to: title)
                commitment.title = title
            }
            
            // Track category change
            if commitment.categoryId != categoryId {
                let oldCategory = persistence.appState.categories.categories.first { $0.id == originalCategoryId }?.name ?? "Unknown"
                let newCategory = persistence.appState.categories.categories.first { $0.id == categoryId }?.name ?? "Unknown"
                HistoryService.recordCategoryChange(&commitment, from: originalCategoryId ?? UUID(), to: categoryId, oldCategoryName: oldCategory, newCategoryName: newCategory)
                commitment.categoryId = categoryId
            }
            
            // Track amount change
            if commitment.amount != amountValue {
                HistoryService.recordAmountChange(&commitment, from: originalAmount, to: amountValue, currency: selectedCurrency)
                commitment.amount = amountValue
                commitment.currency = selectedCurrency
            }
            
            // Track cycle change
            if commitment.cycle != cycle {
                HistoryService.recordCycleChange(&commitment, from: originalCycle, to: cycle)
                commitment.cycle = cycle
            }
            
            commitment.startDate = startDate
            commitment.nextOccurrenceDate = nextDate
            
            // Track notes change
            let newNotes = notes.isEmpty ? nil : notes
            if commitment.notes != newNotes {
                HistoryService.recordNotesChange(&commitment, from: originalNotes, to: newNotes)
                commitment.notes = newNotes
            }
            
            // Update tags
            commitment.tags = tags
            
            persistence.appState.commitments.commitments[index] = commitment
        } else {
            // Create new
            var newCommitment = Commitment(
                title: title,
                categoryId: categoryId,
                amount: amountValue,
                currency: selectedCurrency,
                cycle: cycle,
                startDate: startDate,
                nextOccurrenceDate: nextDate,
                notes: notes.isEmpty ? nil : notes
            )
            newCommitment.tags = tags
            persistence.appState.commitments.commitments.append(newCommitment)
            
            // If created from template, update usage count
            if let templateId = templateId,
               let index = persistence.appState.templates.templates.firstIndex(where: { $0.id == templateId }) {
                persistence.appState.templates.templates[index].usageCount += 1
            }
        }
        
        router.pop()
    }
}

struct EditCategoryPicker: View {
    @Binding var selectedCategoryId: UUID?
    let persistence: PersistenceService
    
    var visibleCategories: [Category] {
        persistence.appState.categories.categories.filter { !$0.isHidden }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(visibleCategories) { category in
                    Button(action: {
                        selectedCategoryId = category.id
                    }) {
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(category.color.color)
                                .frame(width: 12, height: 12)
                            
                            Text(category.name)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(selectedCategoryId == category.id ? .white : .textPrimary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(selectedCategoryId == category.id ? category.color.color : Color.cardBackground)
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct EditCyclePicker: View {
    @Binding var selectedCycle: CommitmentCycle
    @Binding var customDays: String
    @Binding var showCustomDaysPicker: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                EditCycleButton(title: "Weekly", cycle: .weekly, selectedCycle: $selectedCycle)
                EditCycleButton(title: "Monthly", cycle: .monthly, selectedCycle: $selectedCycle)
                EditCycleButton(title: "Yearly", cycle: .yearly, selectedCycle: $selectedCycle)
            }
            
            Button(action: {
                showCustomDaysPicker = true
            }) {
                HStack {
                    if case .custom(let days) = selectedCycle {
                        Text("Every \(days) days")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.textPrimary)
                    } else {
                        Text("Custom")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                }
                .padding(16)
                .background(Color.cardBackground)
                .cornerRadius(12)
            }
        }
    }
}

struct EditCycleButton: View {
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
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isSelected ? .white : .textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.blue : Color.cardBackground)
                .cornerRadius(12)
        }
    }
}

struct CurrencyPickerView: View {
    @Binding var selectedCurrency: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Constants.supportedCurrencies, id: \.self) { currency in
                    Button(action: {
                        selectedCurrency = currency
                        dismiss()
                    }) {
                        HStack {
                            Text(currency)
                                .foregroundColor(.textPrimary)
                            Spacer()
                            if selectedCurrency == currency {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Currency")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
    }
}

struct CustomDaysPickerView: View {
    @Binding var customDays: String
    @Binding var cycle: CommitmentCycle
    @Environment(\.dismiss) var dismiss
    @State private var days: Int = 30
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Every \(days) days")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.textPrimary)
                    
                    Stepper("", value: $days, in: Constants.customCycleMinDays...Constants.customCycleMaxDays)
                        .labelsHidden()
                }
                .padding(40)
                
                Spacer()
                
                Button(action: {
                    cycle = .custom(intervalDays: days)
                    customDays = String(days)
                    dismiss()
                }) {
                    Text("Done")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.blue)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
            }
            .navigationTitle("Custom Cycle")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if case .custom(let d) = cycle {
                days = d
            } else if let d = Int(customDays) {
                days = d
            }
        }
    }
}
