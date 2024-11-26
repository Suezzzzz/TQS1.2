import Foundation

enum VehicleType: String, Codable, CaseIterable {
    case normal = "普通"
    case continuous = "连跑"
    
    var description: String {
        return self.rawValue
    }
} 