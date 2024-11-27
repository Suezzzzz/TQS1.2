import SwiftUI

struct CheckInView: View {
    @ObservedObject var viewModel: QueueViewModel
    
    var body: some View {
        NavigationView {
            List {
                // 只显示今天需要签到的连跑司机
                ForEach(viewModel.getTodayCheckInRegistrations()) { registration in
                    CheckInRow(registration: registration, viewModel: viewModel)
                }
            }
            .navigationTitle("签到")
            .refreshable {
                viewModel.loadData()
            }
        }
    }
}

struct CheckInRow: View {
    let registration: Registration
    @ObservedObject var viewModel: QueueViewModel
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 司机和车辆信息
            HStack {
                Text(registration.driver?.name ?? "未知司机")
                    .font(.headline)
                Spacer()
                Text(registration.vehicle?.plateNumber ?? "未知车牌")
            }
            
            // 预约时间段显示
            if let expectedTime = registration.expectedCheckInTime {
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: expectedTime)
                let nextHour = (hour + 1) % 24
                
                HStack {
                    Text("预约时间段: \(hour):00-\(nextHour):00")
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    // 签到状态
                    if registration.checkInTime != nil {
                        Text("已签到")
                            .foregroundColor(.green)
                    } else if viewModel.canCheckIn(registration: registration) {
                        Button("签到") {
                            viewModel.checkIn(registration: registration)
                            showAlert = true
                            alertMessage = "签到成功"
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Text("未到签到时间")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .alert("提示", isPresented: $showAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
} 