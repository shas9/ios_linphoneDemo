//
//  ViewModel.swift
//  LinphoneDemo
//
//  Created by Shahwat Hasnaine on 25/6/24.
//

import linphonesw

class ViewModel : ObservableObject
{
    var mCore: Core!
    @Published var coreVersion: String = Core.getVersion
    
    /*------------ Login tutorial related variables -------*/
    var mCoreDelegate : CoreDelegate!
    @Published var username : String = "7002"
    @Published var passwd : String = "7002"
    @Published var domain : String = "192.168.1.121"
    @Published var loggedIn: Bool = false
    @Published var transportType : String = "UDP"
    
    // Outgoing call related variables
    @Published var callMsg : String = "No call has been initiated"
    @Published var isCallRunning : Bool = false
    @Published var isVideoEnabled : Bool = false
    @Published var canChangeCamera : Bool = false
    @Published var remoteAddress : String = "sip:7001@192.168.1.121"
    
    init()
    {
        LoggingService.Instance.logLevel = LogLevel.Debug
        
        try? mCore = Factory.Instance.createCore(configPath: "", factoryConfigPath: "", systemContext: nil)
        // Here we enable the video capture & display at Core level
        // It doesn't mean calls will be made with video automatically,
        // But it allows to use it later
        mCore.videoCaptureEnabled = true
        mCore.videoDisplayEnabled = true
        
        // When enabling the video, the remote will either automatically answer the update request
        // or it will ask it's user depending on it's policy.
        // Here we have configured the policy to always automatically accept video requests
        mCore.videoActivationPolicy!.automaticallyAccept = true
        // If you don't want to automatically accept,
        // you'll have to use a code similar to the one in toggleVideo to answer a received request
        
        
        // If the following property is enabled, it will automatically configure created call params with video enabled
        //core.videoActivationPolicy.automaticallyInitiate = true
        
        try? mCore.start()
        
        mCoreDelegate = CoreDelegateStub( onCallStateChanged: { (core: Core, call: Call, state: Call.State, message: String) in
            // This function will be called each time a call state changes,
            // which includes new incoming/outgoing calls
            self.callMsg = message
            
            if (state == .OutgoingInit) {
                // First state an outgoing call will go through
            } else if (state == .OutgoingProgress) {
                // Right after outgoing init
            } else if (state == .OutgoingRinging) {
                // This state will be reached upon reception of the 180 RINGING
            } else if (state == .Connected) {
                // When the 200 OK has been received
            } else if (state == .StreamsRunning) {
                // This state indicates the call is active.
                // You may reach this state multiple times, for example after a pause/resume
                // or after the ICE negotiation completes
                // Wait for the call to be connected before allowing a call update
                self.isCallRunning = true
                
                // Only enable toggle camera button if there is more than 1 camera
                // We check if core.videoDevicesList.size > 2 because of the fake camera with static image created by our SDK (see below)
                self.canChangeCamera = core.videoDevicesList.count > 2
            } else if (state == .Paused) {
                // When you put a call in pause, it will became Paused
                self.canChangeCamera = false
            } else if (state == .PausedByRemote) {
                // When the remote end of the call pauses it, it will be PausedByRemote
            } else if (state == .Updating) {
                // When we request a call update, for example when toggling video
            } else if (state == .UpdatedByRemote) {
                // When the remote requests a call update
            } else if (state == .Released) {
                // Call state will be released shortly after the End state
                self.isCallRunning = false
                self.canChangeCamera = false
            } else if (state == .Error) {
                
            }
        }, onAccountRegistrationStateChanged: { (core: Core, account: Account, state: RegistrationState, message: String) in
            NSLog("New registration state is \(state) for user id \( String(describing: account.params?.identityAddress?.asString()))\n")
            if (state == .Ok) {
                self.loggedIn = true
            } else if (state == .Cleared) {
                self.loggedIn = false
            }
        })
        mCore.addDelegate(delegate: mCoreDelegate)
    }
    
