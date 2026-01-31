import SwiftUI

struct TemplatesView: View {
    @EnvironmentObject var persistence: PersistenceService
    @EnvironmentObject var router: Router
    @State private var showCreateTemplate = false
    
    var userTemplates: [CommitmentTemplate] {
        persistence.appState.templates.templates.filter { !$0.isSystem }
    }
    
    var systemTemplates: [CommitmentTemplate] {
        persistence.appState.templates.templates.filter { $0.isSystem }
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
                            
                            Image("icon_back")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.textPrimary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("Templates")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.textPrimary, .accentPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("\(persistence.appState.templates.templates.count) template\(persistence.appState.templates.templates.count == 1 ? "" : "s")")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    Button(action: { showCreateTemplate = true }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.accentPurple, .accentPink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 40, height: 40)
                                .shadow(color: .accentPurple.opacity(0.4), radius: 8, x: 0, y: 4)
                            
                            Image("icon_quick_add")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 20)
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // User Templates
                        if !userTemplates.isEmpty {
                            TemplatesSection(
                                title: "My Templates",
                                icon: "person.fill",
                                templates: userTemplates,
                                persistence: persistence,
                                router: router
                            )
                        }
                        
                        // System Templates
                        TemplatesSection(
                            title: "System Templates",
                            icon: "star.fill",
                            templates: systemTemplates,
                            persistence: persistence,
                            router: router
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showCreateTemplate) {
            CreateTemplateView()
        }
    }
}

struct TemplatesSection: View {
    let title: String
    let icon: String
    let templates: [CommitmentTemplate]
    let persistence: PersistenceService
    let router: Router
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                    Image(icon == "person.fill" ? "icon_labels" : "icon_templates")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentPurple, .accentPink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(templates.count)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.cardBackground.opacity(0.5))
                    .cornerRadius(12)
            }
            
            VStack(spacing: 12) {
                ForEach(templates) { template in
                    TemplateCard(template: template, persistence: persistence, router: router)
                }
            }
        }
    }
}

struct TemplateCard: View {
    let template: CommitmentTemplate
    let persistence: PersistenceService
    let router: Router
    
    var category: Category? {
        if let categoryId = template.categoryId {
            return persistence.appState.categories.categories.first { $0.id == categoryId }
        }
        return nil
    }
    
    var body: some View {
        Button(action: {
            useTemplate(template)
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    (category?.color.color ?? .accentBlue).opacity(0.3),
                                    (category?.color.color ?? .accentBlue).opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .shadow(color: (category?.color.color ?? .accentBlue).opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Image("icon_templates")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(category?.color.color ?? .accentBlue)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(template.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                    
                    Text(template.title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                    
                    HStack(spacing: 16) {
                        Label(template.cycle.displayName, systemImage: "arrow.triangle.2.circlepath")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.textSecondary)
                        
                        if template.usageCount > 0 {
                            Label("\(template.usageCount)", systemImage: "chart.bar.fill")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                Image("icon_chevron_right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
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
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    (category?.color.color ?? .accentBlue).opacity(0.3),
                                    (category?.color.color ?? .accentBlue).opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func useTemplate(_ template: CommitmentTemplate) {
        // Open edit view with template data (commitment will be created only on save)
        // Usage count will be updated when user saves the commitment
        router.push(.editCommitment(id: nil, templateId: template.id))
    }
}

struct CreateTemplateView: View {
    @EnvironmentObject var persistence: PersistenceService
    @EnvironmentObject var router: Router
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var title: String = ""
    @State private var selectedCategoryId: UUID?
    @State private var amount: String = ""
    @State private var selectedCurrency: String = "USD"
    @State private var cycle: CommitmentCycle = .monthly
    @State private var notes: String = ""
    
    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !title.trimmingCharacters(in: .whitespaces).isEmpty
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
                            Text("Template Name")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.textSecondary)
                            
                            TextField("Enter template name", text: $name)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Commitment Title")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.textSecondary)
                            
                            TextField("Enter commitment title", text: $title)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category (Optional)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.textSecondary)
                            
                            CategoryPicker(selectedCategoryId: $selectedCategoryId, persistence: persistence)
                        }
                        
                        // Amount
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Amount (Optional)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.textSecondary)
                            
                            HStack {
                                TextField("0.00", text: $amount)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(CustomTextFieldStyle())
                                
                                CurrencyPicker(selectedCurrency: $selectedCurrency)
                            }
                        }
                        
                        // Cycle
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Cycle")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.textSecondary)
                            
                            CyclePicker(selectedCycle: $cycle)
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (Optional)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.textSecondary)
                            
                            TextField("Enter notes", text: $notes, axis: .vertical)
                                .lineLimit(3...6)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTemplate()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private func saveTemplate() {
        let amountValue: Decimal? = amount.isEmpty ? nil : Decimal(string: amount)
        
        let template = CommitmentTemplate(
            name: name,
            title: title,
            categoryId: selectedCategoryId,
            amount: amountValue,
            currency: selectedCurrency,
            cycle: cycle,
            notes: notes.isEmpty ? nil : notes
        )
        
        persistence.appState.templates.templates.append(template)
        dismiss()
    }
}

struct CategoryPicker: View {
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
                            Circle()
                                .fill(category.color.color)
                                .frame(width: 12, height: 12)
                            
                            Text(category.name)
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(selectedCategoryId == category.id ? .white : .textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            selectedCategoryId == category.id
                                ? LinearGradient(colors: [category.color.color, category.color.color.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(colors: [Color.cardBackground], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    selectedCategoryId == category.id
                                        ? Color.clear
                                        : category.color.color.opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct CurrencyPicker: View {
    @Binding var selectedCurrency: String
    
    var currencies = ["USD", "EUR", "GBP", "JPY", "Other"]
    
    var body: some View {
        Picker("", selection: $selectedCurrency) {
            ForEach(currencies, id: \.self) { currency in
                Text(currency).tag(currency)
            }
        }
        .pickerStyle(.menu)
        .frame(width: 100)
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

struct CyclePicker: View {
    @Binding var selectedCycle: CommitmentCycle
    
    var body: some View {
        HStack(spacing: 12) {
            CycleButton(title: "Weekly", cycle: .weekly, selectedCycle: $selectedCycle)
            CycleButton(title: "Monthly", cycle: .monthly, selectedCycle: $selectedCycle)
            CycleButton(title: "Yearly", cycle: .yearly, selectedCycle: $selectedCycle)
        }
    }
}

struct CycleButton: View {
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
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedCycle = cycle
            }
        }) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isSelected ? .white : .textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
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
                                ? Color.clear
                                : Color.textSecondary.opacity(0.2),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: isSelected ? .accentBlue.opacity(0.3) : .clear,
                    radius: isSelected ? 8 : 0,
                    x: 0,
                    y: isSelected ? 4 : 0
                )
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(12)
            .foregroundColor(.textPrimary)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
