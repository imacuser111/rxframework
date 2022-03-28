//
//  CCComm.swift
//  
//
//  Created by Canry on 2021/11/5.
//

import Foundation
import RxCocoa
import RxSwift

/// 連線狀態
public let websocketConnectionTrigger = BehaviorRelay<Bool>(value: false)

// MARK: - websocket client common

public class CCComm {
    /// 試連3次
    private let TRY_MAX: Int = 3
    
    private var m_Player = CClientPlayer()
    
    var error = PublishRelay<(Int64?, Error?)>()
    
    var serverPackResponse = PublishRelay<Data>()
    
    private var disposeBag = DisposeBag()
    
    /// sysServ Model
    public let sysServ = CCCommModel(type: .sysServ)
    
    /// funcServ Mdoel
    public let funcServ = CCCommModel(type: .funcServ)
    
    private var m_SendAliveSec: Int = 60
    
    /// 暫存封包
    private var sendPack : Dictionary<UInt64, Data> = [:]
    
    /// token
    private var m_sAccount: String = ""
    
    deinit {
        print("deiniting \(self)")
    }
    
    init() {
        setupServBindings(serv: sysServ)
        setupServBindings(serv: funcServ)
    }
    
    public var player: CClientPlayer {
        return m_Player
    }
    
    /// 確認連線狀況
    #warning("感覺可以用websocketConnectionTrigger或是webSocketClient?.state()來判斷狀態")
    public func getServersStatus() -> (sysServIsConnect: Bool, FuncServIsConnect: Bool) {
        return (sysServ.m_dicConntServ.contains(where: { $0.key == sysServ.m_sInto }), funcServ.m_dicConntServ.contains(where: { $0.key == funcServ.m_sInto }))
    }
    
    /// websocket入口
    public func login(type: ServType, acct: String) {
        // 開啟timer
        RxWebSocketClient.sharedInstance.stopTimer(type: type)
        RxWebSocketClient.sharedInstance.startTimer(type: type)
        
        m_sAccount = acct
        let serv = type == .funcServ ? funcServ : sysServ
        let urls = type == .funcServ ? RxWebSocketClient.sharedInstance.funcServData.webSocketHostUrls : RxWebSocketClient.sharedInstance.sysServData.webSocketHostUrls
        setupURLs(serv: serv, urls: urls)
    }
    
    private func setupURLs(serv: CCCommModel, urls: [String]) {
        let currentPortal = urls.randomElement() ?? ""
        if serv.m_sInto == currentPortal {
            return
        }
        urls.forEach { portal in
            serv.m_dicServList[portal] = "FunctonType"
        }
        switchFuncServ(serv: serv, url: currentPortal)
    }
    
    /// 切換FuncServ url 線路
    private func switchFuncServ(serv: CCCommModel, url: String) {
        
        // 目前只做同時間只連一種功能Serv, 要切斷上一個FuncServ連線
        let connectServ: CToServer? = serv.connectServ
        if connectServ != nil {
            print("\(serv.servType) websocket QUITTT")
            #warning("這邊感覺有問題，有可能disposeBag還沒被釋放就再次綁定")
            connectServ?.sendQuit()
            serv.m_dicConntServ[serv.m_sInto] = nil // order1 ' 不做重連
            connectServ?.WScCommu.close(reason: "切換功能館") // order2
        }
        
        serv.m_sInto = url
        serv.m_iTryInto = 0
        serv.webSocketClient = CWebsocketClient(url: serv.m_sInto)
        conntServer(serv: serv)
    }
    
    /// 連線Server
    private func conntServer(serv: CCCommModel) {
        serv.m_iTryInto += 1
        #warning("感覺不用重設")
//        serv.webSocketClient?.m_sURL = serv.m_sInto
        serv.webSocketClient?.connect()
    }
    