    func login() {
        
        do {
            // Get the transport protocol to use.
            // TLS is strongly recommended
            // Only use UDP if you don't have the choice
            var transport : TransportType
            if (transportType == "TLS") { transport = TransportType.Tls }
            else if (transportType == "TCP") { transport = TransportType.Tcp }
            else  { transport = TransportType.Udp }
            
            // To configure a SIP account, we need an Account object and an AuthInfo object
            // The first one is how to connect to the proxy server, the second one stores the credentials
            
            // The auth info can be created from the Factory as it's only a data class
            // userID is set to null as it's the same as the username in our case
            // ha1 is set to null as we are using the clear text password. Upon first register, the hash will be computed automatically.
            // The realm will be determined automatically from the first register, as well as the algorithm
            let authInfo = try Factory.Instance.createAuthInfo(username: username, userid: "", passwd: passwd, ha1: "", realm: "", domain: domain)
            
            // Account object replaces deprecated ProxyConfig object
            // Account object is configured through an AccountParams object that we can obtain from the Core
            let accountParams = try mCore.createAccountParams()
            
            // A SIP account is identified by an identity address that we can construct from the username and domain
            let identity = try Factory.Instance.createAddress(addr: String("sip:" + username + "@" + domain))
            try! accountParams.setIdentityaddress(newValue: identity)
            
            // We also need to configure where the proxy server is located
            let address = try Factory.Instance.createAddress(addr: String("sip:" + domain))
            
            // We use the Address object to easily set the transport protocol
            try address.setTransport(newValue: transport)
            try accountParams.setServeraddress(newValue: address)
            // And we ensure the account will start the registration process
            accountParams.registerEnabled = true
            
            // Now that our AccountParams is configured, we can create the Account object
            let account = try mCore.createAccount(params: accountParams)
            
            // Now let's add our objects to the Core
            mCore.addAuthInfo(info: authInfo)
            try mCore.addAccount(account: account)
            
            // Also set the newly added account as default
            mCore.defaultAccount = account
            
        } catch { NSLog(error.localizedDescription) }
    }
    
    func unregister()
    {
        // Here we will disable the registration of our Account
        if let account = mCore.defaultAccount {
            
            let params = account.params
            // Returned params object is const, so to make changes we first need to clone it
            let clonedParams = params?.clone()
            
            // Now let's make our changes
            clonedParams?.registerEnabled = false
            
            // And apply them
            account.params = clonedParams
        }
    }
    func delete() {
        // To completely remove an Account
        if let account = mCore.defaultAccount {
            mCore.removeAccount(account: account)
            
            // To remove all accounts use
            mCore.clearAccounts()
            
            // Same for auth info
            mCore.clearAllAuthInfo()
        }
    }
    
    func outgoingCall() {
        do {
            // As for everything we need to get the SIP URI of the remote and convert it to an Address
            let remoteAddress = try Factory.Instance.createAddress(addr: remoteAddress)
            
            // We also need a CallParams object
            // Create call params expects a Call object for incoming calls, but for outgoing we must use null safely
            let params = try mCore.createCallParams(call: nil)
            
            // We can now configure it
            // Here we ask for no encryption but we could ask for ZRTP/SRTP/DTLS
            params.mediaEncryption = MediaEncryption.None
            // If we wanted to start the call with video directly
            //params.videoEnabled = true
            
            // Finally we start the call
            let _ = mCore.inviteAddressWithParams(addr: remoteAddress, params: params)
            // Call process can be followed in onCallStateChanged callback from core listener
        } catch { NSLog(error.localizedDescription) }
        
    }
    
    func terminateCall() {
        do {
            if (mCore.callsNb == 0) { return }
            
            // If the call state isn't paused, we can get it using core.currentCall
            let coreCall = (mCore.currentCall != nil) ? mCore.currentCall : mCore.calls[0]
            
            // Terminating a call is quite simple
            if let call = coreCall {
                try call.terminate()
            }
        } catch { NSLog(error.localizedDescription) }
    }
    
    func pauseOrResume() {
        do {
            if (mCore.callsNb == 0) { return }
            let coreCall = (mCore.currentCall != nil) ? mCore.currentCall : mCore.calls[0]
            
            if let call = coreCall {
                if (call.state != Call.State.Paused && call.state != Call.State.Pausing) {
                    // If our call isn't paused, let's pause it
                    try call.pause()
                } else if (call.state != Call.State.Resuming) {
                    // Otherwise let's resume it
                    try call.resume()
                }
            }
        } catch { NSLog(error.localizedDescription) }
    }
    
}

