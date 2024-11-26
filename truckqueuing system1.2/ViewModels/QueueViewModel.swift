import Foundation

class QueueViewModel: ObservableObject {
    @Published var registrations: [Registration] = [] {
        didSet {
            saveRegistrations()
        }
    }
    @Published var drivers: [Driver] = [] {
        didSet {
            saveDrivers()
        }
    }
    @Published var vehicles: [Vehicle] = []
    
    init() {
        loadData()
    }
    
    func loadData() {
        // 加载注册记录
        registrations = Registration.loadFromUserDefaults()
        
        // 加载驾驶员信息
        if let savedDrivers = loadDrivers() {
            drivers = savedDrivers
        }
        
        // 更新每个注册记录的驾驶员信息
        for i in 0..<registrations.count {
            registrations[i].loadDriver()
        }
    }
    
    // MARK: - Storage Methods
    private func saveRegistrations() {
        Registration.saveToUserDefaults(registrations)
    }
    
    private func saveDrivers() {
        if let encoded = try? JSONEncoder().encode(drivers) {
            UserDefaults.standard.set(encoded, forKey: "savedDrivers")
        }
    }
    
    private func loadDrivers() -> [Driver]? {
        if let savedData = UserDefaults.standard.data(forKey: "savedDrivers"),
           let drivers = try? JSONDecoder().decode([Driver].self, from: savedData) {
            return drivers
        }
        return nil
    }
    
    // MARK: - Registration Methods
    func registerDriver(name: String, phoneNumber: String, isContinuous: Bool, expectedCheckInTime: Date?) -> Driver {
        let driver = Driver(
            id: UUID().uuidString,
            name: name,
            licenseNumber: UUID().uuidString,
            phoneNumber: phoneNumber,
            isContinuousDriver: isContinuous
        )
        drivers.append(driver)
        return driver
    }
    
    func registerVehicle(plateNumber: String, type: VehicleType) throws -> Vehicle {
        if isVehicleInPenalty(plateNumber) {
            throw RegistrationError.vehicleInPenalty
        }
        
        if isVehicleRegisteredWithin24Hours(plateNumber) {
            throw RegistrationError.vehicleAlreadyRegistered
        }
        
        let vehicle = Vehicle(plateNumber: plateNumber, vehicleType: type)
        vehicles.append(vehicle)
        return vehicle
    }
    
    func createRegistration(driver: Driver, vehicle: Vehicle) {
        let registration = Registration(
            id: UUID().uuidString,
            driverId: driver.id,
            registrationDate: Date(),
            expiryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            driver: driver,
            checkInTime: driver.isContinuousDriver ? nil : Date(),
            expectedCheckInTime: driver.isContinuousDriver ? Date() : nil,
            vehicle: vehicle
        )
        registrations.append(registration)
        sortRegistrations()
    }
    
    // MARK: - Check-in Methods
    func checkIn(registration: Registration) {
        if let index = registrations.firstIndex(where: { $0.id == registration.id }) {
            if let driver = registration.driver, driver.isContinuousDriver {
                guard let expectedTime = registration.expectedCheckInTime else { return }
                let currentTime = Date()
                let timeWindow: TimeInterval = 30 * 60
                
                let earliestTime = expectedTime.addingTimeInterval(-timeWindow/2)
                let latestTime = expectedTime.addingTimeInterval(timeWindow/2)
                
                guard currentTime >= earliestTime && currentTime <= latestTime else {
                    var updatedRegistration = registration
                    updatedRegistration.missedCheckInTime = currentTime
                    registrations[index] = updatedRegistration
                    return
                }
            }
            
            var updatedRegistration = registration
            updatedRegistration.checkIn()
            registrations[index] = updatedRegistration
            sortRegistrations()
        }
    }
    
    // MARK: - Penalty Methods
    private func isVehicleInPenalty(_ plateNumber: String) -> Bool {
        let missedRegistration = registrations.first { registration in
            guard let vehicle = registration.vehicle else { return false }
            return vehicle.plateNumber == plateNumber &&
                   registration.missedCheckInTime != nil &&
                   registration.checkInTime == nil
        }
        
        if let missedReg = missedRegistration,
           let missedTime = missedReg.missedCheckInTime {
            let penaltyEnd = missedTime.addingTimeInterval(12 * 3600)
            return Date() < penaltyEnd
        }
        return false
    }
    
