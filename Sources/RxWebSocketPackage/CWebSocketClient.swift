//
//  CWebSocketClient.swift
//  
//
//  Created by Canry on 2021/11/5.
//

import Foundation
import Starscream
import RxSwift

public class CWebsocketClient {
    /// 當唯一ID用，reconnect的時候用
    public var m_sURL: String
    
    /// 各平台自己的websocket元件
    private(set) var m_ws: WebSocket
    
    private var disposeBag = DisposeBag()
    
    /// 接收m_ws(webSocket)的動作
//    let webSocketTrigger = PublishSubject<WebSokcetAction>()
    
    /// 用來記發送登出的flag
    private(set) var m_bQuitting: Bool = false
    
    // TODO: - 這個好像是server用來確認是否開啟一些權限憑證用，我們用不到
    private var m_bSSL: Bool = false
    
    // -----------不知道用在哪裡的參數-----------
    /// for FuncServ used
    private let m_iSysServID: Int?
    
    deinit {
        print("deiniting \(self)")
    }
    
    init(url: String, servID: Int? = nil) {
        m_sURL = url
        m_iSysServID = servID
        
        var request = URLRequest(url: URL(string: url)!)
        request.timeoutInterval = 5
        m_ws = WebSocket(request: request)
        
        // TODO: - 這個好像是server用來確認是否開啟一些權限憑證用，我們用不到
        if url.contains("wss") {
            m_bSSL = true
        }
    }
    
    func state() -> WebSocketEventHandler {
        return m_ws.state
    }
    
    func connect() {
//        m_ws.disconnect()
//        m_ws = nil
//        var request = URLRequest(url: URL(string: m_sURL)!)
//        request.timeoutInterval = 5
//        m_ws = WebSocket(request: request)
//        m_ws.connect()
        
        m_ws.disconnect()
        m_ws.request.url = URL(string: m_sURL)
        m_ws.connect()
    }
    
    func close(reason: String) {
        m_ws.disconnect(closeCode: CloseCode.normal.rawValue)
    }
    
//    public func close_really(reason: String) {
//        m_ws.disconnect(closeCode: CloseCode.goingAway.rawValue)
//
//        // 真的離開不再重連, 清掉id
//        m_sURL = ""
//    }
    
    public func setQuit() {
        m_bQuitting = true
    }
    
    func send(message: String) {
        m_ws.write(string: message)
    }
    
    func send(data: Data) {
        m_ws.write(data: data)
    }
}

//extension CWebsocketClient {
//    enum WebSokcetAction {
//        case connected(Bool)
//        case error(Error)
//        case serverPackResponse(Data)
//        case result(Data)
//    }
//
//    // private function ---------------------------internal------------------------------------
//    /// binding webSocket trigger
//    private func setupBindings() {
//        m_ws.rx.connected.distinctUntilChanged().observe(on: MainScheduler.instance).map { WebSokcetAction.connected($0) }.bind(to: webSocketTrigger).disposed(by: disposeBag)
//
//        m_ws.rx.error.compactMap { $0 }.map { WebSokcetAction.error($0) }.bind(to: webSocketTrigger).disposed(by: disposeBag)
//
//        m_ws.rx.serverPackResponse.map { WebSokcetAction.serverPackResponse($0) }.bind(to: webSocketTrigger).disposed(by: disposeBag)
//
//        m_ws.rx.result.map { WebSokcetAction.result($0) }.bind(to: webSocketTrigger).disposed(by: disposeBag)
//    }
//}
