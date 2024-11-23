import Foundation

struct Registration: Identifiable {
    let id: UUID
    var driver: Driver
    var vehicle: Vehicle
    var registrationTime: Date
    var checkInTime: Date?
    var isDispatched: Bool
    var expectedCheckInTime: Date?
    var isOvertime: Bool {
        guard let expectedTime = expectedCheckInTime,
              let checkIn = checkInTime else { return false }
        return checkIn > expectedTime.addingTimeInterval(30 * 60) // 30分钟超时
    }
    
    init(id: UUID = UUID(), 
         driver: Driver, 
         vehicle: Vehicle, 
         registrationTime: Date = Date(), 
         checkInTime: Date? = nil, 
         isDispatched: Bool = false,
         expectedCheckInTime: Date? = nil) {
        self.id = id
        self.driver = driver
        self.vehicle = vehicle
        self.registrationTime = registrationTime
        self.checkInTime = checkInTime
        self.isDispatched = isDispatched
        self.expectedCheckInTime = expectedCheckInTime
    }
} 