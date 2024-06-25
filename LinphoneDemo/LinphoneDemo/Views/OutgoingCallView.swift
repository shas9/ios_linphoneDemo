//
//  OutgoingCallView.swift
//  LinphoneDemo
//
//  Created by Shahwat Hasnaine on 25/6/24.
//

import SwiftUI
import linphonesw

struct OutgoingCallView: View {
    @ObservedObject var viewModel : ViewModel
    
    func callStateString() -> String {
        if (viewModel.isCallRunning) {
            return "Call running"
        } else {
            return "No Call"
        }
    }
    
    var body: some View {
        
        VStack {
            VStack (spacing: 20) {
                HStack {
                    Text("Call dest:")
                        .font(.title3)
                    TextField("", text : $viewModel.remoteAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!viewModel.loggedIn)
                }
                VStack(spacing: 5) {
                    Button(action: {
                        if (self.viewModel.isCallRunning) {
                            self.viewModel.terminateCall()
                        } else {
                            self.viewModel.outgoingCall()
                        }
                    })
                    {
                        Text( (viewModel.isCallRunning) ? "End" : "Call")
                            .foregroundColor(Color.white)
                            .frame(width: 300.0, height: 45, alignment: .center)
                            .background(Color.accentColor)
                            .clipShape(.rect(cornerRadius: 15))
                    }
                    HStack {
                        Text(viewModel.isCallRunning ? "Running" : "")
                            .italic().foregroundColor(.green)
                        Spacer()
                    }
                    HStack {
                        Text("Call msg:").underline()
                        Text(viewModel.callMsg)
                        Spacer()
                    }
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
                                Text(viewModel.loggedIn ? "Log out" : "Log in")
                                    .foregroundColor(Color.white)
                                    .frame(width: 300.0, height: 45, alignment: .center)
                                    .background(Color.accentColor)
                                    .clipShape(.rect(cornerRadius: 15))
                            }
                        }
                        HStack {
                            Text("Login State : ")
                            Text(viewModel.loggedIn ? "Looged in" : "Unregistered")
                                .foregroundColor(viewModel.loggedIn ? Color.green : Color.red)
                        }
                    }
                }.padding(.top, 30)
                
                Group {
                    Spacer()
                    Text("Core Version is \(viewModel.coreVersion)")
                }
            }
            .padding()
        }
    }
}

#Preview {
    OutgoingCallView(viewModel: ViewModel())
}
