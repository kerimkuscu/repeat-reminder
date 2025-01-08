import Foundation

enum RepeatOption: Double, CaseIterable {
    case none = 0
    case hourly = 3600
    case daily = 86400
    case monthly = 2592000
    case yearly = 31536000
    
    var title: String {
        switch self {
        case .none: return "Yok"
        case .hourly: return "Her Saat"
        case .daily: return "Her Gün"
        case .monthly: return "Her Ay"
        case .yearly: return "Her Yıl"
        }
    }
} 