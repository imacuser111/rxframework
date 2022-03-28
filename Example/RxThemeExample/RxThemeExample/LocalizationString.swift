//
//  LocalizationString.swift
//  RxSample
//
//  Created by user on 2022/3/25.
//

import Foundation

typealias LanguageString = String

/// 跟UserDefault取得語系的設定
var defaultLanguage = "WatchDefaultLanguage"

var currentLanguage :LanguageString = Bundle.main.preferredLocalizations.first ?? ""

enum Localization {
    static func string(_ key: String) -> String {
        if key != "" {
            if currentLanguage == LanguageList.systemSetting.titleName{
                return key.localized(LanguageList.systemSetting.languageCode)
            }
            return key.localized(currentLanguage)
        }
        return ""
    }
}

extension String{
    func localized()->String{
        return Localization.string(self)
    }
    
    func localized(_ lang:String) ->String{
        let path = Bundle.main.path(forResource: "Resource.bundle/"+lang, ofType: "lproj")
        guard let sourcePath = path else {return ""}
        let bundle = Bundle(path: sourcePath)

        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
    
    func localizedCountry(_ lang:String) ->String{
        let path = Bundle.main.path(forResource: "Resource.bundle/"+lang, ofType: "lproj")
        guard let sourcePath = path else {return ""}
        let bundle = Bundle(path: sourcePath)
        
        return NSLocalizedString(self, tableName: "CountryCode", bundle: bundle!, value: "", comment: "")
    }
}



//英文、繁中、簡中、日語、韓語、越南語、泰語、印尼語
enum LanguageList : CaseIterable{
    ///系統設定
    case systemSetting
    ///繁體中文
    case chineseTrad
    ///簡體中文
    case chineseSimp
    ///英文
    case english
    ///日文
    case japanese
    ///韓文
    case korean
    ///越南
    case vietnam
    ///泰文
    case thailand
    ///印尼文
    case indonesia
    
    var titleName: String{
        return String(describing: self)
    }
    
    var deadLanguagetext: String{
        switch self{
        case .systemSetting:
            return Localization.string("ID_DeviceLanguage")
        case .chineseTrad:
            return "中文(繁體)"
        case .chineseSimp:
            return "中文(简体)"
        case .english:
            return "English"
        case .japanese:
            return "日本語"
        case .korean:
            return "한국어"
        case .vietnam:
            return "越南"
        case .thailand:
            return "泰國"
        case .indonesia:
            return "印尼"
        }
    }

    
    var languageCode: String{
        switch self {
        case .systemSetting:
            guard let localization = Bundle.main.preferredLocalizations.first else {return "zh-Hant"}
            if localization == LanguageList.chineseSimp.languageCode ||
                localization == LanguageList.chineseTrad.languageCode ||
                localization == LanguageList.english.languageCode ||
                localization == LanguageList.japanese.languageCode ||
                localization == LanguageList.korean.languageCode{
                return localization
            }else{
                guard let appleDefaultLanguage = UserDefaults.standard.object(forKey: "AppleLanguages") as? [String] else {return ""}
                return appleDefaultLanguage.first ?? ""
            }
        case .chineseTrad:
            return "zh-Hant"
        case .chineseSimp:
            return "zh-Hans"
        case .english:
            return "en"
        case .japanese:
            return "ja"
        case .korean:
            return "ko"
        case .vietnam:
            return "vi"
        case .thailand:
            return "th"
        case .indonesia:
            return "id"
        }
    }
    
    var phoneNumberKitLanguageCode: String{
        switch self{
        case .systemSetting:
            guard let localization = Bundle.main.preferredLocalizations.first else {return "zh-Hant"}
            if localization == LanguageList.chineseSimp.languageCode{
                return "CN"
            }else if localization == LanguageList.chineseTrad.languageCode{
                return "TW"
            }else if localization == LanguageList.english.languageCode{
                return "US"
            }else if localization == LanguageList.japanese.languageCode {
                return "JP"
            }else if localization == LanguageList.korean.languageCode{
                return "KR"
            }else if localization == LanguageList.thailand.languageCode{
                return "TH"
            }else if localization == LanguageList.vietnam.languageCode{
                return "VN"
            }else if localization == LanguageList.indonesia.languageCode{
                return "IN"
            }else{
                guard let appleDefaultLanguage = UserDefaults.standard.object(forKey: "AppleLanguages") as? [String] else {return ""}
                guard let appdefault = appleDefaultLanguage.first else {return "TW"}
                if appdefault == LanguageList.chineseSimp.languageCode{
                    return "CN"
                }else if appdefault == LanguageList.chineseTrad.languageCode{
                    return "TW"
                }else if appdefault == LanguageList.english.languageCode{
                    return "US"
                }else if appdefault == LanguageList.japanese.languageCode {
                    return "JP"
                }else if appdefault == LanguageList.korean.languageCode{
                    return "KR"
                }else if appdefault == LanguageList.thailand.languageCode{
                    return "TH"
                }else if appdefault == LanguageList.vietnam.languageCode{
                    return "VN"
                }else if appdefault == LanguageList.indonesia.languageCode{
                    return "IN"
                }else{
                    return "TW"
                }
            }
        case .chineseTrad:
            return "TW"
        case .chineseSimp:
            return "CN"
        case .english:
            return "US"
        case .japanese:
            return "JP"
        case .korean:
            return "KR"
        case .vietnam:
            return "VN"
        case .thailand:
            return "TH"
        case .indonesia:
            return "IN"
        
        }
    }
}


