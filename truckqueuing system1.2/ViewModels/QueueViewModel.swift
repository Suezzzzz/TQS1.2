import Foundation

class QueueViewModel: ObservableObject {
    @Published var registrations: [Registration] = []
    @Published var drivers: [Driver] = []
    @Published var vehicles: [Vehicle] = []
    
    // MARK: - Registration Methods
    func registerDriver(name: String, phoneNumber: String, isContinuous: Bool, expectedCheckInTime: Date?) -> Driver {
        let driver = Driver(name: name, 
                          phoneNumber: phoneNumber, 
                          isContinuousDriver: isContinuous, 
                          expectedCheckInTime: expectedCheckInTime)
        drivers.append(driver)
        return driver
    }
    
    func registerVehicle(plateNumber: String, type: VehicleType) -> Vehicle {
        let vehicle = Vehicle(plateNumber: plateNumber, type: type)
        vehicles.append(vehicle)
        return vehicle
    }
    
    func createRegistration(driver: Driver, vehicle: Vehicle) {
        let registration = Registration(
            driver: driver, 
            vehicle: vehicle,
            registrationTime: Date(),
            checkInTime: driver.isContinuousDriver ? nil : Date(),
            expectedCheckInTime: driver.expectedCheckInTime
        )
        registrations.append(registration)
        sortRegistrations()
    }
    
    // MARK: - Check-in Methods
    func checkIn(registration: Registration) {
        if let index = registrations.firstIndex(where: { $0.id == registration.id }) {
            if registration.driver.isContinuousDriver {
                guard let expectedTime = registration.expectedCheckInTime else { return }
                let currentTime = Date()
                let timeWindow: TimeInterval = 30 * 60 // 30分钟窗口期（秒）
                
                let earliestTime = expectedTime.addingTimeInterval(-timeWindow/2)
                let latestTime = expectedTime.addingTimeInterval(timeWindow/2)
                
                guard currentTime >= earliestTime && currentTime <= latestTime else {
                    return
                }
            }
            
            var updatedRegistration = registration
            updatedRegistration.checkInTime = Date()
            registrations[index] = updatedRegistration
            sortRegistrations()
        }
    }
    
    // MARK: - Sorting Methods
    private func sortRegistrations() {
        registrations.sort { reg1, reg2 in
            // 1. 昨日未发车连跑司机（已签到）
            if reg1.driver.isContinuousDriver && !reg1.isDispatched && reg1.checkInTime != nil {
                if !reg2.driver.isContinuousDriver || reg2.isDispatched || reg2.checkInTime == nil {
                    return true
                }
            }
            
            // 2. 昨日未发车非连跑司机
            if !reg1.isDispatched && !reg1.driver.isContinuousDriver {
                if reg2.isDispatched {
                    return true
                }
            }
            
            // 3. 今日未发车连跑司机（已签到）
            if reg1.driver.isContinuousDriver && reg1.checkInTime != nil {
                if !reg2.driver.isContinuousDriver || reg2.checkInTime == nil {
                    return true
                }
            }
            
            // 4. 今日未发车非连跑司机
            return reg1.registrationTime < reg2.registrationTime
        }
    }
    
    // MARK: - Helper Methods
    func canCheckIn(registration: Registration) -> Bool {
        guard registration.driver.isContinuousDriver,
              let expectedTime = registration.expectedCheckInTime else {
            return false
        }
        
        let currentTime = Date()
        let timeWindow: TimeInterval = 30 * 60 // 30分钟窗口期
        let earliestTime = expectedTime.addingTimeInterval(-timeWindow/2)
        let latestTime = expectedTime.addingTimeInterval(timeWindow/2)
        
        return currentTime >= earliestTime && currentTime <= latestTime
    }
} 