    // private function ---------------------------internal------------------------------------
    private func setupServBindings(serv: CCCommModel) {
        // connect, result
        serv.webSocketTrigger.bind { [weak self] action in
            switch action {
            case .connected(let isconnected):
                self?.webSocketConnected(serv: serv, connected: isconnected)
            case .result(let res):
                self?.webSocketResult(serv, result: res)
            default:
                break
            }
        }.disposed(by: disposeBag)

        // response
        serv.webSocketTrigger.map { action in
            switch action {
            case .serverPackResponse(let data):
                return data
            default:
                return nil
            }
        }.compactMap { $0 }.bind(to: serverPackResponse).disposed(by: disposeBag)

        // error
        serv.webSocketTrigger.map { [weak self] action -> (Int64?, Error?) in
            switch action {
            case .error(let err):
                print("\(serv.servType) websocket 連線發生錯誤: ", err)
                // 發生錯誤就不進行重連
                self?.closePreviousSocket(serv)
//                self?.update(serv: serv)
                return (nil, WebSocketConnectionError.originError(err))
            default:
                return (nil, nil)
            }
        }.bind(to: error).disposed(by: disposeBag)
    }
    
    /// 拿已接收的包的時戳
    public func getRTS(_ serv: CCCommModel) -> Int64 {
        return serv.connectServ?.WScCommu.getRTS() ?? 0
    }
    
    private func closePreviousSocket(_ serv: CCCommModel) {
        print("\(serv.servType) websocket 中斷未正式斷線的websocket: \(serv.webSocketClient?.m_sURL ?? "")")
        serv.m_dicCloseServ.values.forEach { closeServ in
            closeServ.WScCommu.close(reason: "")
        }
        #warning("還要再測試")
//        serv.discServWebSocketClient?.close(reason: "")
        serv.webSocketClient?.close(reason: "")
    }
    
    /// 連線變關閉
    private func conntTurnClose(_ serv: CCCommModel, id: String) {
        if let conntServ = serv.m_dicConntServ[id] {
            serv.m_dicCloseServ[id] = conntServ
            serv.m_dicConntServ[id] = nil
        }
    }
    
    /// 關閉變連線
    private func closeTurnConnt(_ serv: CCCommModel, id: String) -> CToServer? {
        if let closeServ = serv.m_dicCloseServ[id] {
            serv.m_dicConntServ[id] = closeServ
            serv.m_dicCloseServ[id] = nil
            return closeServ
        }
        return nil
    }
    
    /// Rx專案用來發送request的方法
    public func send(serv: CCCommModel, data: Data) -> Observable<Void> {
        return Single<Void>.create { [weak self] single in
            if serv.webSocketClient?.state() != .connected {
                print("websocket 因連線異常正在重連，因此無法發送此封包")
                // MARK: 發錯誤
                single(.failure(WebSocketConnectionError.serverConnecting))
            }
            
            if let function = functionCall.sendOrRemovePackage {
                if let no = function(data) {
                    print("websocket 發送封包 \(no)")
                    self?.sendPack[UInt64(no)] = data
                    serv.connectServ?.WScCommu.send_DirectPack(ts: no, bt: data)
                } else {
                    serv.webSocketClient?.send(data: data)
                }
                single(.success(()))
            }
            return Disposables.create()
        }.asObservable()
    }
    
    // update -------------------------------internal-------------------------------
    /// 打心跳封包與重連呼叫的方法
    func update(serv: CCCommModel) {
        let m_dicConntServ = serv.m_dicConntServ
        let m_dicServList = serv.m_dicServList
        
        let nowUTC: Int64 = Date().currentTimeMillis()
        m_dicConntServ.values.forEach { serv in
            serv.WScCommu.chkTime(nowUTC: nowUTC)
        }
        
        let listURLs = m_dicServList.keys
        
        // 斷線重連
        if listURLs.isEmpty {
            // 全部嘗試重連還是失敗
            print("\(serv.servType) websocket 全部斷線")
            error.accept((nil, WebSocketConnectionError.connectionTimeout))
            serv.m_dicServList = serv.m_dicTriedServ
        } else if m_dicConntServ.isEmpty {
            let servList = listURLs.randomElement()
            if let url = servList {
                print("\(serv.servType) websocket Reconnecting \(String(describing: url)) \(serv.m_sInto)")
                
                serv.m_dicTriedServ[url] = servList
                serv.m_dicServList[url] = nil
                
                #warning("這邊要想一下，之後換線m_dicCloseServ[url]沒有值的話可能沒辦法發reconnect")
                serv.webSocketClient?.m_sURL = url
                serv.m_dicCloseServ[url]?.WScCommu.resetSendTimeAndWaitTime()
                serv.webSocketClient?.connect()
            }
        }
    }
    
