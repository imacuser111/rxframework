//
//  LoginSys.swift
//  ExampleWebSocket
//
//  Created by Cheng-Hong on 2022/1/7.
//

import Foundation
import RxWebSocketPackage

// MARK: - token登入sysServ

class LoginSysWebSocketRequest: WebSocketRequestProtocol {
    
    var serv: CCCommModel = RxWebSocketClient.sharedInstance.WebSocketComm.sysServ
    
    var method = WebSocketRequestType.LoginSys
    
    var body: Data = Data()
    
    var timeStamp: Int64 = Date().currentTimeMillis()
    
    init(token: String, refreshToken: String) {
        let request = QPPProto_Login.LoginSys.with {
            $0.type = .tokenLogin
            $0.acct = token
            $0.pw = refreshToken
            $0.dkind = .ios
        }
        body = convertToData(request: request, timeStamp: timeStamp)
    }
}
