import SwiftUI

struct RouterView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var persistence: PersistenceService
    
    var body: some View {
        ZStack {
            if let route = router.currentRoute {
                view(for: route)
                    .transition(.opacity)
            } else {
                // Show onboarding or home based on first launch
                if persistence.appState.preferences.onboardingCompleted {
                    HomesView()
                } else {
                    OnboardingView()
                }
            }
        }
        .onAppear {
            if router.navigationStack.isEmpty {
                // Set initial route based on onboarding status
                if persistence.appState.preferences.onboardingCompleted {
                    router.setRoot(.home)
                } else {
                    router.setRoot(.onboarding)
                }
            }
        }
    }
    
    @ViewBuilder
    private func view(for route: Route) -> some View {
        switch route {
        case .splash:
            EmptyView()
        case .onboarding:
            OnboardingView()
        case .home:
            HomesView()
        case .commitmentDetail(let id):
            CommitmentDetailView(commitmentId: id)
        case .editCommitment(let id, let templateId):
            EditCommitmentView(commitmentId: id, templateId: templateId)
        case .quickAdd:
            QuickAddView()
        case .filters:
            FilterViewWrapper()
                .environmentObject(persistence)
                .environmentObject(router)
        case .sort:
            SortViewWrapper()
                .environmentObject(persistence)
                .environmentObject(router)
        case .search:
            SearchView()
        case .templates:
            TemplatesView()
        case .bulkActions:
            BulkActionsView()
        case .anniversaries:
            AnniversariesView(commitments: persistence.appState.commitments.commitments.filter { $0.status.isActive })
        case .highlights:
            QuietHighlightsView(commitments: persistence.appState.commitments.commitments.filter { $0.status.isActive })
        case .focusPeriods:
            FocusPeriodsView()
        case .personalLabels:
            PersonalLabelsView()
        case .calendar:
            CalendarView()
        case .categories:
            CategoriesView()
        case .insights:
            InsightsView()
        case .archived:
            ArchivedView()
        case .settings:
            SettingsView()
        }
    }
}
