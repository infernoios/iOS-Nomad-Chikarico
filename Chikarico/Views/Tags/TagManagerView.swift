import SwiftUI

struct TagManagerView: View {
    @EnvironmentObject var persistence: PersistenceService
    @Binding var selectedTags: [String]
    @State private var newTag: String = ""
    @FocusState private var isTagFieldFocused: Bool
    
    var allTags: [String] {
        Array(Set(persistence.appState.commitments.commitments.flatMap { $0.tags })).sorted()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tags")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            // Selected tags
            if !selectedTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedTags, id: \.self) { tag in
                            SelectedTagChip(tag: tag) {
                                selectedTags.removeAll { $0 == tag }
                            }
                        }
                    }
                }
            }
            
            // Add new tag
            HStack(spacing: 8) {
                TextField("Add tag", text: $newTag)
                    .textFieldStyle(CustomTextFieldStyle())
                    .focused($isTagFieldFocused)
                    .onSubmit {
                        addTag()
                    }
                
                Button(action: addTag) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.accentBlue)
                }
                .disabled(newTag.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            
            // Available tags
            if !allTags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Available Tags")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.textSecondary)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(allTags, id: \.self) { tag in
                            if !selectedTags.contains(tag) {
                                AvailableTagChip(tag: tag) {
                                    if !selectedTags.contains(tag) {
                                        selectedTags.append(tag)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground.opacity(0.5))
        .cornerRadius(12)
    }
    
    private func addTag() {
        let trimmed = newTag.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !selectedTags.contains(trimmed) {
            selectedTags.append(trimmed)
            newTag = ""
            isTagFieldFocused = false
        }
    }
}

struct SelectedTagChip: View {
    let tag: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(tag)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [.accentBlue, .accentPurple],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
    }
}

struct AvailableTagChip: View {
    let tag: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(tag)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.cardBackground)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.textSecondary.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}
