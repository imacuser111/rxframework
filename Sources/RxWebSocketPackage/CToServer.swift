//
//  CToServer.swift
//  
//
//  Created by Canry on 2021/11/5.
//

import Foundation

// MARK: - Client用來對應Server資料及重連

public class CToServer {
    /// 重連溝通用
    public let m_myToken: String
    /// 登入的system server ID
    public var m_mySServID: Int
    
    private let m_WSCCommu: CWSCCommu
    
    deinit {
        print("deiniting \(self)")
    }
    
    init(wsc: CWebsocketClient, sendAliveSec: Int, token: String, sservID: Int) {
        m_WSCCommu = CWSCCommu(wsc: wsc, sendAliveSec: sendAliveSec)
        
        m_myToken = token
        m_mySServID = sservID
    }
    
    public var WScCommu: CWSCCommu {
        return m_WSCCommu
    }
    
    func sendConfirm() { // 接收到才會打confirm
        if let function = functionCall.confirmFunc {
            let bt = function(self)
            m_WSCCommu.send_Direct(obj: bt)
        }
    }
    
    func sendReconnect() {
        if let function = functionCall.reconnectFunc {
            let bt = function(self)
            m_WSCCommu.send_Direct(obj: bt)
        }
    }
    
    //#Jas 20211229 //! 加分流識別ID
    func sendChgSys() { // for Send_FunServ
        if let function = functionCall.chgSysFunc {
            let (sts, bt) = function(self)
            m_WSCCommu.send_DirectPack(ts: sts, bt: bt)
        }
    }
    
    public func sendQuit() {
        m_WSCCommu.setQuit()
        
        if let function = functionCall.quitFunc {
            let (sts, bt) = function(self)
            m_WSCCommu.send_DirectPack(ts: sts, bt: bt)
        }
    }
}
