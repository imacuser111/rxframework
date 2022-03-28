//
//  LoginFServWebSocketRequest.swift
//  ExampleWebSocket
//
//  Created by Cheng-Hong on 2022/1/7.
//

import Foundation
import RxWebSocketPackage

// MARK: - 功能登入funcServ

class LoginFServWebSocketRequest: WebSocketRequestProtocol {
    
    var serv: CCCommModel = RxWebSocketClient.sharedInstance.WebSocketComm.funcServ
    
    var method = WebSocketRequestType.LoginFServ
    
    var body: Data = Data()
    
    var timeStamp: Int64 = Date().currentTimeMillis()
    
    init() {
        let request = QPPProto_Login.LoginFServ.with {
            $0.token = RxWebSocketClient.sharedInstance.WebSocketComm.player.m_sToken
            $0.dkind = .ios
            $0.sservID = Int32(RxWebSocketClient.sharedInstance.WebSocketComm.player.m_iSServID) //#Jas 20211229 //! 加分流識別ID
        }
        body = convertToData(request: request, timeStamp: timeStamp)
    }
}
