import SwiftUI

struct DispatchListView: View {
    @ObservedObject var viewModel: QueueViewModel
    @State private var showingPasswordAlert = false
    @State private var password = ""
    @State private var showingErrorAlert = false
    @State private var showingConfirmationAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.registrations.filter { !$0.isDispatched }) { registration in
                        DispatchRow(registration: registration, viewModel: viewModel)
                    }
                }
                
                // 重置按钮
                Button(action: {
                    showingPasswordAlert = true
                }) {
                    Text("重置")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)
                .padding()
            }
            .navigationTitle("发车列表")
            .alert("输入密码", isPresented: $showingPasswordAlert) {
                TextField("密码", text: $password)
                    .textInputAutocapitalization(.never)
                Button("确定") {
                    if viewModel.clearAllData(password: password) {
                        showingConfirmationAlert = true
                    } else {
                        showingErrorAlert = true
                    }
                    password = ""
                }
                Button("取消", role: .cancel) {
                    password = ""
                }
            }
            .alert("错误", isPresented: $showingErrorAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text("密码错误")
            }
            .alert("成功", isPresented: $showingConfirmationAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text("所有信息已重置")
            }
        }
    }
}

// 添加 DispatchRow 视图
struct DispatchRow: View {
    let registration: Registration
    @ObservedObject var viewModel: QueueViewModel
    @State private var showingTrailerInput = false
    @State private var trailerNumber = ""
    
    var body: some View {
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
                
                if registration.checkInTime != nil {
                    Button("发车") {
                        showingTrailerInput = true
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Text("未签到")
                        .foregroundColor(.orange)
                }
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
        .alert("输入挂车号", isPresented: $showingTrailerInput) {
            TextField("挂车号", text: $trailerNumber)
            Button("确定") {
                viewModel.dispatchVehicle(registration: registration, trailerNumber: trailerNumber)
                trailerNumber = ""
            }
            Button("取消", role: .cancel) {
                trailerNumber = ""
            }
        }
    }
}

#Preview {
    DispatchListView(viewModel: QueueViewModel())
} 