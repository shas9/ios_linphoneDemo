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
        if viewModel.loggedIn == false {
            LoginView(viewModel: viewModel)
        } else {
            OutgoingCallView(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}
