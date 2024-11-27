//
//  ContentView.swift
//  truckqueuing system1.2
//
//  Created by Di Zheng on 2024/11/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = QueueViewModel()
    @State private var currentTime = Date()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    // 创建一个定时器来更新时间
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // 主要内容
            TabView {
                RegistrationView(viewModel: viewModel)
                    .tabItem {
                        Label("登记", systemImage: "square.and.pencil")
                    }
                
                CheckInView(viewModel: viewModel)
                    .tabItem {
                        Label("签到", systemImage: "checkmark.circle")
                    }
                
                DispatchListView(viewModel: viewModel)
                    .tabItem {
                        Label("发车列表", systemImage: "list.bullet")
                    }
                
                HistoryView()
                    .tabItem {
                        Label("历史记录", systemImage: "clock")
                    }
            }
            
            // 仅在iPad上显示额外信息
            if horizontalSizeClass == .regular {
                SidebarInfoView(currentTime: currentTime)
            }
        }
        .onReceive(timer) { time in
            currentTime = time
        }
    }
}

// 将侧边栏信息移到单独的视图中
struct SidebarInfoView: View {
    let currentTime: Date
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 30) {
                    // 流程说明
                    ProcessInstructionsView()
                    
                    // 导航信息
                    NavigationInfoView()
                    
                    // 时间显示
                    TimeDisplayView(currentTime: currentTime)
                }
                .padding(.trailing, 30)
                .padding(.bottom, 30)
            }
        }
    }
}

// 流程说明视图
struct ProcessInstructionsView: View {
    var body: some View {
        VStack(alignment: .trailing, spacing: 15) {
            Text("登记流程说明")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            Text("整体流程：")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.gray)
                .multilineTextAlignment(.trailing)
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("连跑司机：登记信息-选择预计签到时间-按时签到-排队等候发车-接收发车通知-填入挂车号完成发车")
                    .multilineTextAlignment(.trailing)
                Text("非连跑司机：登记信息-排队等候发车-接收发车通知-填入挂车号完成发车")
                    .multilineTextAlignment(.trailing)
            }
            .font(.system(size: 14))
            .foregroundColor(.gray)
            
            Text("具体细则：")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.gray)
                .multilineTextAlignment(.trailing)
                .padding(.top, 10)
            
            VStack(alignment: .trailing, spacing: 10) {
                Text("1. 连跑司机需要在现场登记选择签到时间并按时完成签到；")
                    .multilineTextAlignment(.trailing)
                Text("2. 连跑司机需要在预定时间前后15分钟内签到，超时视为放弃登记；")
                    .multilineTextAlignment(.trailing)
                Text("3. 连跑司机完成签到后进入发车列表等候发车；")
                    .multilineTextAlignment(.trailing)
                Text("4. 非连跑司机登记后直接进入发车列表等候发车；")
                    .multilineTextAlignment(.trailing)
                Text("5. 当日连跑司机优先于非连跑司机派单；")
                    .multilineTextAlignment(.trailing)
                Text("6. 同一车牌24小时内只可登记一次；")
                    .multilineTextAlignment(.trailing)
                Text("7. 发车时需要输入挂车号。")
                    .multilineTextAlignment(.trailing)
            }
            .font(.system(size: 14))
            .foregroundColor(.gray)
            
            Text("无论山高路远，愿您平安顺风，一路繁花相伴！")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.blue)
                .multilineTextAlignment(.trailing)
                .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

// 导航信息视图
struct NavigationInfoView: View {
    var body: some View {
        VStack(alignment: .trailing, spacing: 15) {
            Text("From: 14590 Limonite Avenue, Eastvale, CA")
                .font(.system(size: 20))
                .foregroundColor(.gray)
            
            VStack(alignment: .trailing, spacing: 20) {
                // Harrisburg 路线
                VStack(alignment: .trailing, spacing: 8) {
                    Text("To: 1900 Crooked hill rd, Harrisburg PA")
                        .font(.system(size: 16))
                    HStack {
                        Text("2,654 miles")
                        Text("•")
                        Text("预计39小时")
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                }
                
                // Douglasville 路线
                VStack(alignment: .trailing, spacing: 8) {
                    Text("To: 7600 Wood Rd, Douglasville, GA")
                        .font(.system(size: 16))
                    HStack {
                        Text("2,175 miles")
                        Text("•")
                        Text("预计32小时")
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

// 时间显示视图
struct TimeDisplayView: View {
    let currentTime: Date
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 5) {
            Text(formatDate(currentTime))
                .font(.system(size: 26))
                .foregroundColor(.gray)
            
            Text(formatTime(currentTime))
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.blue)
                .monospacedDigit()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
}
