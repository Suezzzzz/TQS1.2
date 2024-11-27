import SwiftUI

struct DispatchConfirmationView: View {
    @ObservedObject var viewModel: QueueViewModel
    @State private var trailerNumber = ""
    @State private var selectedRoute: Route = .CA_PA
    @Environment(\.presentationMode) var presentationMode
    let registration: Registration
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("请输入挂车号", text: $trailerNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Picker("路线", selection: $selectedRoute) {
                ForEach(Route.allCases, id: \.self) { route in
                    Text(route.rawValue).tag(route)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            Button("确认发车") {
                viewModel.dispatchVehicle(
                    registration: registration,
                    trailerNumber: trailerNumber,
                    route: selectedRoute
                )
            }
            .disabled(trailerNumber.isEmpty)
        }
        .alert(isPresented: $viewModel.showingSuccessAlert) {
            Alert(
                title: Text("发车成功"),
                message: Text("祝您一路平安"),
                dismissButton: .default(Text("确定")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .padding()
    }
} 