    /// 確認封包是否逾時
    func checkPackages() {
        let sendPack = sendPack
        let currentTime = UInt64(Date().currentTimeMillis())
        sendPack.keys.forEach { key in
            // 超過30秒
            if currentTime - key > 30000 {
                print("websocket 封包 \(key) 逾時")
                print("websocket 移除逾時封包 \(key)")
                
                removePackage(packageID: key)
                
                error.accept((Int64(key), WebSocketConnectionError.packageLost))
            }
        }
    }
    
    /// 移除封包
    func removePackage(packageID: UInt64) {
        let sendPack = sendPack
        if sendPack.contains(where: { $0.key == packageID }) {
            self.sendPack[packageID] = nil
        }
    }
    
    /// 重新發送封包
    private func resendPackage(serv: CCCommModel) {
        let sendPack = sendPack
        sendPack.forEach { package in
            serv.connectServ?.WScCommu.send_DirectPack(ts: Int64(package.key), bt: package.value)
        }
    }
    
//    public func refreshProfiles() {
//        print("webscoket 頭像更新",player.currentProfileTimestamp)
//        let refreshProfilesRequest = RefreshProfilesWebSocketRequest(lastTimeStamp: (player.currentProfileTimestamp))
//
//        Observable.of(refreshProfilesRequest).sendRequest().success().subscribe(onNext:{ [weak self] res in
//            print("res",res.sts,",",res.rts,res.refreshProfileRes.aryProfile)
//            self?.player.currentProfileTimestamp = res.rts
//            if !res.refreshProfileRes.aryProfile.isEmpty{
//                if let profile = res.refreshProfileRes.aryProfile.first(where: {$0.mobilKey == self?.player.mobileKey}){
//                    UserDefaultsAdapter.userDataProfile = (profile.name, res.refreshProfileRes.imgURL(profile.mobilKey, imgTs: profile.imgTs))
//                }
//                NotificationCenter.default.post(name: .NT_ForumProfilesUpdate,
//                                                object: nil,
//                                                userInfo: ([Notification.Name.NT_ForumProfilesUpdate.rawValue: res.refreshProfileRes.wkAryProfile ?? []]))
//            }
//        }).disposed(by: disposeBag)
//    }
}

