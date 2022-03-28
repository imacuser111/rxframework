//
//  ProfilesWebSocketRequest.swift
//  ExampleWebSocket
//
//  Created by Cheng-Hong on 2022/1/7.
//

import Foundation
import RxWebSocketPackage

// MARK: - 取得個人資訊funcServ

class ProfilesWebSocketRequest: WebSocketRequestProtocol {
    
    var serv: CCCommModel = RxWebSocketClient.sharedInstance.WebSocketComm.funcServ
    
    var method = WebSocketRequestType.Profiles
    
    var body: Data = Data()
    
    var timeStamp: Int64 = Date().currentTimeMillis()
    
    init() {
        let request = QPPProto_ClientPack.Profiles.with {
            $0.aryMkey = [RxWebSocketClient.sharedInstance.WebSocketComm.player.m_sToken]
        }
        body = convertToData(request: request, timeStamp: timeStamp)
    }
}
