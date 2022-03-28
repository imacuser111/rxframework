//
//  CreateAccountWebSocketRequest.swift
//  ExampleWebSocket
//
//  Created by Cheng-Hong on 2022/1/7.
//

import Foundation
import RxWebSocketPackage

// MARK: - 創建帳號(新用戶) or 創建uname(舊用戶) sysServ

class CreateAccountWebSocketRequest: WebSocketRequestProtocol {
    
    var serv: CCCommModel = RxWebSocketClient.sharedInstance.WebSocketComm.sysServ
    
    var method = WebSocketRequestType.CreateAccount
    
    var body: Data = Data()
    
    var timeStamp: Int64 = Date().currentTimeMillis()
    
    init(uname: String) {
        let request = QPPProto_ClientPack.CreateAccount.with {
            $0.uname = uname
        }
        body = convertToData(request: request, timeStamp: timeStamp)
    }
}
