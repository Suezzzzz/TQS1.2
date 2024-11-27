import Foundation

enum Route: String, CaseIterable, Codable {
    case CA_PA = "CA-PA"
    case CA_GA = "CA-GA"
    case PA_CA = "PA-CA"
    case GA_CA = "GA-CA"
    
    var transitHours: Int {
        switch self {
        case .CA_PA, .PA_CA:
            return 48
        case .CA_GA, .GA_CA:
            return 36
        }
    }
} 