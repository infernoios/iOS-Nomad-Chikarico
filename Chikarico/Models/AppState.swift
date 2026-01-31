import Foundation
import Combine

struct CommitmentsState: Codable {
    var commitments: [Commitment] = []
}

struct CategoriesState: Codable {
    var categories: [Category] = []
    
    init() {
        self.categories = Category.systemCategories
    }
}

struct PreferencesState: Codable {
    var onboardingCompleted: Bool = false
    var showReflectionPrompts: Bool = true
    var schemaVersion: Int = 1
}

struct TemplatesState: Codable {
    var templates: [CommitmentTemplate] = []
    
    init() {
        self.templates = CommitmentTemplate.systemTemplates
    }
}

struct FocusPeriodsState: Codable {
    var focusPeriods: [FocusPeriod] = []
}

struct PersonalLabelsState: Codable {
    var labels: [PersonalLabel] = []
}

struct AppState: Codable {
    var commitments: CommitmentsState
    var categories: CategoriesState
    var preferences: PreferencesState
    var filter: FilterState
    var sort: SortState
    var templates: TemplatesState
    var focusPeriods: FocusPeriodsState
    var personalLabels: PersonalLabelsState
    
    init() {
        self.commitments = CommitmentsState()
        self.categories = CategoriesState()
        self.preferences = PreferencesState()
        self.filter = FilterState.empty
        self.sort = SortState.default
        self.templates = TemplatesState()
        self.focusPeriods = FocusPeriodsState()
        self.personalLabels = PersonalLabelsState()
    }
}
