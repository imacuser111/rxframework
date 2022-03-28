//
//  RxWebSocketManager.swift
//  
//
//  Created by Canry on 2021/11/5.
//

import Foundation
import RxSwift
import RxCocoa
import Starscream

public var functionCall = FunctionClosureInstance() // 與project溝通的colsure

public class RxWebSocketClinetModel {
    public var webSocketHostUrls: [String] = [] // ["ws://172.28.15.29:22001"]
    
    var timer: Timer?
    
    var timerCount = 0
    
//    private var refreshProfileCount = 0
}

public class RxWebSocketClient: NSObject {
    
    public static let sharedInstance = RxWebSocketClient()
    
    public let WebSocketComm = CCComm()
    
    public let sysServData = RxWebSocketClinetModel()
    
    public let funcServData = RxWebSocketClinetModel()
    
//    public var refreshProfileTrigger: Bool = false
    
    override init() {
        super.init()
    }
    
    func startTimer(type: ServType) {
        let data = type == .sysServ ? sysServData : funcServData
        
        data.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            self?.update(type: type)
        })
    }
    
    func stopTimer(type: ServType) {
        let data = type == .sysServ ? sysServData : funcServData
        
        data.timer?.invalidate()
        
        data.timer = nil
    }
    
    private func update(type: ServType) {
        let data = type == .sysServ ? sysServData : funcServData
        
        data.timerCount += 1
        
//        if refreshProfileTrigger {
//            refreshProfileCount += 1
//        }
        
        // 15秒檢查封包
        if data.timerCount == 15 {
            WebSocketComm.checkPackages()
            data.timerCount = 0
        }
        
//        // 1分鐘更新profile
//        if refreshProfileCount == 60 {
//            WebSocketComm.refreshProfiles()
//            refreshProfileCount = 0
//        }
        
        // 每一秒打心跳+確定連線
        type == .sysServ ? WebSocketComm.update(serv: WebSocketComm.sysServ) : WebSocketComm.update(serv: WebSocketComm.funcServ)
    }
}

public enum WebSocketEventHandler: Equatable {
    case connected
    case error(Error?)
    case disconnected
    case message(String)
    case data(Data)
    case pong
    
    public static func == (lhs: WebSocketEventHandler, rhs: WebSocketEventHandler) -> Bool {
        switch (lhs, rhs) {
        case (connected, connected), (error(_), error(_)), (disconnected, disconnected), (message(_), message(_)), (data(_), data(_)), (pong, pong):
            return true
        default:
            return false
        }
    }
}

public class RxWebSocketDelegateProxy<Client: WebSocket>: DelegateProxy<Client, NSObjectProtocol>, DelegateProxyType, WebSocketDelegate {

    let subject = PublishSubject<WebSocketEventHandler>()
    
    let serverPackResponse = PublishSubject<Data>()

    var event: WebSocketEventHandler = .disconnected

    required public init(websocket: Client) {
        super.init(parentObject: websocket, delegateProxy: RxWebSocketDelegateProxy.self)
    }
    
    public static func currentDelegate(for object: Client) -> NSObjectProtocol? {
        return object.delegate as? NSObjectProtocol
    }

    public static func setCurrentDelegate(_ delegate: NSObjectProtocol?, to object: Client) {
        object.delegate = delegate as? WebSocketDelegate
    }
    
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(_):
            self.event = WebSocketEventHandler.connected
            subject.onNext(WebSocketEventHandler.connected)
            
        case .text(let string):
            self.event = WebSocketEventHandler.connected
            subject.onNext(WebSocketEventHandler.message(string))
            
        case .binary(let data):
            self.event = WebSocketEventHandler.connected
            subject.onNext(WebSocketEventHandler.data(data))
            serverPackResponse.onNext(data)
            
            if let function = functionCall.sendOrRemovePackage, let no = function(data) {
                // 接到response後，將之前發送時存的sendPackage移除
                RxWebSocketClient.sharedInstance.WebSocketComm.removePackage(packageID: UInt64(no))
            }
            
        case .pong(_):
            self.event = WebSocketEventHandler.pong
            subject.onNext(WebSocketEventHandler.connected)
            
        case .error(let error):
            self.event = WebSocketEventHandler.error(error)
            subject.onNext(WebSocketEventHandler.error(error))
            
        case .disconnected(_, _):
            self.event = WebSocketEventHandler.disconnected
            subject.onNext(WebSocketEventHandler.disconnected)
            
        case .cancelled,.reconnectSuggested(_):
            self.event = WebSocketEventHandler.disconnected
            subject.onNext(WebSocketEventHandler.disconnected)
            
        default:
            self.event = WebSocketEventHandler.connected
            break
        }
    }
    
    public static func registerKnownImplementations() {
        self.register { RxWebSocketDelegateProxy(websocket: $0) }
    }

    deinit {
        subject.onCompleted()
    }
}

extension CCComm: ReactiveCompatible { }

public extension Reactive where Base: CCComm {
    
    var serverPackResponse: Observable<Data> {
        return base.serverPackResponse.asObservable()
    }
    
    var error: Observable<(Int64?, Error?)> {
        return base.error.asObservable()
    }
}

extension WebSocket {
    var state: WebSocketEventHandler {
        return RxWebSocketDelegateProxy.proxy(for: self).event
    }
}

extension WebSocket: ReactiveCompatible { }

extension Reactive where Base: WebSocket {
    
    public var delegate : DelegateProxy<WebSocket, NSObjectProtocol> {
        return RxWebSocketDelegateProxy.proxy(for: base)
    }

    var response: Observable<WebSocketEventHandler> {
        return RxWebSocketDelegateProxy.proxy(for: base).subject
    }
    
    var serverPackResponse: Observable<Data> {
        return RxWebSocketDelegateProxy.proxy(for: base).serverPackResponse
    }
    
    /// 只有成功進來的資料
    var result: Observable<Data> {
        return response.filter {
            switch $0 {
            case .data(_):
                return true
            default:
                return false
            }
        }.map { type -> Data in
            switch type {
            case .data(let data):
                return data
            default:
                return Data()
            }
        }
    }
    
    /// 只有錯誤
    var error: Observable<Error?> {
        return response.filter {
            switch $0 {
            case .error(_):
                return true
            default:
                return false
            }
        }.map { type -> Error? in
            switch type {
            case .error(let error):
                return error
            default:
                return nil
            }
        }
    }
    
//    public var text: Observable<String> {
//        return response
//            .filter {
//                switch $0 {
//                case .message(_):
//                    return true
//                default:
//                    return false
//                }
//            }
//            .map {
//                switch $0 {
//                case .message(let message):
//                    return message
//                default:
//                    return String()
//                }
//        }
//    }

    public var connected: Observable<Bool> {
        return response
            .filter {
                switch $0 {
                case .connected, .disconnected, .pong:
                    return true
                default:
                    return false
                }
            }
            .map {
                switch $0 {
                case .connected, .pong:
                    return true
                default:
                    return false
                }
        }
    }

    public func write(data: Data) -> Observable<Void> {
        return Observable.create { sub in
            self.base.write(data: data) {
                sub.onNext(())
                sub.onCompleted()
            }

            return Disposables.create()
        }
    }

    public func write(ping: Data) -> Observable<Void> {
        return Observable.create { sub in
            self.base.write(ping: ping) {
                sub.onNext(())
                sub.onCompleted()
            }

            return Disposables.create()
        }
    }

    public func write(string: String) -> Observable<Void> {
        return Observable.create { sub in
            self.base.write(string: string) {
                sub.onNext(())
                sub.onCompleted()
            }

            return Disposables.create()
        }
    }
}
