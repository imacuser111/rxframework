//
//  ViewController.swift
//  ExampleWebSocket
//
//  Created by Cheng-Hong on 2021/12/29.
//

import UIKit
import RxSwift
import RxWebSocketPackage

class ViewController: UIViewController {
    
    private let rxWebSocketClient = RxWebSocketClient.sharedInstance
    
    private let disposeBag = DisposeBag()
    
    var flag = false
    
    var token = ""
    
    var refreshToken = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        rxWebSocketClient.sysServData.webSocketHostUrls = ["ws://172.28.15.29:23001", "ws://172.28.15.29:23111"]
        rxWebSocketClient.funcServData.webSocketHostUrls = ["ws://172.28.15.29:24001"]
        
        functionCall = FunctionClosureInstance(confirmFunc: { [weak self] conntServ in self?.confirmFuncClosure(conntServ) ?? Data() },
                                               reconnectFunc: { [weak self] closeServ in self?.reconnectFuncClosure(closeServ) ?? Data() },
                                               chgSysFunc: { [weak self] conntServ in self?.chgSysFuncClosure(conntServ) ?? (Int64(), Data()) },
                                               quitFunc: { [weak self] conntServ in self?.quitFuncClosure(conntServ) ?? (Int64(), Data()) },
                                               sendOrRemovePackage: { [weak self] data in self?.sendOrRemovePackageClosure(data) },
                                               loginPackageResult: { [weak self] result in self?.loginPackageResultClosure(result) ?? .unknown },
                                               serverPackageResult: { [weak self] (serv, result) in self?.serverPackageResultClosure(serv, result: result) ?? (nil, nil, .unknown) },
                                               login: { [weak self] (servType, acct) in self?.loginClosure(servType, acct: acct) ?? Data() })
        
        functionCall.entry(type: .sysServ, acct: "886-975512986")
        
        let btn = UIButton(type: .system)
        view.addSubview(btn)
        btn.setTitle("login", for: .normal)
        btn.frame = view.bounds
        view.backgroundColor = .white
        
        btn.rx.tap.bind { _ in
            functionCall.entry(type: .sysServ, acct: "886-975512986")
        }.disposed(by: disposeBag)
        
//        let testResponse = btn.rx.tap.asObservable().profiles().share()
//
//        testResponse.success().bind {
//            print("testResponse: \($0.profilesRes)")
//        }.disposed(by: disposeBag)
//
//        testResponse.fail().bind {
//            print("error: \($0) !!!!!!!!!")
//        }.disposed(by: disposeBag)
//
        let loginResponse = rxWebSocketClient.WebSocketComm.rx.serverPackResponse.map { (try? QPPProto_LoginResult(serializedData: $0)) ?? QPPProto_LoginResult() }.materialize().success().share()
        
        // 更新UserDefault Token
        loginResponse.subscribe(onNext: { [weak self] in
            switch $0.msg {
            case .ssucc(let succ):
                UserDefaultsAdapter.token = succ.token
                UserDefaultsAdapter.refreshToken = succ.refreshToken
            case .plssucc(let succ):
                self?.token = succ.token
                self?.refreshToken = succ.refreshToken
            default:
                return
            }
        }).disposed(by: disposeBag)
        
//        loginResponse.filter {
//            if case .plssucc(_) = $0.msg { return true }
//            return false
//        }.bind(onNext: { [weak self] _ in
//            if self?.flag == false {
//                self?.flag = true
//                print("sendQuit !!!!!!!")
//                self?.rxWebSocketClient.WebSocketComm.sysServ.connectServ?.sendQuit()
//            }
//        }).disposed(by: disposeBag)
        
        // 登出，清空token
        rxWebSocketClient.WebSocketComm.rx.serverPackResponse.map { (try? QPPProto_ServerPack(serializedData: $0)) ?? QPPProto_ServerPack() }.subscribe(onNext: {
            switch $0.msg {
            case .quitRes(_):
                UserDefaultsAdapter.token = ""
                UserDefaultsAdapter.refreshToken = ""
                
                print("登出，清空token !!!!!!!")
            default:
                break
            }
        }).disposed(by: disposeBag)
            
        // 手機登入成功，打驗證碼
        let verifyPreLoginResponse = loginResponse.filter { [weak self] in
            if case .plssucc(let succ) = $0.msg {
                self?.token = succ.token
                return true
            }
            return false
        }.map { _ in }.verifyPreLogin(code: 123456).share()

        // token登入
        let tokenLoginResponse = loginResponse.filter {
            if case .ssucc(_) = $0.msg { return true }
            return false
        }
        
