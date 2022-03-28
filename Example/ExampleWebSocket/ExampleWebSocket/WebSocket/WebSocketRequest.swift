//
//  WebSocketRequest.swift
//  ExampleWebSocket
//
//  Created by Cheng-Hong on 2022/1/6.
//

import Foundation
import RxSwift
import RxWebSocketPackage

enum WebSocketRequestType {
    case ReadConfirmResult
    case Reconnect
    case ChangeSystem
    case LoginSys
    case PreLoginSys
    case VerifyPreLogin
    case CreateAccount
    case LoginFServ
    case Profiles
}

protocol WebSocketRequestProtocol {
    var serv: CCCommModel { get }
    var method: WebSocketRequestType { get }
    var body: Data { get }
    var timeStamp: Int64 { set get }
}

extension Observable where Element == WebSocketRequestProtocol {
    func sendRequest() -> Observable<Event<QPPProto_ServerPack>> {
        return flatMap { request -> Observable<Event<QPPProto_ServerPack>> in
            // 防止打二次(complted會再打一次)
            let response = RxWebSocketClient.sharedInstance.WebSocketComm.send(serv: request.serv, data: request.body).materialize().filter{ !$0.isCompleted }
            
            let serverPackageErrorInMaterialize = RxWebSocketClient.sharedInstance.WebSocketComm.rx.error.filter{ $0.0 != nil && $0.0 == request.timeStamp }.compactMap{ $0.1 }.flatMap{ err -> Observable<QPPProto_ServerPack> in
                return Observable<QPPProto_ServerPack>.error(err)
            }.materialize()
            
            let resposneInMaterialize = response.flatMap{ event -> Observable<Event<QPPProto_ServerPack>> in
                if let err = event.error {
                    return Observable<QPPProto_ServerPack>.error(err).materialize()
                }
                return RxWebSocketClient.sharedInstance.WebSocketComm.rx.serverPackResponse.map { (try? QPPProto_ServerPack(serializedData: $0)) ?? QPPProto_ServerPack() }.filter{ $0.no == request.timeStamp }.materialize()
            }
            return Observable<Event<QPPProto_ServerPack>>.merge(serverPackageErrorInMaterialize,
                                                                resposneInMaterialize)
        }.share()
    }
}

extension WebSocketRequestProtocol {
    func convertToData(request: Any, timeStamp: Int64) -> Data {
        var clientPack = QPPProto_ClientPack.with {
            $0.rts = RxWebSocketClient.sharedInstance.WebSocketComm.getRTS(serv)
            $0.sts = timeStamp
            $0.no = timeStamp
        }
        
        switch method {
        case .ReadConfirmResult:
            // 發送確認
            guard let res = request as? QPPProto_ClientPack.ReadConfirmResult else { return Data() }
            clientPack.confirmRes = res
        case .Reconnect:
            // 重新連線
            guard let res = request as? QPPProto_Login.Reconnect else { return Data() }
            let loginPK = QPPProto_Login.with {
                $0.recnnt = res
            }
            return (try? loginPK.serializedData()) ?? Data()
        case .ChangeSystem:
            // 換了新的System分流要通知FuncServ重新處理一次未處理包(for sysServ)
            guard let res = request as? QPPProto_ClientPack.ChangeSystem else { return Data() }
            clientPack.changeSys = res
        case .LoginSys:
            // token登入SysServer
            guard let res = request as? QPPProto_Login.LoginSys else { return Data() }
            let loginPK = QPPProto_Login.with {
                $0.ls = res
            }
            return (try? loginPK.serializedData()) ?? Data()
        case .PreLoginSys:
            // 手機登入SysServer
            guard let res = request as? QPPProto_Login.PreLoginSys else { return Data() }
            let loginPK = QPPProto_Login.with {
                $0.pls = res
            }
            return (try? loginPK.serializedData()) ?? Data()
        case .LoginFServ:
            // 登入FuncServ
            guard let res = request as? QPPProto_Login.LoginFServ else { return Data() }
            let loginPK = QPPProto_Login.with {
                $0.lf = res
            }
            return (try? loginPK.serializedData()) ?? Data()
        case .VerifyPreLogin:
            guard let res = request as? QPPProto_ClientPack.VerifyPreLogin else { return Data() }
            clientPack.verifyPreLogin = res
        case .CreateAccount:
            guard let res = request as? QPPProto_ClientPack.CreateAccount else { return Data() }
            clientPack.createAcct = res
        case .Profiles:
            guard let res = request as? QPPProto_ClientPack.Profiles else { return Data() }
            clientPack.profiles = res
        }
        return (try? clientPack.serializedData()) ?? Data()
    }
}

extension Observable where Element == Event<QPPProto_LoginResult> {
    func success() -> Observable<QPPProto_LoginResult> {
        return compactMap{ $0.element }
    }
    
    func fail() -> Observable<Error> {
        return compactMap{ $0.error }
    }
}

extension Observable where Element == Event<QPPProto_ServerPack> {
    func success() -> Observable<QPPProto_ServerPack> {
        return compactMap{ $0.element }.filter{ res in
            switch res.msg {
            case .confirm(_), .kick(_), .quitRes(_), .error(_):
                return false
            case .verifyPreLoginRes(let res as ResultCode), .createAcctRes(let res as ResultCode), .profilesRes(let res as ResultCode):
                if res.code == .ok {
                    return true
                }
                return false
            default:
                return false
            }
        }
    }
    
    func fail() -> Observable<Error> {
        return Observable<Error>.merge(compactMap { $0.error }.map { WebSocketConnectionError.originError($0) },
                                       compactMap { $0.element }.filter { res in
            switch res.msg {
            case .confirm(_), .kick(_), .quitRes(_):
                return false
            case .error(_):
                return true
            case .verifyPreLoginRes(let res as ResultCode), .createAcctRes(let res as ResultCode), .profilesRes(let res as ResultCode):
                if res.code == .ok {
                    return false
                }
                return true
            default:
                return false
            }
        }.map { res -> Error? in
            switch res.msg {
            case .confirm(_), .kick(_), .quitRes(_):
                return nil
            case .error(let err):
                return WebSocketResultErrorReason.responseError(msg: err.msg, code: err.code.rawValue)
            case .verifyPreLoginRes(let res as ResultCode), .createAcctRes(let res as ResultCode), .profilesRes(let res as ResultCode):
                if res.code == .ok {
                    return nil
                }
                return WebSocketResultErrorReason.responseError(msg: res.msg, code: res.code.rawValue)
            default:
                return nil
            }
        }.compactMap{ $0 })
    }
}
