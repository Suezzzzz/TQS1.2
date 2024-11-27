import Foundation

enum DriverStatus: String, Codable {
    case registered = "已登记"
    case checkedIn = "已签到"
    case dispatched = "已发车"
}

struct Driver: Codable, Identifiable {
    let id: String
    let name: String
    let licenseNumber: String
    let phoneNumber: String
    let isContinuousDriver: Bool
    var status: DriverStatus = .registered
    var checkInTime: Date?
    var trailerNumber: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case licenseNumber
        case phoneNumber
        case isContinuousDriver
        case status
        case checkInTime
        case trailerNumber
    }
    
    // 添加用于UserDefaults存储的方法
    static func saveToUserDefaults(_ driver: Driver) {
        if let encoded = try? JSONEncoder().encode(driver) {
            UserDefaults.standard.set(encoded, forKey: "savedDriver")
        }
    }
    
    static func loadFromUserDefaults() -> Driver? {
        if let savedData = UserDefaults.standard.data(forKey: "savedDriver"),
           let driver = try? JSONDecoder().decode(Driver.self, from: savedData) {
            return driver
        }
        return nil
    }
    
    // 删除存储的驾驶员数据
    static func removeFromUserDefaults() {
        UserDefaults.standard.removeObject(forKey: "savedDriver")
    }
} 