        // 真正登入成功，記下token並打login funcServ
        Observable.merge(tokenLoginResponse.map { ($0.ssucc.token, $0.ssucc.refreshToken) }, verifyPreLoginResponse.success().map { [weak self] _ in (self?.token ?? "", self?.refreshToken ?? "") }).bind {
            UserDefaultsAdapter.token = $0.0
            UserDefaultsAdapter.refreshToken = $0.1
            functionCall.entry(type: .funcServ)
        }.disposed(by: disposeBag)
        
        verifyPreLoginResponse.success().subscribe(onNext: {
            print("verifyPreLoginResponse: \($0.verifyPreLoginRes)")
        }).disposed(by: disposeBag)

        verifyPreLoginResponse.fail().subscribe(onNext: {
            print("verifyPreLoginResponse error: \($0)")
        }).disposed(by: disposeBag)

        // 驗證碼成功，創建帳號(新用戶) or 創建uname(舊用戶)
        let createAccountResponse = verifyPreLoginResponse.success().filter { $0.verifyPreLoginRes.needData == .create }.map { _ in }.createAccount(uname: "Cheng3").share()

        createAccountResponse.success().subscribe(onNext: {
            print("createAccountResponse: \($0.createAcctRes)")
        }).disposed(by: disposeBag)

        createAccountResponse.fail().subscribe(onNext: {
            print("createAccountResponse error: \($0)")
        }).disposed(by: disposeBag)

        // funcServ登入成功，取得個人資訊
        let profilesResponse = rxWebSocketClient.WebSocketComm.rx.serverPackResponse.map { (try? QPPProto_LoginResult(serializedData: $0)) ?? QPPProto_LoginResult() }.materialize().success().filter {
            switch $0.msg {
            case .fsucc(_):
                return true
            default:
                return false
            }
        }.map { _ in }.profiles().share()

        profilesResponse.success().subscribe(onNext: {
            print("profilesResponse: \($0.profilesRes)")
        }).disposed(by: disposeBag)

        profilesResponse.fail().subscribe(onNext: {
            print("profilesResponse error: \($0)")
        }).disposed(by: disposeBag)
        
        rxWebSocketClient.WebSocketComm.rx.error.map { args -> WebSocketResultErrorReason? in
            if let error = args.1 as? WebSocketResultErrorReason {
                return error
            }
            return nil
        }.filter { $0?.isTokenInvalid == true }.bind { [weak self] _ in
            print("token失效 !!!!!!!")
            self?.rxWebSocketClient.WebSocketComm.sysServ.webSocketClient?.setQuit()
        }.disposed(by: disposeBag)
    }
}

extension ViewController {
    private func confirmFuncClosure(_ conntServ: CToServer) -> Data {
        var clientPK = QPPProto_ClientPack()
        clientPK.sts = 0
        clientPK.rts = conntServ.WScCommu.getRTS()
        clientPK.confirmRes = QPPProto_ClientPack.ReadConfirmResult()
        
        return (try? clientPK.serializedData()) ?? Data()
    }
    
    private func reconnectFuncClosure(_ closeServ: CToServer) -> Data {
        var loginPK = QPPProto_Login()
        loginPK.recnnt = QPPProto_Login.Reconnect()
        loginPK.recnnt.dkind = .ios
        loginPK.recnnt.token = closeServ.m_myToken
        loginPK.recnnt.recvTs = closeServ.WScCommu.getRTS()
        loginPK.recnnt.sservID = Int32(closeServ.m_mySServID) //#Jas 20211229 //! 加分流識別ID
        
        return (try? loginPK.serializedData()) ?? Data()
    }
    
    private func chgSysFuncClosure(_ conntServ: CToServer) -> (Int64, Data) {
        var clientPK = QPPProto_ClientPack()
        clientPK.sts = Date().currentTimeMillis()
        clientPK.rts = conntServ.WScCommu.getRTS()
        clientPK.changeSys = QPPProto_ClientPack.ChangeSystem()
        clientPK.changeSys.sservID = Int32(conntServ.m_mySServID)
        
        return (clientPK.sts, (try? clientPK.serializedData()) ?? Data())
    }
    
    private func quitFuncClosure(_ conntServ: CToServer) -> (Int64, Data) {
        var clientPK = QPPProto_ClientPack()
        clientPK.sts = Date().currentTimeMillis()
        clientPK.rts = conntServ.WScCommu.getRTS()
        clientPK.quit = QPPProto_ClientPack.Quit()
        
        return (clientPK.sts, (try? clientPK.serializedData()) ?? Data())
    }
    
    // MARK: - login and get result
    
    private func loginClosure(_ type: ServType, acct: String) -> Data {
        switch type {
        case .sysServ:
            if UserDefaultsAdapter.token.isEmpty {
                // 手機登入
                let request = PreLoginSysWebSocketRequest(acct: acct)
                return request.body
            } else {
                // token登入SysServer
                let request = LoginSysWebSocketRequest(token: UserDefaultsAdapter.token, refreshToken: UserDefaultsAdapter.refreshToken)
                return request.body
            }
        case .funcServ:
            // 登入FuncServ
            let request = LoginFServWebSocketRequest()
            return request.body
        }
    }
    
