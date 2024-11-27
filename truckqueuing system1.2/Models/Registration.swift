import Foundation

struct Registration: Codable, Identifiable {
    let id: String
    var driverId: String
    var registrationDate: Date
    var expiryDate: Date
    var driver: Driver?
    var checkInTime: Date?
    var expectedCheckInTime: Date?
    var vehicle: Vehicle?
    var status: RegistrationStatus
    var missedCheckInTime: Date?
    var isDispatched: Bool
    var dispatchTime: Date?
    var trailerNumber: String?
    var route: Route?
    
    var estimatedArrivalTime: Date? {
        guard let dispatchTime = dispatchTime,
              let route = route else { return nil }
        return Calendar.current.date(byAdding: .hour, value: route.transitHours, to: dispatchTime)
    }
    
    enum RegistrationStatus: String, Codable {
        case pending = "待签到"
        case checkedIn = "已签到"
        case completed = "已完成"
        case expired = "已过期"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case driverId
        case registrationDate
        case expiryDate
        case driver
        case checkInTime
        case expectedCheckInTime
        case vehicle
        case status
        case missedCheckInTime
        case isDispatched
        case dispatchTime
        case trailerNumber
        case route
    }
    
    init(id: String = UUID().uuidString,
         driverId: String,
         registrationDate: Date,
         expiryDate: Date,
         driver: Driver? = nil,
         checkInTime: Date? = nil,
         expectedCheckInTime: Date? = nil,
         vehicle: Vehicle? = nil,
         status: RegistrationStatus = .pending,
         missedCheckInTime: Date? = nil,
         isDispatched: Bool = false,
         dispatchTime: Date? = nil,
         trailerNumber: String? = nil,
         route: Route? = nil) {
        
        self.id = id
        self.driverId = driverId
        self.registrationDate = registrationDate
        self.expiryDate = expiryDate
        self.driver = driver
        self.checkInTime = checkInTime
        self.expectedCheckInTime = expectedCheckInTime
        self.vehicle = vehicle
        self.status = status
        self.missedCheckInTime = missedCheckInTime
        self.isDispatched = isDispatched
        self.dispatchTime = dispatchTime
        self.trailerNumber = trailerNumber
        self.route = route
    }
    
    // 添加用于UserDefaults存储的方法
    static func saveToUserDefaults(_ registrations: [Registration]) {
        if let encoded = try? JSONEncoder().encode(registrations) {
            UserDefaults.standard.set(encoded, forKey: "savedRegistrations")
        }
    }
    
    static func loadFromUserDefaults() -> [Registration] {
        if let savedData = UserDefaults.standard.data(forKey: "savedRegistrations"),
           let registrations = try? JSONDecoder().decode([Registration].self, from: savedData) {
            return registrations
        }
        return []
    }
    
    // 添加单个注册记录
    static func addRegistration(_ registration: Registration) {
        var registrations = loadFromUserDefaults()
        registrations.append(registration)
        saveToUserDefaults(registrations)
    }
    
    // 删除所有注册记录
    static func removeAllFromUserDefaults() {
        UserDefaults.standard.removeObject(forKey: "savedRegistrations")
    }
    
    // 添加获取关联驾驶员信息的方法
    mutating func loadDriver() {
        if let savedDriver = Driver.loadFromUserDefaults(),
           savedDriver.id == self.driverId {
            self.driver = savedDriver
        }
    }
    
    // 添加按日期排序的静态方法
    static func sortedByDate(_ registrations: [Registration]) -> [Registration] {
        return registrations.sorted { $0.registrationDate > $1.registrationDate }
    }
    
    // 添加签到方法
    mutating func checkIn() {
        self.checkInTime = Date()
        self.status = .checkedIn
        // 更新存储
        var registrations = Registration.loadFromUserDefaults()
        if let index = registrations.firstIndex(where: { $0.id == self.id }) {
            registrations[index] = self
            Registration.saveToUserDefaults(registrations)
        }
    }
} 