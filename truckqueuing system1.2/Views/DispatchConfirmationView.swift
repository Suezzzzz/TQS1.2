import SwiftUI

struct DispatchConfirmationView: View {
    @ObservedObject var viewModel: QueueViewModel
    @State private var trailerNumber = ""
    @Environment(\.presentationMode) var presentationMode
    let driver: Driver
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("请输入挂车号", text: $trailerNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("确认发车") {
                viewModel.dispatch(driver: driver, trailerNumber: trailerNumber)
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