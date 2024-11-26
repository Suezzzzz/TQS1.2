import Foundation

struct Vehicle: Codable {
    var plateNumber: String
    var trailerNumber: String?
    var vehicleType: VehicleType
    
    init(plateNumber: String, trailerNumber: String? = nil, vehicleType: VehicleType = .normal) {
        self.plateNumber = plateNumber
        self.trailerNumber = trailerNumber
        self.vehicleType = vehicleType
    }
} 