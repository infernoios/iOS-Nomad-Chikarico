import SwiftUI

struct QuickAddView: View {
    @EnvironmentObject var persistence: PersistenceService
    @EnvironmentObject var router: Router
    
    @State private var title: String = ""
    @State private var selectedCategoryId: UUID?
    @State private var showFullForm = false
    @FocusState private var isTitleFocused: Bool
    
    var visibleCategories: [Category] {
        persistence.appState.categories.categories.filter { !$0.isHidden }
    }
    
    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedCategoryId != nil
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
                        Text("Quick Add")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.textPrimary, .accentBlue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Create commitment in seconds")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    Button(action: saveCommitment) {
                        Text("Add")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(
                                canSave
                                    ? LinearGradient(colors: [.accentBlue, .accentPurple], startPoint: .leading, endPoint: .trailing)
                                    : LinearGradient(colors: [.textSecondary], startPoint: .leading, endPoint: .trailing)
                            )
                    }
                    .disabled(!canSave)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Title Field
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image("icon_info")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.accentBlue)
                                
                                Text("Title")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.textSecondary)
                            }
                            
                            TextField("Enter commitment name", text: $title)
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.textPrimary)
                                .padding(20)
                                .background(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.cardBackground)
                                        
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                isTitleFocused
                                                    ? LinearGradient(colors: [.accentBlue, .accentPurple], startPoint: .leading, endPoint: .trailing)
                                                    : LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing),
                                                lineWidth: isTitleFocused ? 2 : 0
                                            )
                                    }
                                )
                                .focused($isTitleFocused)
                                .shadow(color: isTitleFocused ? .accentBlue.opacity(0.2) : .black.opacity(0.1), radius: isTitleFocused ? 12 : 8, x: 0, y: 4)
                        }
                        
                        // Category Picker
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image("icon_categories")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                
                                Text("Category")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.textSecondary)
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(visibleCategories) { category in
                                        CategoryButton(
                                            category: category,
                                            isSelected: selectedCategoryId == category.id
                                        ) {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedCategoryId = category.id
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                        
                        // Info Section
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Image("icon_info")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                                    .font(.system(size: 18))
                                    .foregroundColor(.accentBlue)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Quick defaults")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.textPrimary)
                                    
                                    Text("Monthly cycle, today's date")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.textSecondary)
                                }
                                
                                Spacer()
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.accentBlue.opacity(0.1))
                            )
                            
                            Button(action: {
                                showFullForm = true
                            }) {
                                HStack(spacing: 12) {
                                    Image("icon_settings")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16, height: 16)
                                    
                                    Text("Need more options?")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    
                                    Spacer()
                                    
                                    Image("icon_chevron_right")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 14, height: 14)
                                }
                                .foregroundColor(.white)
                                .padding(18)
                                .background(
                                    LinearGradient(
                                        colors: [.accentBlue, .accentPurple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: .accentBlue.opacity(0.4), radius: 12, x: 0, y: 6)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showFullForm) {
            EditCommitmentView(commitmentId: nil)
        }
        .onAppear {
            // Set default category if none selected
            if selectedCategoryId == nil,
               let firstCategory = visibleCategories.first {
                selectedCategoryId = firstCategory.id
            }
            
            // Auto-focus title field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isTitleFocused = true
            }
        }
    }
    
    private func saveCommitment() {
        guard let categoryId = selectedCategoryId else { return }
        
        let today = Date()
        let nextDate = CommitmentCalculator.computeNextOccurrence(
            from: today,
            cycle: .monthly,
            currentDate: today
        )
        
        let newCommitment = Commitment(
            title: title.trimmingCharacters(in: .whitespaces),
            categoryId: categoryId,
            cycle: .monthly,
            startDate: today,
            nextOccurrenceDate: nextDate
        )
        
        persistence.appState.commitments.commitments.append(newCommitment)
        router.pop()
    }
}
