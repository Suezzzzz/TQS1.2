import SwiftUI

struct DispatchListView: View {
    @ObservedObject var viewModel: QueueViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.registrations.filter { $0.checkInTime != nil && !$0.isDispatched }) { registration in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(registration.driver.name)
                                .font(.headline)
                            Spacer()
                            Text(registration.vehicle.type.rawValue)
                                .font(.subheadline)
                        }
                        
                        Text("车牌: \(registration.vehicle.plateNumber)")
                        
                        if let checkInTime = registration.checkInTime {
                            Text("签到时间: \(checkInTime.formatted(date: .omitted, time: .shortened))")
                                .font(.caption)
                        }
                        
                        if registration.driver.isContinuousDriver {
                            Text("连跑司机")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("发车列表")
        }
    }
} 