    // MARK: - Sorting Methods
    private func sortRegistrations() {
        let currentDate = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: currentDate)
        
        registrations.sort { reg1, reg2 in
            // 处理超时未签到
            if let time1 = reg1.expectedCheckInTime,
               reg1.checkInTime == nil,
               currentDate > time1.addingTimeInterval(12 * 3600) {
                return false
            }
            if let time2 = reg2.expectedCheckInTime,
               reg2.checkInTime == nil,
               currentDate > time2.addingTimeInterval(12 * 3600) {
                return true
            }
            
            // 获取日期
            let date1 = calendar.startOfDay(for: reg1.registrationDate)
            let date2 = calendar.startOfDay(for: reg2.registrationDate)
            
            // 安全解包driver
            guard let driver1 = reg1.driver, let driver2 = reg2.driver else {
                return reg1.registrationDate < reg2.registrationDate
            }
            
            // 昨日未发车连跑司机（已签到）
            let isYesterday1 = date1 < today && driver1.isContinuousDriver && !reg1.isDispatched && reg1.checkInTime != nil
            let isYesterday2 = date2 < today && driver2.isContinuousDriver && !reg2.isDispatched && reg2.checkInTime != nil
            
            if isYesterday1 != isYesterday2 {
                return isYesterday1
            }
            
            // 昨日未发车非连跑司机
            let isYesterdayNormal1 = date1 < today && !driver1.isContinuousDriver && !reg1.isDispatched
            let isYesterdayNormal2 = date2 < today && !driver2.isContinuousDriver && !reg2.isDispatched
            
            if isYesterdayNormal1 != isYesterdayNormal2 {
                return isYesterdayNormal1
            }
            
            // 今日未发车连跑司机（已签到）
            let isTodayContinuous1 = date1 == today && driver1.isContinuousDriver && !reg1.isDispatched && reg1.checkInTime != nil
            let isTodayContinuous2 = date2 == today && driver2.isContinuousDriver && !reg2.isDispatched && reg2.checkInTime != nil
            
            if isTodayContinuous1 != isTodayContinuous2 {
                return isTodayContinuous1
            }
            
            // 同级排序
            if driver1.isContinuousDriver == driver2.isContinuousDriver {
                if driver1.isContinuousDriver {
                    return (reg1.expectedCheckInTime ?? reg1.registrationDate) < (reg2.expectedCheckInTime ?? reg2.registrationDate)
                } else {
                    return reg1.registrationDate < reg2.registrationDate
                }
            }
            
            return reg1.registrationDate < reg2.registrationDate
        }
    }
    
    // MARK: - Helper Methods
    func canCheckIn(registration: Registration) -> Bool {
        guard let driver = registration.driver,
              driver.isContinuousDriver,
              let expectedTime = registration.expectedCheckInTime else {
            return false
        }
        
        let currentTime = Date()
        let timeWindow: TimeInterval = 30 * 60
        let earliestTime = expectedTime.addingTimeInterval(-timeWindow/2)
        let latestTime = expectedTime.addingTimeInterval(timeWindow/2)
        
        return currentTime >= earliestTime && currentTime <= latestTime
    }
    
    private func isVehicleRegisteredWithin24Hours(_ plateNumber: String) -> Bool {
        let currentDate = Date()
        let twentyFourHoursAgo = currentDate.addingTimeInterval(-24 * 3600)
        
        return registrations.contains { registration in
            guard let vehicle = registration.vehicle else { return false }
            return vehicle.plateNumber == plateNumber &&
                   registration.registrationDate > twentyFourHoursAgo
        }
    }
    
    func dispatchVehicle(registration: Registration, trailerNumber: String) {
        if let index = registrations.firstIndex(where: { $0.id == registration.id }) {
            var updatedRegistration = registration
            updatedRegistration.isDispatched = true
            updatedRegistration.dispatchTime = Date()
            updatedRegistration.trailerNumber = trailerNumber.uppercased().trimmingCharacters(in: .whitespaces)
            registrations[index] = updatedRegistration
            sortRegistrations()
        }
    }
}

enum RegistrationError: Error {
    case vehicleInPenalty
    case vehicleAlreadyRegistered
} 
