//
//  CCCommModel.swift
//  RxWebSocketPackage
//
//  Created by Cheng-Hong on 2021/12/30.
//

import Foundation
import RxSwift

public enum WebSocketConnectionError: Error {
    case connectionTimeout
    case connectionError
    case packageLost
    case serverConnecting
    case originError(Error)
    
    var errorCode: Int {
        switch self {
        case .connectionTimeout:
            return -1000
        case .connectionError:
            return -1001
        case .packageLost:
            return -1002
        case .serverConnecting:
            return -1003
        case .originError(_):
            return -1004
        }
    }
}

public enum WebSocketResultErrorReason: Error {
    case connectionError(error: WebSocketConnectionError)
    
    case responseError(msg: String, code: Int)
}

public enum ServType {
    case sysServ
    case funcServ
}

public enum LoginResult {
    case error(code: Int, msg: String)
    case success(LoginResultSuccess)
    case recnntSucc(recvTs: Int64, servID: Int32)
    case unknown
}

public struct LoginResultSuccess {
    var token: String?
    var nick: String?
    var servID: Int
    var aliveSec: Int?
    
    public init(token: String? = nil, nick: String? = nil, servID: Int, aliveSec: Int? = nil) {
        self.token = token
        self.nick = nick
        self.servID = servID
        self.aliveSec = aliveSec
    }
}

public enum ServerResult {
    case confirm
    case error(code: Int, msg: String)
    case kick
    case quitRes
    case unknown
}

// MARK: - CCCommModel

public class CCCommModel {
    /// 連線成功 dictionary (key: server url)
    var m_dicConntServ: Dictionary<String, CToServer> = [:]
    
    /// 連線失敗 dictionary
    var m_dicCloseServ: Dictionary<String, CToServer> = [:]
    
    /// 連線路徑  dictionary <key: url, value: FunctionType>
    var m_dicServList: Dictionary<String, String> = [:]
    
    /// 嘗試連線的 dictionary <key: url, value: FunctionType>
    var m_dicTriedServ: Dictionary<String, String> = [:]
    
    //計算用 ---------------------------------------------------------------
    
    #warning("感覺用不到")
    /// function server URL  ' 玩家選擇要進的功能伺服
//    private var m_sSelect = ""
    
    /// server URL '登入的系統伺服
    var m_sInto = ""
    
    /// 試連3次還失敗才跳"目前無法連線，請候稍再試"訊息窗
    var m_iTryInto = 0
    
    #warning("reconeect bug 解掉後，應該用不到了")
    var m_itryReconnectCount = 0
    
    // TODO: Change to default(_) if this is not a reference type
    public var webSocketClient: CWebsocketClient? = nil {
        didSet {
            disposeBag = DisposeBag()
            if webSocketClient != nil {
                setupBindings()
            }
        }
    }
    
    /// 上一條連線的webSocket
//    var discServWebSocketClient: CWebsocketClient? = nil
    
    var disposeBag = DisposeBag()
    
    /// 接收m_ws(webSocket)的動作
    let webSocketTrigger = PublishSubject<WebSokcetAction>()
    
    /// 連線中的線
    public var connectServ: CToServer? {
        m_dicConntServ[m_sInto]
    }
    
    let servType: ServType
    
    init(type: ServType) {
        servType = type
    }
}

extension CCCommModel {
    enum WebSokcetAction {
        case connected(Bool)
        case error(Error)
        case serverPackResponse(Data)
        case result(Data)
    }
    
    // private function ---------------------------internal------------------------------------
    /// binding webSocket trigger
    private func setupBindings() {
        webSocketClient?.m_ws.rx.connected.distinctUntilChanged().observe(on: MainScheduler.instance).map { WebSokcetAction.connected($0) }.bind(to: webSocketTrigger).disposed(by: disposeBag)

        webSocketClient?.m_ws.rx.error.compactMap { $0 }.map { WebSokcetAction.error($0) }.bind(to: webSocketTrigger).disposed(by: disposeBag)

        webSocketClient?.m_ws.rx.serverPackResponse.map { WebSokcetAction.serverPackResponse($0) }.bind(to: webSocketTrigger).disposed(by: disposeBag)

        webSocketClient?.m_ws.rx.result.map { WebSokcetAction.result($0) }.bind(to: webSocketTrigger).disposed(by: disposeBag)
    }
}