extension CCComm {
    private func webSocketConnected(serv: CCCommModel, connected: Bool) {
        // 連線成功
        if connected {
            serv.m_sInto = serv.webSocketClient?.m_sURL ?? ""
            
            serv.m_dicTriedServ.forEach { triedServ in
                serv.m_dicServList[triedServ.key] = triedServ.value
            }
            serv.m_dicTriedServ.removeAll()
            
            print("\(serv.servType) websocket 連線 \(String(describing: serv.webSocketClient?.m_sURL)) 成功")
            // 將重連次數歸0
            serv.m_iTryInto = 0
            
            let m_dicCloseServ = serv.m_dicCloseServ
            
            // 第一次登入
            if (!m_dicCloseServ.contains(where: { $0.key == serv.webSocketClient?.m_sURL })) || serv.m_itryReconnectCount >= TRY_MAX {
                // 重置reconnect次數
                serv.m_itryReconnectCount = 0
                
                // 登入Server
                print("\(serv.servType) websocket 發送Login")
                
                if let function = functionCall.login {
                    
                    let bt = function((serv.servType, m_sAccount))
                    serv.webSocketClient?.send(data: bt)
                }
            } else if serv.m_itryReconnectCount < TRY_MAX {
                // 一樣給予3次reconnect的機會，若都沒有持成功則走重新login
                serv.m_itryReconnectCount += 1
                
                // 已有登入過，重新連線
                print("\(serv.servType) websocket 發送Reconnect")
                
                #warning("這邊要想一下，之後換線m_dicCloseServ[url]沒有值的話可能沒辦法發reconnect")
                let closeServ: CToServer? = m_dicCloseServ[serv.webSocketClient?.m_sURL ?? ""]
                closeServ?.sendReconnect()
            }
        // 連線失敗
        } else {
            let m_dicCloseServ = serv.m_dicCloseServ
            let m_dicConntServ = serv.m_dicConntServ
            
            if m_dicConntServ.contains(where: { $0.key == serv.webSocketClient?.m_sURL }) || m_dicCloseServ.contains(where: { $0.key == serv.webSocketClient?.m_sURL }) { // 連線變關閉
                if serv.webSocketClient?.m_bQuitting == true {
                    
                    print("\(serv.servType) websocket 正在離開中的不再重連!!!!!")
                    
                    // 正在離開中的不再重連
                    serv.m_dicConntServ[serv.m_sInto] = nil
                    
                    // 清掉已登入的url
                    serv.m_sInto = ""
                    
                    // TODO: - 不重連要清掉webSocketClient
                    serv.webSocketClient = nil
                    
                    // 關閉Timer
                    RxWebSocketClient.sharedInstance.stopTimer(type: ServType.sysServ)
                    RxWebSocketClient.sharedInstance.stopTimer(type: ServType.funcServ)
                } else {
                    print("\(serv.servType) websocket 連線 \(String(describing: serv.webSocketClient?.m_sURL)) 中斷")
                    
                    // 進入重連
                    conntTurnClose(serv, id: serv.webSocketClient?.m_sURL ?? "")
                    
                    error.accept((nil, WebSocketConnectionError.serverConnecting))
                    
//                    serv.discServWebSocketClient = serv.webSocketClient
                    
                    switch serv.webSocketClient?.state() {
                    case .error(let error):
                        print("\(serv.servType) websocket Error: \(String(describing: error))")
                        self.error.accept((nil, WebSocketConnectionError.connectionError))
//                        self.update(serv: serv)
                    default:
                        if serv.m_iTryInto < TRY_MAX {
                            print("\(serv.servType) websocket 嘗試自動重新連線中...")
                            conntServer(serv: serv)
                        } else {
                            print("\(serv.servType) websocket 3次連線失敗")
                            self.error.accept((nil, WebSocketConnectionError.connectionError))
//                            self.update(serv: serv)
                        }
                    }
                }
            } else if (!m_dicCloseServ.contains(where: { $0.key == serv.webSocketClient?.m_sURL })) { // 尚未建立連線
                if serv.m_iTryInto < TRY_MAX {
                    print("\(serv.servType) websocket 重新連線中...")
                    conntServer(serv: serv)
                } else {
                    print("\(serv.servType) websocket 3次連線失敗")
//                    serv.discServWebSocketClient = serv.webSocketClient
                    conntTurnClose(serv, id: serv.webSocketClient?.m_sURL ?? "")
                    error.accept((nil, WebSocketConnectionError.connectionError))
                }
            }
        }
    }
    
