import Foundation

struct TimeSlot: Identifiable, Hashable {
    let id = UUID()
    let startTime: Date
    let endTime: Date
    var registeredDrivers: [Driver] = []
    
    var displayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startTime))-\(formatter.string(from: endTime))"
    }
    
    // 实现 Hashable 协议
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(startTime)
        hasher.combine(endTime)
    }
    
    // 实现 Equatable 协议
    static func == (lhs: TimeSlot, rhs: TimeSlot) -> Bool {
        lhs.id == rhs.id &&
        lhs.startTime == rhs.startTime &&
        lhs.endTime == rhs.endTime
    }
    
    // 生成从当前时间段开始的时间段
    static func generateAvailableTimeSlots(from date: Date) -> [TimeSlot] {
        let calendar = Calendar.current
        let now = Date()
        
        // 获取当前小时的开始时间
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: now)
        components.minute = 0
        components.second = 0
        
        guard let currentHourStart = calendar.date(from: components),
              let currentHourEnd = calendar.date(byAdding: .hour, value: 1, to: currentHourStart) else {
            return []
        }
        
        var timeSlots: [TimeSlot] = []
        
        // 添加当前时间段
        timeSlots.append(TimeSlot(startTime: currentHourStart, endTime: currentHourEnd))
        
        // 生成后续时间段
        var currentTime = currentHourEnd
        for _ in 0..<11 { // 减少一个小时，因为已经包含了当前时间段
            let endTime = calendar.date(byAdding: .hour, value: 1, to: currentTime)!
            timeSlots.append(TimeSlot(startTime: currentTime, endTime: endTime))
            currentTime = endTime
        }
        
        return timeSlots
    }
} 