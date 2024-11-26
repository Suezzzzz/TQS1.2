import SwiftUI

struct RegistrationView: View {
    @ObservedObject var viewModel: QueueViewModel
    @State private var driverName = ""
    @State private var phoneNumber = ""
    @State private var plateNumber = ""
    @State private var isContinuousDriver = false
    @State private var selectedVehicleType = VehicleType.normal
    @State private var expectedCheckInTime = Date()
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("司机信息")) {
                    TextField("司机姓名", text: $driverName)
                    TextField("手机号码", text: $phoneNumber)
                        .keyboardType(.numberPad)
                    Toggle("连跑司机", isOn: $isContinuousDriver)
                    
                    if isContinuousDriver {
                        DatePicker("预计签到时间",
                                 selection: $expectedCheckInTime,
                                 in: Date()...Date().addingTimeInterval(12*3600),
                                 displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                Section(header: Text("车辆信息")) {
                    TextField("车牌号", text: $plateNumber)
                        .textCase(.uppercase)
                    
                    Picker("车辆类型", selection: $selectedVehicleType) {
                        ForEach(VehicleType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section {
                    Button(action: submitRegistration) {
                        HStack {
                            Spacer()
                            Text("提交登记")
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isFormValid())
                }
            }
            .navigationTitle("登记")
            .alert("登记成功", isPresented: $showSuccessAlert) {
                Button("确定", role: .cancel) {
                    clearForm()
                }
            } message: {
                Text(isContinuousDriver ? "请在预定时间签到" : "已自动签到并进入发车队列")
            }
            .alert("登记失败", isPresented: $showErrorAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func isFormValid() -> Bool {
        !driverName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty &&
        !plateNumber.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func submitRegistration() {
        let driver = viewModel.registerDriver(
            name: driverName.trimmingCharacters(in: .whitespaces),
            phoneNumber: phoneNumber.trimmingCharacters(in: .whitespaces),
            isContinuous: isContinuousDriver,
            expectedCheckInTime: isContinuousDriver ? expectedCheckInTime : nil
        )
        
        do {
            let vehicle = try viewModel.registerVehicle(
                plateNumber: plateNumber.uppercased().trimmingCharacters(in: .whitespaces),
                type: selectedVehicleType
            )
            
            viewModel.createRegistration(driver: driver, vehicle: vehicle)
            showSuccessAlert = true
        } catch RegistrationError.vehicleInPenalty {
            errorMessage = "该车辆在惩罚期内，12小时内不能重新登记"
            showErrorAlert = true
        } catch RegistrationError.vehicleAlreadyRegistered {
            errorMessage = "该车辆在24小时内已经登记过，请等待24小时后再次登记"
            showErrorAlert = true
        } catch {
            errorMessage = "登记失败，请稍后重试"
            showErrorAlert = true
        }
    }
    
    private func clearForm() {
        driverName = ""
        phoneNumber = ""
        plateNumber = ""
        isContinuousDriver = false
        selectedVehicleType = .normal
        expectedCheckInTime = Date()
    }
}

#Preview {
    RegistrationView(viewModel: QueueViewModel())
} 