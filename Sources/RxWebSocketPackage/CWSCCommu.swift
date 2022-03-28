//
//  CWSCCommu.swift
//  
//
//  Created by Canry on 2021/11/5.
//

import Foundation
import Starscream

public class CWSCCommu {
    
    public let m_wsc: CWebsocketClient
    
    /// 用來儲存package的dic
    private var m_dicSendPack: Dictionary<Int64, Data> = [:]
    
    /// 用來排序的鎖
    private let mutex = DispatchSemaphore(value: 1)
    
    private var m_SendTime: Int64 = Date().currentTimeMillis()
    
    /// 發送時戳，如果等待時間到，未回覆則觸發斷線
    private var m_iWaitResponse: Int64 = 0
    
    /// 已接收的包的時戳
    private var m_RecvTS: Int64 = 0
    
    // -----------以下為新的參數-----------
    /// 發送心跳封包時間
    private let m_SendAliveTime: Int64 // ms
    
    // -----------不知道用在哪裡的參數-----------
    /// 斷線起始時間，用來計算5分鐘後停止重連
    private var m_CloseTime: Int64 = 0
    
    deinit {
        print("deiniting \(self)")
    }
    
    init(wsc: CWebsocketClient, sendAliveSec: Int) {
        m_wsc = wsc
        m_SendAliveTime = Int64(sendAliveSec * 1000)
    }
    
//    func connect() {
//        m_wsc.connect()
//        
//        resetSendTimeAndWaitTime()
//    }
    
    /// 重連清除狀態
    func resetSendTimeAndWaitTime() {
        // 發生重連, 要清狀態 '先在這裡清
        m_SendTime = 0
        m_iWaitResponse = 0
    }
    
    func state() -> WebSocketEventHandler {
        return m_wsc.state()
    }
    
//    public func close_really(reason: String) {
//        m_wsc?.close_really(reason: reason)
//    }
    
    func close(reason: String) {
        m_wsc.close(reason: reason)
    }
    
    func setQuit() {
        m_wsc.setQuit()
    }
    
    /// 直接送不記包
    func send_Direct(obj: Any) {
        if m_wsc.state() != .connected {
            return
        }
        if let message = obj as? String {
            m_wsc.send(message: message)
        } else if let data = obj as? Data {
            m_wsc.send(data: data)
        } else {
            print("send_Direct obj type is not ture !!!!!!")
        }
    }
    
    /// 直接送並且記錄包
    func send_DirectPack(ts: Int64, bt: Data) {
        m_SendTime = ts
        m_iWaitResponse = ts
        
        send_Direct(obj: bt)
        
        #warning("要再修改重送封包機制")
        mutex.wait()
        m_dicSendPack[ts] = bt
        mutex.signal()
    }
    
    func chkTime(nowUTC: Int64) {
        if state() == .connected && m_iWaitResponse > 0 {
            if nowUTC - m_iWaitResponse > (30 * 1000) {
                print("!! Server( \(String(describing: m_wsc.m_sURL)) )未回應要求 !!")
                m_iWaitResponse = 0
                m_wsc.close(reason: "Server超 \((30 * 1000) / 1000) 秒未回應")
                return
            }
        }
        
        // JSON // 有接CDN時才需要調短
        if nowUTC - m_SendTime > m_SendAliveTime { // > (2 * 1000) 之前的判斷
            m_SendTime = nowUTC
            let jStr = "{'cmd':'Alive'}"
            send_Direct(obj: jStr)
        }
    }
    
    /// 設定自己的已讀時戳及對方的已讀處理 'arg:對方的傳送時戳，已讀時戳
    func setTS(sendTS: Int64, readTS: Int64) {
        if sendTS > m_RecvTS {
            m_RecvTS = sendTS
        }
        if readTS >= m_iWaitResponse {
            m_iWaitResponse = 0
        }
        
        #warning("要再修改重送封包機制")
        // 將已讀以前的buffer清空
        mutex.wait()
        m_dicSendPack.keys.forEach {
            if $0 <= readTS {
                m_dicSendPack.removeValue(forKey: $0)
            }
        }
        mutex.signal()
    }
    
    /// 拿已接收的包的時戳
    public func getRTS() -> Int64 {
        return m_RecvTS
    }
    
    // 重連機制 ------------------------interval---------------------------------
    #warning("要再修改重送封包機制")
    func sendRepair(recvTS: Int64) {
        // 補送包 '將已讀以前的buffer清空，將未讀的再發送一次
        m_dicSendPack.keys.forEach {
            if $0 <= recvTS {
                print("-----清空以前的buffer-----")
                m_dicSendPack.removeValue(forKey: $0)
            } else {
                if let rebt = m_dicSendPack[$0] {
                    print("-----補送封包 \(recvTS)-----")
                    m_wsc.send(data: rebt)
                }
            }
        }
    }
}
