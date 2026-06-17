import SwiftUI
import SwiftData

@main
struct PlanoFinanceiroApp: App {

    let container: ModelContainer

    init() {
        let schema = Schema([
            Household.self, Member.self, BudgetCategory.self,
            Transaction.self, Goal.self, Debt.self
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        do {
            container = try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Não foi possível criar o ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .tint(Theme.accent)
        }
        .modelContainer(container)
    }
}
