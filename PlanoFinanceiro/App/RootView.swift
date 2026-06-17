import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Visão Geral", systemImage: "square.grid.2x2.fill") }

            BudgetView()
                .tabItem { Label("Orçamento", systemImage: "tray.full.fill") }

            GoalsView()
                .tabItem { Label("Metas", systemImage: "target") }

            // ReserveSimulationView()
            // .tabItem { Label("Simulador", systemImage: "chart.xyaxis.line") }

            MoreView()
                .tabItem { Label("Mais", systemImage: "ellipsis.circle.fill") }
        }
        .task { SampleData.seedIfNeeded(context) }
    }
}
