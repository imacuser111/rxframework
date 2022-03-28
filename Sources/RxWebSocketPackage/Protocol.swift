//
//  File.swift
//  
//
//  Created by Canry on 2021/11/8.
//

import Foundation
import RxSwift
import RxCocoa

extension Date {
    public func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

open class FunctionClosureInstance {
    public typealias ConfirmFunc = (CToServer) -> Data
    public typealias ReconnectFunc = (CToServer) -> Data
    public typealias ChgSysFunc = (CToServer) -> (sts: Int64, bt: Data)
    public typealias QuitFunc = (CToServer) -> (sts: Int64, bt: Data)
    public typealias SendOrRemovePackage = (Data) -> (Int64?)
    public typealias CheckPackage = (Data) -> (Int64)
    public typealias LoginPackageResult = (Data) -> (LoginResult)
    public typealias ServerPackageResult = (CToServer, Data) -> (sts: Int64?, rts: Int64?, result: ServerResult)
    public typealias Login = ((type: ServType, acct: String)) -> Data
    
    public init(confirmFunc: ConfirmFunc? = nil,
                reconnectFunc: ReconnectFunc? = nil,
                chgSysFunc: ChgSysFunc? = nil,
                quitFunc: QuitFunc? = nil,
                sendOrRemovePackage: SendOrRemovePackage? = nil,
                loginPackageResult: LoginPackageResult? = nil,
                serverPackageResult: ServerPackageResult? = nil,
                login: Login? = nil) {
        self.confirmFunc = confirmFunc
        self.reconnectFunc = reconnectFunc
        self.chgSysFunc = chgSysFunc
        self.quitFunc = quitFunc
        self.loginPackageResult = loginPackageResult
        self.serverPackageResult = serverPackageResult
        self.login = login
        self.sendOrRemovePackage = sendOrRemovePackage
    }
    #if DEBUG
    // If data source has already been bound, then mutating it
    // afterwards isn't something desired.
    // This simulates immutability after binding
    var _dataSourceBound: Bool = false

    private func ensureNotMutatedAfterBinding() {
        assert(!_dataSourceBound, "Data source is already bound. Please write this line before binding call (`bindTo`, `drive`). Data source must first be completely configured, and then bound after that, otherwise there could be runtime bugs, glitches, or partial malfunctions.")
    }

    #endif
    
    open var confirmFunc: ConfirmFunc? {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    open var reconnectFunc: ReconnectFunc? {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    open var chgSysFunc: ChgSysFunc? {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    open var quitFunc: QuitFunc? {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    open var loginPackageResult: LoginPackageResult? {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    open var serverPackageResult: ServerPackageResult? {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    open var login: Login? {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    open var sendOrRemovePackage: SendOrRemovePackage? {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    
    public func entry(type: ServType, acct: String = "") {
        RxWebSocketClient.sharedInstance.WebSocketComm.login(type: type, acct: acct)
    }
}
