import Foundation

struct Driver: Codable {
    var id: String
    var name: String
    var licenseNumber: String
    var phoneNumber: String
    var isContinuousDriver: Bool
    
    init(id: String, name: String, licenseNumber: String, phoneNumber: String, isContinuousDriver: Bool = false) {
        self.id = id
        self.name = name
        self.licenseNumber = licenseNumber
        self.phoneNumber = phoneNumber
        self.isContinuousDriver = isContinuousDriver
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