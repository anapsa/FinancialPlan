import SwiftUI
import SwiftData

struct ProgressRing: View {
    var progress: Double
    var tint: Color = Theme.accent
    var lineWidth: CGFloat = 12
    var label: String

    var body: some View {
        ZStack {
            Circle().stroke(tint.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.001, min(progress, 1)))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.6), value: progress)
            VStack(spacing: 2) {
                Text(Format.percent(progress)).font(.title2.bold()).monospacedDigit()
                Text(label).font(.caption).foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(Format.percent(progress)) concluído")
    }
}

struct EnvelopeBar: View {
    var progress: Double
    var tint: Color
    var isOver: Bool

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color(.systemFill))
                Capsule()
                    .fill(isOver ? Color.red : tint)
                    .frame(width: geo.size.width * min(progress, 1))
                    .animation(.easeOut(duration: 0.4), value: progress)
            }
        }
        .frame(height: 8)
    }
}

struct StatCard: View {
    var title: String
    var value: String
    var systemImage: String
    var tint: Color = Theme.accent

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: systemImage)
                .font(.caption).foregroundStyle(.secondary).labelStyle(.titleAndIcon)
            Text(value).font(.title3.bold()).monospacedDigit().foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.regular)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct MemberBadge: View {
    let member: Member
    var size: CGFloat = 28

    var body: some View {
        Circle()
            .fill(Color(hex: member.colorHex))
            .frame(width: size, height: size)
            .overlay(
                Text(String(member.name.prefix(1)))
                    .font(.system(size: size * 0.5, weight: .bold))
                    .foregroundStyle(.white)
            )
    }
}

struct QuickAddExpenseCard: View {
    @Environment(\.modelContext) private var context
    @AppStorage("currentMemberName") private var currentMemberName = "Maria"

    let members: [Member]
    let categories: [BudgetCategory]

    @State private var amount = ""
    @State private var selectedCategory: BudgetCategory?
    @State private var note = ""
    @FocusState private var amountFocused: Bool

    private var parsedAmount: Double? {
        Double(amount.replacingOccurrences(of: ",", with: "."))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.regular) {
            Text("Lançar gasto").font(.headline)

            if !members.isEmpty {
                Picker("Quem pagou?", selection: $currentMemberName) {
                    ForEach(members) { member in
                        Text(member.name).tag(member.name)
                    }
                }
                .pickerStyle(.segmented)
            }

            HStack {
                Text("R$").foregroundStyle(.secondary)
                TextField("0", text: $amount)
                    .keyboardType(.decimalPad)
                    .font(.title2.weight(.semibold).monospacedDigit())
                    .focused($amountFocused)
            }

            Menu {
                ForEach(categories) { category in
                    Button(category.name) { selectedCategory = category }
                }
            } label: {
                HStack {
                    Image(systemName: selectedCategory?.bucket.systemImage ?? "tray")
                    Text(selectedCategory?.name ?? "Escolher categoria")
                        .foregroundStyle(selectedCategory == nil ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down").font(.caption).foregroundStyle(.secondary)
                }
                .padding(12)
                .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 10))
            }

            TextField("Observação (opcional)", text: $note)
                .textFieldStyle(.roundedBorder)

            Button(action: save) {
                Label("Adicionar", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(parsedAmount == nil || selectedCategory == nil)
        }
        .padding(Theme.Spacing.regular)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }

    private func save() {
        guard let value = parsedAmount, let category = selectedCategory else { return }
        let payer = members.first(where: { $0.name == currentMemberName }) ?? members.first
        let transaction = Transaction(amount: value, note: note, date: .now,
                                      payer: payer, category: category)
        context.insert(transaction)
        try? context.save()

        amount = ""
        note = ""
        amountFocused = false
    }
}
