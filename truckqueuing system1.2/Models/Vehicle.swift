import Foundation

enum VehicleType: String, CaseIterable {
    case normal = "普通货车"
    case refrigerated = "冷藏车"
    case dangerous = "危险品车"
}

struct Vehicle: Identifiable {
    let id: UUID
    var plateNumber: String
    var type: VehicleType
    var registrationTime: Date
    
    init(id: UUID = UUID(), plateNumber: String, type: VehicleType, registrationTime: Date = Date()) {
        self.id = id
        self.plateNumber = plateNumber
        self.type = type
        self.registrationTime = registrationTime
    }
} 