//
//  VerifyPreLoginWebSocketRequest.swift
//  ExampleWebSocket
//
//  Created by Cheng-Hong on 2022/1/6.
//

import Foundation
import RxWebSocketPackage

// MARK: - 手機登入驗證sysServ

class VerifyPreLoginWebSocketRequest: WebSocketRequestProtocol {
    
    var serv: CCCommModel = RxWebSocketClient.sharedInstance.WebSocketComm.sysServ
    
    var method = WebSocketRequestType.VerifyPreLogin
    
    var body: Data = Data()
    
    var timeStamp: Int64 = Date().currentTimeMillis()
    
    init(code: Int32) {
        let request = QPPProto_ClientPack.VerifyPreLogin.with {
            $0.code = code
        }
        body = convertToData(request: request, timeStamp: timeStamp)
    }
}
