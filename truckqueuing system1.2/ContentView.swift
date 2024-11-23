//
//  ContentView.swift
//  truckqueuing system1.2
//
//  Created by Di Zheng on 2024/11/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = QueueViewModel()
    
    var body: some View {
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
        }
    }
}

#Preview {
    ContentView()
}
