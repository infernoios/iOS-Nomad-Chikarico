import Foundation

enum Route: Hashable, Identifiable {
    case splash
    case onboarding
    case home
    case commitmentDetail(id: UUID)
    case editCommitment(id: UUID?, templateId: UUID? = nil)
    case quickAdd
    case filters
    case sort
    case search
    case templates
    case bulkActions
    case anniversaries
    case highlights
    case focusPeriods
    case personalLabels
    case calendar
    case categories
    case insights
    case archived
    case settings
    
    var id: String {
        switch self {
        case .splash: return "splash"
        case .onboarding: return "onboarding"
        case .home: return "home"
        case .commitmentDetail(let id): return "detail-\(id.uuidString)"
        case .editCommitment(let id, let templateId): return "edit-\(id?.uuidString ?? "new")-template-\(templateId?.uuidString ?? "none")"
        case .quickAdd: return "quickAdd"
        case .filters: return "filters"
        case .sort: return "sort"
        case .search: return "search"
        case .templates: return "templates"
        case .bulkActions: return "bulkActions"
        case .anniversaries: return "anniversaries"
        case .highlights: return "highlights"
        case .focusPeriods: return "focusPeriods"
        case .personalLabels: return "personalLabels"
        case .calendar: return "calendar"
        case .categories: return "categories"
        case .insights: return "insights"
        case .archived: return "archived"
        case .settings: return "settings"
        }
    }
}
