import Foundation

struct CommitmentTemplate: Identifiable, Codable {
    let id: UUID
    var name: String
    var title: String
    var categoryId: UUID?
    var amount: Decimal?
    var currency: String
    var cycle: CommitmentCycle
    var notes: String?
    var isSystem: Bool
    var createdAt: Date
    var usageCount: Int
    
    init(
        id: UUID = UUID(),
        name: String,
        title: String,
        categoryId: UUID? = nil,
        amount: Decimal? = nil,
        currency: String = "USD",
        cycle: CommitmentCycle,
        notes: String? = nil,
        isSystem: Bool = false,
        createdAt: Date = Date(),
        usageCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.title = title
        self.categoryId = categoryId
        self.amount = amount
        self.currency = currency
        self.cycle = cycle
        self.notes = notes
        self.isSystem = isSystem
        self.createdAt = createdAt
        self.usageCount = usageCount
    }
    
    func createCommitment() -> Commitment {
        Commitment(
            title: title,
            categoryId: categoryId ?? UUID(),
            amount: amount,
            currency: currency,
            cycle: cycle,
            startDate: Date(),
            notes: notes
        )
    }
}

extension CommitmentTemplate {
    static var systemTemplates: [CommitmentTemplate] {
        [
            CommitmentTemplate(
                name: "Monthly Subscription",
                title: "Monthly Subscription",
                cycle: .monthly,
                isSystem: true
            ),
            CommitmentTemplate(
                name: "Weekly Activity",
                title: "Weekly Activity",
                cycle: .weekly,
                isSystem: true
            ),
            CommitmentTemplate(
                name: "Annual Payment",
                title: "Annual Payment",
                cycle: .yearly,
                isSystem: true
            )
        ]
    }
}
