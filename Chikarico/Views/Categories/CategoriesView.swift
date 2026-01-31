import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject var persistence: PersistenceService
    @EnvironmentObject var router: Router
    @State private var showAddCategory = false
    @State private var editingCategory: Category?
    
    var visibleCategories: [Category] {
        persistence.appState.categories.categories.filter { !$0.isHidden }
    }
    
    var hiddenCategories: [Category] {
        persistence.appState.categories.categories.filter { $0.isHidden }
    }
    
    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { router.pop() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.textPrimary)
                    }
                    
                    Spacer()
                    
                    Text("Categories")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Button(action: { showAddCategory = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(visibleCategories) { category in
                            CategoryRow(
                                category: category,
                                persistence: persistence,
                                onEdit: { editingCategory = category }
                            )
                        }
                        
                        if !hiddenCategories.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Hidden")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.textSecondary)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 8)
                                
                                ForEach(hiddenCategories) { category in
                                    CategoryRow(
                                        category: category,
                                        persistence: persistence,
                                        onEdit: { editingCategory = category }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showAddCategory) {
            EditCategoryView(category: nil, persistence: persistence)
        }
        .sheet(item: $editingCategory) { category in
            EditCategoryView(category: category, persistence: persistence)
        }
    }
}

struct CategoryRow: View {
    let category: Category
    let persistence: PersistenceService
    let onEdit: () -> Void
    
    var commitmentCount: Int {
        persistence.appState.commitments.commitments.filter { $0.categoryId == category.id }.count
    }
    
    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 8)
                .fill(category.color.color)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                Text("\(commitmentCount) commitment\(commitmentCount == 1 ? "" : "s")")
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            if category.isSystem {
                Text("System")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.cardBackground)
                    .cornerRadius(6)
            } else {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16))
                        .foregroundColor(.textSecondary)
                }
            }
            
            Menu {
                if category.isSystem {
                    Button(action: {
                        toggleCategoryVisibility(category)
                    }) {
                        Label(category.isHidden ? "Show" : "Hide", systemImage: category.isHidden ? "eye" : "eye.slash")
                    }
                } else {
                    Button(action: {
                        toggleCategoryVisibility(category)
                    }) {
                        Label(category.isHidden ? "Show" : "Hide", systemImage: category.isHidden ? "eye" : "eye.slash")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: {
                        deleteCategory(category)
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16))
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    private func toggleCategoryVisibility(_ category: Category) {
        guard let index = persistence.appState.categories.categories.firstIndex(where: { $0.id == category.id }) else { return }
        persistence.appState.categories.categories[index].isHidden.toggle()
    }
    
    private func deleteCategory(_ category: Category) {
        guard let index = persistence.appState.categories.categories.firstIndex(where: { $0.id == category.id }) else { return }
        
        // Move commitments to "Other" category
        if let otherCategory = persistence.appState.categories.categories.first(where: { $0.name == "Other" && $0.isSystem }) {
            for i in persistence.appState.commitments.commitments.indices {
                if persistence.appState.commitments.commitments[i].categoryId == category.id {
                    persistence.appState.commitments.commitments[i].categoryId = otherCategory.id
                }
            }
        }
        
        persistence.appState.categories.categories.remove(at: index)
    }
}

struct EditCategoryView: View {
    let category: Category?
    let persistence: PersistenceService
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var selectedColor: Color = .blue
    
    var isEditing: Bool {
        category != nil
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.textSecondary)
                        
                        TextField("Category name", text: $name)
                            .font(.system(size: 17))
                            .foregroundColor(.textPrimary)
                            .padding(16)
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.textSecondary)
                            .padding(.horizontal, 20)
                        
                        ColorPickerGrid(selectedColor: $selectedColor)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle(isEditing ? "Edit Category" : "New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCategory()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if let category = category {
                name = category.name
                selectedColor = category.color.color
            }
        }
    }
    
    private func saveCategory() {
        let categoryColor = CategoryColor(selectedColor)
        
        if let existingCategory = category,
           let index = persistence.appState.categories.categories.firstIndex(where: { $0.id == existingCategory.id }) {
            persistence.appState.categories.categories[index].name = name
            persistence.appState.categories.categories[index].color = categoryColor
        } else {
            let newCategory = Category(
                name: name,
                color: categoryColor,
                isSystem: false
            )
            persistence.appState.categories.categories.append(newCategory)
        }
        
        dismiss()
    }
}

struct ColorPickerGrid: View {
    @Binding var selectedColor: Color
    
    private let colors: [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal,
        .cyan, .blue, .indigo, .purple, .pink, .brown
    ]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
            ForEach(colors, id: \.self) { color in
                Button(action: {
                    selectedColor = color
                }) {
                    Circle()
                        .fill(color)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(selectedColor == color ? Color.white : Color.clear, lineWidth: 3)
                        )
                }
            }
        }
        .padding(.horizontal, 20)
    }
}
