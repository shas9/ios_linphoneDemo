//
//  ContentView.swift
//  LinphoneDemo
//
//  Created by Shahwat Hasnaine on 25/6/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: ViewModel = ViewModel()
    var body: some View {
        VStack {
            if viewModel.loggedIn == false {
                LoginView(viewModel: viewModel)
            } else {
                OutgoingCallView(viewModel: viewModel)
            }
        }.sheet(isPresented: $viewModel.isCallIncoming, content: {
            IncomingCallView(viewModel: viewModel)
        })
    }
}

#Preview {
    ContentView()
}
