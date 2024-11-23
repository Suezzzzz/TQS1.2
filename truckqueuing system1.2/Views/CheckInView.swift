import SwiftUI

struct CheckInView: View {
    @ObservedObject var viewModel: QueueViewModel
    @State private var searchPlateNumber = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var filteredRegistrations: [Registration] {
        if searchPlateNumber.isEmpty {
            return viewModel.registrations.filter { $0.checkInTime == nil }
        } else {
            return viewModel.registrations.filter { 
                $0.checkInTime == nil && 
                $0.vehicle.plateNumber.contains(searchPlateNumber)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("输入车牌号搜索", text: $searchPlateNumber)
                }
                
                Section(header: Text("待签到列表")) {
                    ForEach(filteredRegistrations) { registration in
                        RegistrationRow(registration: registration, viewModel: viewModel) {
                            if registration.driver.isContinuousDriver {
                                if viewModel.canCheckIn(registration: registration) {
                                    viewModel.checkIn(registration: registration)
                                } else {
                                    showAlert = true
                                    alertMessage = "只能在预定时间前后15分钟内签到"
                                }
                            } else {
                                viewModel.checkIn(registration: registration)
                            }
                        }
                    }
                }
            }
            .navigationTitle("签到")
            .alert("签到失败", isPresented: $showAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

struct RegistrationRow: View {
    let registration: Registration
    let viewModel: QueueViewModel
    let checkInAction: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(registration.driver.name)
                    .font(.headline)
                Text(registration.vehicle.plateNumber)
                    .font(.subheadline)
                if registration.driver.isContinuousDriver,
                   let expectedTime = registration.expectedCheckInTime {
                    Text("预计签到: \(expectedTime.formatted(date: .omitted, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(viewModel.canCheckIn(registration: registration) ? .blue : .gray)
                }
            }
            
            Spacer()
            
            Button("签到") {
                checkInAction()
            }
            .buttonStyle(.borderedProminent)
            .disabled(registration.driver.isContinuousDriver && !viewModel.canCheckIn(registration: registration))
        }
        .padding(.vertical, 4)
    }
} 