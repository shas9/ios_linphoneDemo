//
//  LoginView.swift
//  LinphoneDemo
//
//  Created by Shahwat Hasnaine on 25/6/24.
//

import SwiftUI

struct LoginView: View {
    
    @ObservedObject var viewModel: LoginViewModel
    var body: some View {
        Form {
            HStack {
                Text("Username:")
                    .font(.title3)
                TextField("", text : $viewModel.username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(viewModel.loggedIn)
            }
            HStack {
                Text("Password:")
                    .font(.title3)
                TextField("", text : $viewModel.passwd)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(viewModel.loggedIn)
            }
            HStack {
                Text("Domain:")
                    .font(.title3)
                TextField("", text : $viewModel.domain)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(viewModel.loggedIn)
            }
            Picker(selection: $viewModel.transportType, label: Text("Transport:")) {
                Text("TLS").tag("TLS")
                Text("TCP").tag("TCP")
                Text("UDP").tag("UDP")
            }.pickerStyle(SegmentedPickerStyle()).padding()
            
        }
        .scrollDismissesKeyboard(.immediately)
        
        VStack {
            HStack {
                Button(action:  {
                    if (self.viewModel.loggedIn)
                    {
                        self.viewModel.unregister()
                        self.viewModel.delete()
                    } else {
                        self.viewModel.login()
                    }
                })
                {
                    Text(viewModel.loggedIn ? "Log out & \ndelete account" : "Create & \nlog in account")
                        .foregroundColor(Color.white)
                        .frame(width: 220.0, height: 45, alignment: .center)
                        .background(Color.accentColor)
                        .clipShape(.rect(cornerRadius: 15))
                }
            }
            HStack {
                Text("Login State : ")
                    .font(.footnote)
                Text(viewModel.loggedIn ? "Looged in" : "Unregistered")
                    .font(.footnote)
                    .foregroundColor(viewModel.loggedIn ? Color.green : Color.black)
            }.padding(.top, 10.0)
        }
    }
}

#Preview {
    LoginView(viewModel: LoginViewModel())
}
