//
//  ContentView.swift
//  LinphoneDemo
//
//  Created by Shahwat Hasnaine on 25/6/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var loginViewModel: LoginViewModel = LoginViewModel()
    var body: some View {
        LoginView(viewModel: loginViewModel)
    }
}

#Preview {
    ContentView()
}
