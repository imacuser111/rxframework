//
//  PreLoginSysWebSocketRequest.swift
//  ExampleWebSocket
//
//  Created by Cheng-Hong on 2022/1/6.
//

import Foundation
import RxWebSocketPackage

// MARK: - 手機登入sysServ

class PreLoginSysWebSocketRequest: WebSocketRequestProtocol {
    
    var serv: CCCommModel = RxWebSocketClient.sharedInstance.WebSocketComm.sysServ
    
    var method = WebSocketRequestType.PreLoginSys
    
    var body: Data = Data()
    
    var timeStamp: Int64 = Date().currentTimeMillis()
    
    init(acct: String) {
        let request = QPPProto_Login.PreLoginSys.with {
            $0.type = .phone
            $0.acct = acct
            $0.dkind = .ios
        }
        body = convertToData(request: request, timeStamp: timeStamp)
    }
}
