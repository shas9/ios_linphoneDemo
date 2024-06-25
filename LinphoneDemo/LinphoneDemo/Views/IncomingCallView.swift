//
//  IncomingCallView.swift
//  LinphoneDemo
//
//  Created by Shahwat Hasnaine on 25/6/24.
//

import SwiftUI

struct IncomingCallView: View {
    @ObservedObject var viewModel : ViewModel
    
    func callStateString() -> String {
        if (viewModel.isIncomingCallRunning) {
            return "Call running"
        } else if (viewModel.isCallIncoming) {
            return "Incoming call"
        } else {
            return "No Call"
        }
    }
    
    var body: some View {
        
        VStack {
            Group {
                VStack {
                    VStack {
                        Button(action: {
                            if (self.viewModel.isCallIncoming) {
                                self.viewModel.acceptCall()
                            } else if (self.viewModel.isIncomingCallRunning){
                                self.viewModel.terminateCall()
                            }
                        })
                        {
                            Text( (viewModel.isIncomingCallRunning) ? "Terminate" : "Accept")
                                .foregroundColor(Color.white)
                                .frame(width: 300.0, height: 45, alignment: .center)
                                .background(Color.green)
                                .clipShape(.rect(cornerRadius: 15))
                        }
                        .disabled(!viewModel.isCallIncoming && !viewModel.isIncomingCallRunning)
                        HStack {
                            Text(callStateString()).italic()
                            Spacer()
                        }
                    }
                    HStack {
                        Text("Caller:").underline()
                        Text(viewModel.incomingCallRemoteAddress)
                        Spacer()
                    }.padding(.top, 5)
                    HStack {
                        Text("Call msg:").underline()
                        Text(viewModel.incomingCallMsg)
                        Spacer()
                    }.padding(.top, 5)
                    HStack {
                        Button(action: viewModel.toggleSpeaker)
                        {
                            Text((viewModel.isSpeakerEnabled) ? "Speaker OFF" : "Speaker ON")
                                .foregroundColor(Color.white)
                                .frame(width: 160, height: 45, alignment: .center)
                                .background(Color.accentColor)
                                .clipShape(.rect(cornerRadius: 15))
                        }
                        .disabled(!viewModel.isIncomingCallRunning)
                        Button(action: viewModel.muteMicrophone)
                        {
                            Text((viewModel.isMicrophoneEnabled) ? "Microphone OFF" : "Microphone ON")
                                .foregroundColor(Color.white)
                                .frame(width: 160, height: 45, alignment: .center)
                                .background(Color.accentColor)
                                .clipShape(.rect(cornerRadius: 15))
                        }
                        .disabled(!viewModel.isIncomingCallRunning)
                    }.padding(.top, 10)
                }.padding(.top, 30)
            }
            Group {
                Spacer()
                Text("Core Version is \(viewModel.coreVersion)")
            }
        }
        .padding()
    }
}

#Preview {
    IncomingCallView(viewModel: ViewModel())
}
