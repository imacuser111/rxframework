//
//  CClientPlayer.swift
//  
//
//  Created by Canry on 2021/11/8.
//

import Foundation

// Client用來對應 玩家資料
public class CClientPlayer {
    /// 登入的login server編號
    public var m_iSServID: Int = 0
    
    /// login server給的通行碼
    public var m_sToken: String = ""
    
    /// 登入的forum server編號
    public var m_iFServID: Int = 0
    
    // TODO: ------------以下變數不知道是什麼，目前沒用到------------
    
    /// login server給的通行碼
    public var m_sRefreshToken: String = ""
    
    public var m_sNick: String = ""
    
    deinit {
        print("deiniting \(self)")
    }
    
    public init() {
    }
    
    func setSData(_ succ: LoginResultSuccess) {
        m_iSServID = succ.servID
        m_sToken = succ.token ?? ""
        m_sNick = succ.nick ?? ""
    }
    
    func setFData(_ succ: LoginResultSuccess) {
        m_iFServID = succ.servID
        m_sNick = succ.nick ?? ""
    }
}
