import Foundation

enum BudgetBucket: String, CaseIterable, Identifiable, Codable {
    case needs     = "Necessidades Fixas"
    case lifestyle = "Lazer e Estilo de Vida"
    case reserve   = "Reserva de Emergência"
    case goals     = "Fundos de Objetivos"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .needs:     return "house.fill"
        case .lifestyle: return "fork.knife"
        case .reserve:   return "shield.lefthalf.filled"
        case .goals:     return "target"
        }
    }
}
