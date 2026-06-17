import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Ferramentas") {
                    NavigationLink {
                        DebtView()
                    } label: {
                        Label("Calculadora de Dívidas", systemImage: "creditcard")
                    }
                }

                Section("Rituais financeiros") {
                    ForEach(Ritual.all) { ritual in
                        RitualRow(ritual: ritual)
                    }
                }

                Section {
                    ForEach(Bias.all) { bias in
                        BiasRow(bias: bias)
                    }
                } header: {
                    Text("Vieses & estratégias")
                } footer: {
                    Text("Pequenas regras de comportamento sustentam o plano: o orçamento só funciona com revisões constantes a dois.")
                }
            }
            .navigationTitle("Mais")
        }
    }
}

// MARK: - Rituals

private struct Ritual: Identifiable {
    let id = UUID()
    let title: String
    let cadence: String
    let detail: String
    let systemImage: String

    static let all: [Ritual] = [
        .init(title: "Check-in Semanal", cadence: "Toda segunda",
              detail: "Revisar gastos da semana e o saldo dos envelopes.",
              systemImage: "calendar.badge.clock"),
        .init(title: "Balanço Mensal", cadence: "Último dia do mês",
              detail: "Fechar o mês, apurar o saldo real e fazer os aportes.",
              systemImage: "doc.text.magnifyingglass"),
        .init(title: "Revisão Anual", cadence: "Janeiro",
              detail: "Reavaliar metas, rebalancear e atualizar a meta da reserva pela inflação.",
              systemImage: "arrow.triangle.2.circlepath")
    ]
}

private struct RitualRow: View {
    let ritual: Ritual
    var body: some View {
        HStack(spacing: Theme.Spacing.regular) {
            Image(systemName: ritual.systemImage)
                .foregroundStyle(Theme.accent)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(ritual.title).font(.subheadline.weight(.medium))
                Text(ritual.detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(ritual.cadence).font(.caption2).foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Behavioral biases

private struct Bias: Identifiable {
    let id = UUID()
    let name: String
    let strategy: String

    static let all: [Bias] = [
        .init(name: "Viés do presente",
              strategy: "Regra das 48h antes de compras acima de R$ 300."),
        .init(name: "Gasto por impulso",
              strategy: "Envelope esgotado = categoria encerrada no mês."),
        .init(name: "Ilusão de controle dos cartões",
              strategy: "Tratar o cartão como débito; revisar a fatura toda semana."),
        .init(name: "Assimetria de engajamento",
              strategy: "Papéis definidos: Pedro nos investimentos, Maria no orçamento.")
    ]
}

private struct BiasRow: View {
    let bias: Bias
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(bias.name).font(.subheadline.weight(.medium))
            Text(bias.strategy).font(.caption).foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    MoreView()
}