    private func webSocketResult(_ serv: CCCommModel, result: Data) {
        // 新建立的連線
        if (!serv.m_dicConntServ.contains(where: { $0.key == serv.webSocketClient?.m_sURL })) {
            if let function = functionCall.loginPackageResult {
                let loginResult = function(result)
                switch loginResult {
                case .error(error: let error):
                    websocketConnectionTrigger.accept(false)
                    
                    print("\(serv.servType) websocket 封包發生錯誤:", error)
                    
                    // 發生錯誤就不再進行重連
                    serv.m_dicCloseServ[serv.webSocketClient?.m_sURL ?? ""] = CToServer(wsc: serv.webSocketClient ?? CWebsocketClient(url: ""),
                                                                                        sendAliveSec: m_SendAliveSec,
                                                                                        token: m_Player.m_sToken,
                                                                                        sservID: m_Player.m_iSServID)
//                    serv.discServWebSocketClient = serv.webSocketClient
                    closePreviousSocket(serv)
                    serv.webSocketClient?.close(reason: error.msg)
                    self.error.accept((nil, WebSocketResultErrorReason.responseError(msg: error.msg, code: error.code)))
                case .success(let succ):
                    switch serv.servType {
                    case .sysServ:
                        print("\(serv.servType) websocket ------System Login Succ---------")
                        
                        if let aliveSec = succ.aliveSec {
                            m_SendAliveSec = aliveSec
                        }
                        m_Player.setSData(succ)
                    case .funcServ:
                        print("\(serv.servType) websocket ------FuncServer Login Succ---------")
                        
                        m_Player.setFData(succ)
                    }
                    
                    websocketConnectionTrigger.accept(true)
                    
                    serv.m_dicConntServ[serv.webSocketClient?.m_sURL ?? ""] = CToServer(wsc: serv.webSocketClient ?? CWebsocketClient(url: ""),
                                                                                        sendAliveSec: m_SendAliveSec,
                                                                                        token: m_Player.m_sToken,
                                                                                        sservID: m_Player.m_iSServID)
                case .recnntSucc(let recvTs, let servID):
                    print("\(serv.servType) websocket ------Reconnect Success------")
                    websocketConnectionTrigger.accept(true)
                    // 補送封包
                    resendPackage(serv: serv)
                    let closeServ = closeTurnConnt(serv, id: serv.webSocketClient?.m_sURL ?? "")
                    closeServ?.WScCommu.sendRepair(recvTS: recvTs)
                    
                    //#Jas 20211229 //! 加分流識別ID
                    // TODO: - 換了新的System分流要通知FuncServ重新處理一次未處理包
                    if serv.servType == .sysServ {
                        if m_Player.m_iSServID != servID {
                            m_Player.m_iSServID = Int(servID)
                            closeServ?.m_mySServID = m_Player.m_iSServID
                            
                            #warning("還要再測試，不確定是不是funcServ")
                            // 連線中的funServ要送changeSystem
                            funcServ.m_dicConntServ.forEach {
//                                if $0.key != serv.webSocketClient?.m_sURL {
                                    $0.value.m_mySServID = m_Player.m_iSServID
                                    $0.value.sendChgSys()
//                                }
                            }
                            
                            // 斷線中的funServ要改m_mySServID
                            funcServ.m_dicCloseServ.forEach {
//                                if $0.key != serv.webSocketClient?.m_sURL {
                                    $0.value.m_mySServID = m_Player.m_iSServID
//                                }
                            }
                        }
                    }
                default:
                    websocketConnectionTrigger.accept(false)
                    print("\(serv.servType) websocket FuncServer \(String(describing: serv.webSocketClient?.m_sURL)) 給了非登入結果包")
                }
            }
        } else { // 已存在的連線
            if let conntServ = serv.connectServ {
                if let function = functionCall.serverPackageResult {
                    let args = function(conntServ, result)
                    
                    guard let sts = args.sts, let rts = args.rts else { return }
                    
                    conntServ.WScCommu.setTS(sendTS: sts, readTS: rts)
                    
                    switch args.result {
                    case .confirm:
                        conntServ.sendConfirm()
                    case .error(code: _, msg: let msg):
                        // 主動接收重新連線
                        if serv.m_iTryInto < TRY_MAX {
                            print("websocket 收到自動斷線 嘗試自動重新連線中...")
                            conntTurnClose(serv, id: serv.webSocketClient?.m_sURL ?? "")
//                            serv.discServWebSocketClient = serv.webSocketClient
                            closePreviousSocket(serv)
                            serv.webSocketClient?.close(reason: msg)
                            conntServer(serv: serv)
                        } else {
                            print("websocket 3次連線失敗")
                            error.accept((nil, WebSocketResultErrorReason.connectionError(error: WebSocketConnectionError.connectionError)))
//                            update(serv: serv)
                        }
                    case .kick:
                        print("\(serv.servType) websocket ------踢人-------")
                        conntServ.WScCommu.setQuit()
                        conntServ.WScCommu.close(reason: "\(serv.servType)踢人")
                    case .quitRes:
                        print("\(serv.servType) websocket ------Quit-------")
                        conntServ.WScCommu.close(reason: "自行離開")
                    case .unknown:
                        break
                    }
                }
            } else {
                print("websocket Res_Server已不在 id: \(String(describing: serv.webSocketClient?.m_sURL))")
            }
        }
    }
}
