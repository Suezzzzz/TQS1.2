import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = QueueViewModel()
    @State private var searchText = ""
    
    var filteredRegistrations: [Registration] {
        if searchText.isEmpty {
            return viewModel.registrations
        } else {
            return viewModel.registrations.filter { registration in
                if let vehicle = registration.vehicle {
                    return vehicle.plateNumber.contains(searchText)
                }
                return false
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("搜索车牌号", text: $searchText)
                }
                
                ForEach(filteredRegistrations) { registration in
                    VStack(alignment: .leading, spacing: 8) {
                        if let driver = registration.driver {
                            Text("司机: \(driver.name)")
                                .font(.headline)
                            
                            if driver.isContinuousDriver {
                                Text("连跑司机")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        if let vehicle = registration.vehicle {
                            Text("车牌: \(vehicle.plateNumber)")
                                .font(.subheadline)
                        }
                        
                        HStack {
                            Image(systemName: "calendar")
                            Text("登记时间: \(formatDate(registration.registrationDate))")
                                .font(.caption)
                        }
                        
                        HStack {
                            Image(systemName: "clock")
                            Text("到期时间: \(formatDate(registration.expiryDate))")
                                .font(.caption)
                                .foregroundColor(isExpired(registration.expiryDate) ? .red : .gray)
                        }
                        
                        if let checkInTime = registration.checkInTime {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                Text("签到时间: \(formatDate(checkInTime))")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        if registration.isDispatched {
                            HStack {
                                Image(systemName: "truck.box")
                                Text("已发车")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            if let trailerNumber = registration.trailerNumber {
                                Text("挂车号: \(trailerNumber)")
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("历史记录")
            .refreshable {
                viewModel.loadData()
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
    
    private func isExpired(_ date: Date) -> Bool {
        return date < Date()
    }
}

#Preview {
    HistoryView()
} 