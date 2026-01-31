import SwiftUI

struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(category.color.color)
                    .frame(width: 16, height: 16)
                
                Text(category.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? .white : .textPrimary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(categoryButtonBackground)
            .cornerRadius(14)
            .overlay(categoryButtonOverlay)
        }
    }
    
    private var categoryButtonBackground: some View {
        Group {
            if isSelected {
                category.color.color
            } else {
                Color.cardBackground
            }
        }
    }
    
    private var categoryButtonOverlay: some View {
        RoundedRectangle(cornerRadius: 14)
            .stroke(
                isSelected
                    ? AnyShapeStyle(Color.clear)
                    : AnyShapeStyle(LinearGradient(colors: [category.color.color.opacity(0.3)], startPoint: .leading, endPoint: .trailing)),
                lineWidth: 1
            )
    }
}
