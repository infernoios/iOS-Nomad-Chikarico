import SwiftUI

struct CommitmentRelationshipsView: View {
    let commitment: Commitment
    let allCommitments: [Commitment]
    
    var relationships: [Relationship] {
        calculateRelationships()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Relationships")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            if relationships.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(relationships) { relationship in
                            RelationshipCard(relationship: relationship)
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
                                Color.accentPurple.opacity(0.3),
                                Color.accentPurple.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
    }
    
    private func calculateRelationships() -> [Relationship] {
        var relationships: [Relationship] = []
        
        // Same category
        let sameCategory = allCommitments.filter {
            $0.id != commitment.id && $0.categoryId == commitment.categoryId
        }
        
        if !sameCategory.isEmpty {
            relationships.append(Relationship(
                type: .sameCategory,
                commitments: sameCategory,
                description: "\(sameCategory.count) commitment(s) in the same category"
            ))
        }
        
        // Similar cycle
        let similarCycle = allCommitments.filter {
            $0.id != commitment.id && $0.cycle == commitment.cycle
        }
        
        if !similarCycle.isEmpty {
            relationships.append(Relationship(
                type: .similarCycle,
                commitments: similarCycle,
                description: "\(similarCycle.count) commitment(s) with the same cycle"
            ))
        }
        
        // Similar amount
        if let amount = commitment.amount {
            let similarAmount = allCommitments.filter { otherCommitment in
                guard otherCommitment.id != commitment.id,
                      let otherAmount = otherCommitment.amount else {
                    return false
                }
                return abs((otherAmount - amount).doubleValue) < amount.doubleValue * 0.1 // Within 10%
            }
            
            if !similarAmount.isEmpty {
                relationships.append(Relationship(
                    type: .similarAmount,
                    commitments: similarAmount,
                    description: "\(similarAmount.count) commitment(s) with similar amount"
                ))
            }
        }
        
        // Shared tags
        if !commitment.tags.isEmpty {
            let sharedTags = allCommitments.filter {
                $0.id != commitment.id && !Set($0.tags).isDisjoint(with: Set(commitment.tags))
            }
            
            if !sharedTags.isEmpty {
                relationships.append(Relationship(
                    type: .sharedTags,
                    commitments: sharedTags,
                    description: "\(sharedTags.count) commitment(s) with shared tags"
                ))
            }
        }
        
        return relationships
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "link")
                .font(.system(size: 40))
                .foregroundColor(.textSecondary)
            
            Text("No relationships found")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct Relationship: Identifiable {
    let id = UUID()
    let type: RelationshipType
    let commitments: [Commitment]
    let description: String
}

enum RelationshipType {
    case sameCategory
    case similarCycle
    case similarAmount
    case sharedTags
    
    var icon: String {
        switch self {
        case .sameCategory: return "folder.fill"
        case .similarCycle: return "arrow.triangle.2.circlepath"
        case .similarAmount: return "dollarsign.circle.fill"
        case .sharedTags: return "tag.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .sameCategory: return .accentBlue
        case .similarCycle: return .accentPurple
        case .similarAmount: return .accentGreen
        case .sharedTags: return .accentOrange
        }
    }
}

struct RelationshipCard: View {
    let relationship: Relationship
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: relationship.type.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(relationship.type.color)
                
                Text(relationship.description)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)
            }
            
            VStack(spacing: 8) {
                ForEach(relationship.commitments.prefix(5)) { relatedCommitment in
                    HStack {
                        Text(relatedCommitment.title)
                            .font(.system(size: 14))
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                        
                        Text(relatedCommitment.nextOccurrenceDate.formattedRelative())
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.vertical, 4)
                }
                
                if relationship.commitments.count > 5 {
                    Text("+ \(relationship.commitments.count - 5) more")
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                        .padding(.top, 4)
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

extension Decimal {
    var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
}
