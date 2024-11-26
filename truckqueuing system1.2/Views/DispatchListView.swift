import SwiftUI

struct DispatchListView: View {
    @ObservedObject var viewModel: QueueViewModel
    @State private var showingTrailerInput = false
    @State private var trailerNumber = ""
    @State private var selectedRegistration: Registration?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.registrations.filter { $0.checkInTime != nil && !$0.isDispatched }) { registration in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading) {
                                if let driver = registration.driver {
                                    Text(driver.name)
                                        .font(.headline)
                                }
                                if let vehicle = registration.vehicle {
                                    Text(vehicle.plateNumber)
                                        .font(.subheadline)
                                }
                            }
                            
                            Spacer()
                            
                            Button("发车") {
                                selectedRegistration = registration
                                showingTrailerInput = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        
                        if let checkInTime = registration.checkInTime {
                            Text("签到时间: \(checkInTime.formatted(date: .omitted, time: .shortened))")
                                .font(.caption)
                        }
                        
                        if let driver = registration.driver, driver.isContinuousDriver {
                            Text("连跑司机")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("发车列表")
            .alert("输入挂车号", isPresented: $showingTrailerInput) {
                TextField("挂车号", text: $trailerNumber)
                Button("确定") {
                    if let registration = selectedRegistration {
                        viewModel.dispatchVehicle(registration: registration, trailerNumber: trailerNumber)
                        trailerNumber = ""
                    }
                }
                Button("取消", role: .cancel) {
                    trailerNumber = ""
                }
            }
        }
    }
} 