import Foundation

struct Driver: Identifiable {
    let id: UUID
    var name: String
    var phoneNumber: String
    var isContinuousDriver: Bool
    var expectedCheckInTime: Date?
    
    init(id: UUID = UUID(), name: String, phoneNumber: String, isContinuousDriver: Bool = false, expectedCheckInTime: Date? = nil) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.isContinuousDriver = isContinuousDriver
        self.expectedCheckInTime = expectedCheckInTime
    }
} 