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
                    HistoryRow(registration: registration)
                }
            }
            .navigationTitle("历史记录")
            .refreshable {
                viewModel.loadData()
            }
        }
    }
}

struct HistoryRow: View {
    let registration: Registration
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(registration.driver?.name ?? "未知司机")
                        .font(.headline)
                    Text(registration.vehicle?.plateNumber ?? "未知车牌")
                        .font(.subheadline)
                }
                Spacer()
                if registration.isDispatched {
                    Text("已发车")
                        .foregroundColor(.green)
                }
            }
            
            if let expectedTime = registration.expectedCheckInTime {
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: expectedTime)
                let nextHour = (hour + 1) % 24
                Text("预约时间段: \(hour):00-\(nextHour):00")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if let checkInTime = registration.checkInTime {
                Text("签到时间: \(checkInTime.formatted())")
                    .font(.caption)
            }
            
            if let route = registration.route {
                Text("路线: \(route.rawValue)")
                    .font(.caption)
            }
            
            if let dispatchTime = registration.dispatchTime {
                Text("发车时间: \(dispatchTime.formatted())")
                    .font(.caption)
                
                if let estimatedArrival = registration.estimatedArrivalTime {
                    Text("预计到达: \(estimatedArrival.formatted())")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            if registration.driver?.isContinuousDriver == true {
                Text("连跑司机")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HistoryView()
} 