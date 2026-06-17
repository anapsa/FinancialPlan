import SwiftUI
import SwiftData

struct BudgetView: View {
    @Query(sort: \BudgetCategory.sortIndex) private var categories: [BudgetCategory]
    @Query(sort: \Member.createdAt) private var members: [Member]
    @State private var loggingCategory: BudgetCategory?

    private func categories(in bucket: BudgetBucket) -> [BudgetCategory] {
        categories.filter { $0.bucket == bucket }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(BudgetBucket.allCases) { bucket in
                    let items = categories(in: bucket)
                    if !items.isEmpty {
                        Section {
                            ForEach(items) { category in
                                CategoryRow(category: category) { loggingCategory = category }
                            }
                        } header: {
                            bucketHeader(bucket, items: items)
                        }
                    }
                }
            }
            .navigationTitle("Orçamento")
            .sheet(item: $loggingCategory) { category in
                LogExpenseSheet(category: category, members: members)
                    .presentationDetents([.height(320)])
            }
        }
    }

    private func bucketHeader(_ bucket: BudgetBucket, items: [BudgetCategory]) -> some View {
        let spent = items.reduce(0) { $0 + $1.spent() }
        let limit = items.reduce(0) { $0 + $1.limit }
        return HStack {
            Label(bucket.rawValue, systemImage: bucket.systemImage)
                .foregroundStyle(Theme.color(for: bucket))
            Spacer()
            Text("\(Format.currency(spent)) / \(Format.currency(limit))")
                .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
        }
        .textCase(nil)
    }
}

private struct CategoryRow: View {
    let category: BudgetCategory
    let onLog: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category.name).font(.subheadline.weight(.medium))
                Spacer()
                Text(category.isOverBudget()
                     ? "Estourou \(Format.currency(category.spent() - category.limit))"
                     : "Resta \(Format.currency(category.remaining()))")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(category.isOverBudget() ? .red : .secondary)
            }
            EnvelopeBar(progress: category.progress(),
                        tint: Theme.color(for: category.bucket),
                        isOver: category.isOverBudget())
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing) {
            Button(action: onLog) { Label("Lançar", systemImage: "plus") }
                .tint(Theme.accent)
        }
    }
}

private struct LogExpenseSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @AppStorage("currentMemberName") private var currentMemberName = "Maria"

    let category: BudgetCategory
    let members: [Member]
    @State private var amount = ""

    private var parsedAmount: Double? {
        Double(amount.replacingOccurrences(of: ",", with: "."))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Gasto em \(category.name)") {
                    HStack {
                        Text("R$").foregroundStyle(.secondary)
                        TextField("0", text: $amount).keyboardType(.decimalPad)
                    }
                }
                Section("Quem pagou?") {
                    Picker("Quem pagou?", selection: $currentMemberName) {
                        ForEach(members) { Text($0.name).tag($0.name) }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Novo gasto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") { save() }.disabled(parsedAmount == nil)
                }
            }
        }
    }

    private func save() {
        guard let value = parsedAmount else { return }
        let payer = members.first(where: { $0.name == currentMemberName }) ?? members.first
        context.insert(Transaction(amount: value, date: .now, payer: payer, category: category))
        try? context.save()
        dismiss()
    }
}
