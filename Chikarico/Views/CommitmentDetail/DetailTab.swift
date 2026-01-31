import SwiftUI

enum DetailTab {
    case info
    case history
    case timeline
    case lifecycle
    case projection
    case milestones
    case relationships
    case amountHistory
    case notesHistory
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : .textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isSelected
                    ? LinearGradient(colors: [.accentBlue, .accentPurple], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(12)
        }
    }
}
