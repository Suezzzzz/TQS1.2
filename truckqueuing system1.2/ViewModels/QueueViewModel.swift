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
    @Published var timeSlots: [TimeSlot] = []
    @Published var selectedTimeSlot: TimeSlot?
    @Published var showingSuccessAlert = false
    
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
    
    func createRegistration(driver: Driver, vehicle: Vehicle, timeSlot: TimeSlot? = nil) {
        let registration = Registration(
            id: UUID().uuidString,
            driverId: driver.id,
            registrationDate: Date(),
            expiryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            driver: driver,
            checkInTime: driver.isContinuousDriver ? nil : Date(),
            expectedCheckInTime: timeSlot?.startTime,
            vehicle: vehicle
        )
        registrations.append(registration)
        sortRegistrations()
    }
    
    // MARK: - Check-in Methods
    func checkIn(registration: Registration) {
        if let index = registrations.firstIndex(where: { $0.id == registration.id }) {
            var updatedRegistration = registration
            updatedRegistration.checkInTime = Date()
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
                    // 如果都是连跑司机且都已签到，按签到时间排序
                    if let checkIn1 = reg1.checkInTime, let checkIn2 = reg2.checkInTime {
                        return checkIn1 < checkIn2
                    }
                    // 如果有一个未签到，按预约时间排序
                    return (reg1.expectedCheckInTime ?? reg1.registrationDate) < (reg2.expectedCheckInTime ?? reg2.registrationDate)
                } else {
                    // 非连跑司机按登记时间排序
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
        let calendar = Calendar.current
        
        // 获取预期时间的日期和小时
        let expectedComponents = calendar.dateComponents([.year, .month, .day, .hour], from: expectedTime)
        let currentComponents = calendar.dateComponents([.year, .month, .day, .hour], from: currentTime)
        
        // 检查是否是同一天同一小时
        return expectedComponents.year == currentComponents.year &&
               expectedComponents.month == currentComponents.month &&
               expectedComponents.day == currentComponents.day &&
               expectedComponents.hour == currentComponents.hour
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
    
    func dispatchVehicle(registration: Registration, trailerNumber: String, route: Route) {
        if let index = registrations.firstIndex(where: { $0.id == registration.id }) {
            var updatedRegistration = registration
            updatedRegistration.isDispatched = true
            updatedRegistration.dispatchTime = Date()
            updatedRegistration.trailerNumber = trailerNumber.uppercased().trimmingCharacters(in: .whitespaces)
            updatedRegistration.route = route
            registrations[index] = updatedRegistration
            sortRegistrations()
            showingSuccessAlert = true
        }
    }
    
    // 更新可用时间段
    func updateTimeSlots(for date: Date) {
        timeSlots = TimeSlot.generateAvailableTimeSlots(from: date)
    }
    
    // 在时间段中添加司机
    func registerDriver(_ driver: Driver, for timeSlot: TimeSlot) {
        guard let index = timeSlots.firstIndex(where: { $0.id == timeSlot.id }) else { return }
        timeSlots[index].registeredDrivers.append(driver)
    }
    
    // 司机签到
    func checkIn(driver: Driver, timeSlot: TimeSlot) {
        if let index = drivers.firstIndex(where: { $0.id == driver.id }) {
            var updatedDriver = driver
            updatedDriver.status = .checkedIn
            updatedDriver.checkInTime = Date()
            drivers[index] = updatedDriver
        }
    }
    
    // 发车处理
    func dispatch(driver: Driver, trailerNumber: String) {
        if let index = drivers.firstIndex(where: { $0.id == driver.id }) {
            var updatedDriver = driver
            updatedDriver.status = .dispatched
            updatedDriver.trailerNumber = trailerNumber
            drivers[index] = updatedDriver
            showingSuccessAlert = true
        }
    }
    
    func getTodayCheckInRegistrations() -> [Registration] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return registrations.filter { registration in
            guard let driver = registration.driver,
                  let expectedTime = registration.expectedCheckInTime else {
                return false
            }
            
            let registrationDate = calendar.startOfDay(for: expectedTime)
            return driver.isContinuousDriver &&
                   !registration.isDispatched &&
                   registrationDate == today
        }.sorted { reg1, reg2 in
            // 按时间段排
            guard let time1 = reg1.expectedCheckInTime,
                  let time2 = reg2.expectedCheckInTime else {
                return false
            }
            return time1 < time2
        }
    }
    
    func clearAllData(password: String) -> Bool {
        // 验证密码
        guard password == "jian.pan" else { return false }
        
        // 清除所有数据
        registrations.removeAll()
        drivers.removeAll()
        vehicles.removeAll()
        timeSlots.removeAll()
        
        // 清除 UserDefaults 中的数据
        UserDefaults.standard.removeObject(forKey: "savedRegistrations")
        UserDefaults.standard.removeObject(forKey: "savedDrivers")
        
        return true
    }
    
    func getRegistrationCountForTimeSlot(_ timeSlot: TimeSlot) -> Int {
        registrations.filter { registration in
            guard let expectedTime = registration.expectedCheckInTime else { return false }
            let calendar = Calendar.current
            let expectedHour = calendar.component(.hour, from: expectedTime)
            let slotHour = calendar.component(.hour, from: timeSlot.startTime)
            return expectedHour == slotHour
        }.count
    }
}

enum RegistrationError: Error {
    case vehicleInPenalty
    case vehicleAlreadyRegistered
} 