    private func loginPackageResultClosure(_ result: Data) -> LoginResult {
        guard let res: QPPProto_LoginResult = try? QPPProto_LoginResult(serializedData: result) else { return .unknown }
        
        switch res.msg {
        case .error(let error):
            return .error(code: error.code.rawValue, msg: error.msg)
        case .plssucc(let succ):
            return .success(LoginResultSuccess(token: succ.token, servID: Int(succ.sservID), aliveSec: Int(succ.aliveSec)))
        case .ssucc(let succ):
            return .success(LoginResultSuccess(token: succ.token, nick: succ.nick, servID: Int(succ.sservID), aliveSec: Int(succ.aliveSec)))
        case .fsucc(let succ):
            return .success(LoginResultSuccess(nick: succ.nick, servID: Int(succ.fservID)))
        case .recnntSucc(let recnntSucc):
            return .recnntSucc(recvTs: recnntSucc.recvTs, servID: recnntSucc.servID)
        case .none:
            return .unknown
        }
    }
    
    private func serverPackageResultClosure(_ conntServ: CToServer, result: Data) -> (Int64?, Int64?, ServerResult) {
        guard let servPK: QPPProto_ServerPack = try? QPPProto_ServerPack(serializedData: result) else { return (nil, nil, .unknown) }
        
        var serverResult: ServerResult = .unknown
        
        switch servPK.msg {
        case .confirm(_):
            serverResult = .confirm
        case .error(let error):
            if error.code == .notLoginWs {
                serverResult = .error(code: error.code.rawValue, msg: error.msg)
            } else {
                print("websocket \(conntServ.WScCommu.m_wsc.m_sURL) Error: \(servPK.error.msg)")
                serverResult = .unknown
            }
        case .kick(_):
            print("websocket \(conntServ.WScCommu.m_wsc.m_sURL) Kick: \(servPK.kick.msg) sendTime: \(servPK.sts)")
            serverResult = .kick
        case .quitRes(_):
            serverResult = .quitRes
        case .verifyPreLoginRes(let res as ResultCode), .createAcctRes(let res as ResultCode), .profilesRes(let res as ResultCode):
            if res.code == .ok {
                #warning("這邊應該不用刪掉，RxWebSocketManager有砍掉了")
//                rxWebSocketClient.WebSocketComm.removePackage(packageID: UInt64(servPK.rts))
//                print("websocket \(servPK.msg.self)")
            }
            serverResult = .unknown
        default:
            serverResult = .unknown
        }
        
        return (servPK.sts, servPK.rts, serverResult)
    }
    
    // MARK: - send or remove package
    private func sendOrRemovePackageClosure(_ data: Data) -> Int64? {
        if let cp = try? QPPProto_ClientPack(serializedData: data) {
            switch cp.msg {
            // 驗證碼這包不能放入記錄包
            case .verifyPreLogin(_):
                return nil
            default:
                return cp.no
            }
        }
        return nil
    }
}

extension WebSocketResultErrorReason {
    var isTokenInvalid: Bool {
        switch self {
        case .connectionError(_):
            return false
        case .responseError(_, let code):
            if QPPProto_ECode(rawValue: code) == .tokenInvalid {
                return true
            }
            return false
        }
    }
}

protocol ResultCode {
    var code: QPPProto_ECode { get }
    var msg: String { get }
}

extension QPPProto_ServerPack.VerifyPreLoginResult: ResultCode {}
extension QPPProto_ServerPack.CreateAccountResult: ResultCode {}
extension QPPProto_ServerPack.ProfilesResult: ResultCode {}

private extension Observable where Element == Void {
    func preLoginSys(acct: String, isCreate: Bool) -> Observable<Event<QPPProto_ServerPack>> {
        return map { _ -> WebSocketRequestProtocol in
            let request = PreLoginSysWebSocketRequest(acct: acct)
            return request
        }.sendRequest().share()
    }
    
    func verifyPreLogin(code: Int32) -> Observable<Event<QPPProto_ServerPack>> {
        return map { _ -> WebSocketRequestProtocol in
            let request = VerifyPreLoginWebSocketRequest(code: code)
            return request
        }.sendRequest().share()
    }
    
    func createAccount(uname: String) -> Observable<Event<QPPProto_ServerPack>> {
        return map { _ -> WebSocketRequestProtocol in
            let request = CreateAccountWebSocketRequest(uname: uname)
            return request
        }.sendRequest().share()
    }
    
    func profiles() -> Observable<Event<QPPProto_ServerPack>> {
        return map { _ -> WebSocketRequestProtocol in
            let request = ProfilesWebSocketRequest()
            return request
        }.sendRequest().share()
    }
}
