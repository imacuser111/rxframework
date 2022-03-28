 import UIKit
 import RxTheme
 protocol LocalizationList{
  	var ID_NotConnectedSubmit: String{get}
	var ID_NotConnectedReload: String{get}
	var ID_AutoLogoutTitle: String{get}
	var ID_AutoLogoutLongTimeNoSeeContent: String{get}
	var ID_AutoLogoutMultipleDevicesTitle: String{get}
	var ID_AutoLogoutMultipleDevicesContent: String{get}
	var ID_AutoLogoutMultipleDevicesNotMeTitle: String{get}
	var ID_AutoLogoutMultipleDevicesNotMeContent: String{get}
	var ID_AutoLogoutMultipleDevicesNotMeSendReport: String{get}
	var ID_AutoLogoutMultipleDevicesNotMeLogoutOtherDevices: String{get}
	var ID_AutoLogoutMultipleDevicesSecurityNotificationTitle: String{get}
	var ID_AutoLogoutMultipleDevicesSecurityNotificationContent: String{get}
	var ID_WelcomeMainTitle: String{get}
	var ID_WelcomeSubTitle: String{get}
	var ID_WelcomeLogin: String{get}
	var ID_WelcomeGuest: String{get}
	var ID_PhoneMainTitle: String{get}
	var ID_PhoneSubTitle: String{get}
	var ID_EnterPhoneNumber: String{get}
	var ID_CallingCodeDone: String{get}
	var ID_Continue: String{get}
	var ID_PolicyAndTermStatement: String{get}
	var ID_PhoneVerificationError: String{get}
	var ID_ContactUs: String{get}
	var ID_PrivacyPolicy: String{get}
	var ID_TermsOfService: String{get}
	var ID_EmailSubjectLine: String{get}
	var ID_EnterVerificationCodeMainTitle: String{get}
	var ID_EnterVerificationCodeSubTitle: String{get}
	var ID_Resend: String{get}
	var ID_ResendNoSecond: String{get}
	var ID_MessageContent: String{get}
	var ID_NoMessage: String{get}
	var ID_ThreeTimesErrorSubTitle: String{get}
	var ID_Relogin: String{get}
	var ID_VerificationCodeExpiredSubTitle: String{get}
	var ID_IncompleteLoginAlertMainTitle: String{get}
	var ID_IncompleteLoginAlertSubTitle: String{get}
	var ID_AlertYes: String{get}
	var ID_AlertNo: String{get}
	var ID_NoMessageTitle: String{get}
	var ID_NoMessageCheckSignalTitle: String{get}
	var ID_NoMessageCloseFlightModeTitle: String{get}
	var ID_NoMessageUnblockListTitle: String{get}
	var ID_NoMessageCloseUnknownSenderTitle_iOS: String{get}
	var ID_NoMessageResetMessageSettingsTitle_Andriod: String{get}
	var ID_NoMessageRestartTitle: String{get}
	var ID_NoMessageCheckSignalContent: String{get}
	var ID_NoMessageCloseFlightModeContent: String{get}
	var ID_NoMessageUnblockListContent_iOS: String{get}
	var ID_NoMessageUnblockListContent_Android: String{get}
	var ID_NoMessageCloseUnknownSenderContent_iOS: String{get}
	var ID_NoMessageResetMessageSettingsContent_Android: String{get}
	var ID_NoMessageRestartContent: String{get}
	var ID_SetNickNameMainTitle: String{get}
	var ID_SetNickNameSubTitle: String{get}
	var ID_NickNameRealTimeValidator1: String{get}
	var ID_NickNameRealTimeValidator2: String{get}
	var ID_GetStarted: String{get}
	var ID_PickInterestMainTitle: String{get}
	var ID_PickInterestSubTitle: String{get}
	var ID_VideoCategory: String{get}
	var ID_PickedCompletely: String{get}
	var ID_SuccessfullyCompleted: String{get}
	var ID_CompleteLoginMainTitle: String{get}
	var ID_CompleteLoginSubTitle: String{get}
	var ID_ReceiveNewbieGift: String{get}
	var ID_GoToHomepage: String{get}
	var ID_GoToRecentBrowsedPage: String{get}
	var errorHTTPNumber400: String{get}
	var errorHTTPNumber401: String{get}
	var errorHTTPNumber500: String{get}
	var errorNum1001: String{get}
	var errorNum1002: String{get}
	var errorNum1003: String{get}
	var errorNum1004: String{get}
	var errorNum1005: String{get}
	var errorNum1006: String{get}
	var errorNum1007: String{get}
	var errorNum1008: String{get}
	var errorNum2001: String{get}
	var errorNum2002: String{get}
	var errorNum2003: String{get}
	var errorNum2004: String{get}
	var errorNum2005: String{get}
	var errorNum9999: String{get}
  }

struct LanguageStringList:LocalizationList{
 	let ID_NotConnectedSubmit: String = "ID_NotConnectedSubmit"
	let ID_NotConnectedReload: String = "ID_NotConnectedReload"
	let ID_AutoLogoutTitle: String = "ID_AutoLogoutTitle"
	let ID_AutoLogoutLongTimeNoSeeContent: String = "ID_AutoLogoutLongTimeNoSeeContent"
	let ID_AutoLogoutMultipleDevicesTitle: String = "ID_AutoLogoutMultipleDevicesTitle"
	let ID_AutoLogoutMultipleDevicesContent: String = "ID_AutoLogoutMultipleDevicesContent"
	let ID_AutoLogoutMultipleDevicesNotMeTitle: String = "ID_AutoLogoutMultipleDevicesNotMeTitle"
	let ID_AutoLogoutMultipleDevicesNotMeContent: String = "ID_AutoLogoutMultipleDevicesNotMeContent"
	let ID_AutoLogoutMultipleDevicesNotMeSendReport: String = "ID_AutoLogoutMultipleDevicesNotMeSendReport"
	let ID_AutoLogoutMultipleDevicesNotMeLogoutOtherDevices: String = "ID_AutoLogoutMultipleDevicesNotMeLogoutOtherDevices"
	let ID_AutoLogoutMultipleDevicesSecurityNotificationTitle: String = "ID_AutoLogoutMultipleDevicesSecurityNotificationTitle"
	let ID_AutoLogoutMultipleDevicesSecurityNotificationContent: String = "ID_AutoLogoutMultipleDevicesSecurityNotificationContent"
	let ID_WelcomeMainTitle: String = "ID_WelcomeMainTitle"
	let ID_WelcomeSubTitle: String = "ID_WelcomeSubTitle"
	let ID_WelcomeLogin: String = "ID_WelcomeLogin"
	let ID_WelcomeGuest: String = "ID_WelcomeGuest"
	let ID_PhoneMainTitle: String = "ID_PhoneMainTitle"
	let ID_PhoneSubTitle: String = "ID_PhoneSubTitle"
	let ID_EnterPhoneNumber: String = "ID_EnterPhoneNumber"
	let ID_CallingCodeDone: String = "ID_CallingCodeDone"
	let ID_Continue: String = "ID_Continue"
	let ID_PolicyAndTermStatement: String = "ID_PolicyAndTermStatement"
	let ID_PhoneVerificationError: String = "ID_PhoneVerificationError"
	let ID_ContactUs: String = "ID_ContactUs"
	let ID_PrivacyPolicy: String = "ID_PrivacyPolicy"
	let ID_TermsOfService: String = "ID_TermsOfService"
	let ID_EmailSubjectLine: String = "ID_EmailSubjectLine"
	let ID_EnterVerificationCodeMainTitle: String = "ID_EnterVerificationCodeMainTitle"
	let ID_EnterVerificationCodeSubTitle: String = "ID_EnterVerificationCodeSubTitle"
	let ID_Resend: String = "ID_Resend"
	let ID_ResendNoSecond: String = "ID_ResendNoSecond"
	let ID_MessageContent: String = "ID_MessageContent"
	let ID_NoMessage: String = "ID_NoMessage"
	let ID_ThreeTimesErrorSubTitle: String = "ID_ThreeTimesErrorSubTitle"
	let ID_Relogin: String = "ID_Relogin"
	let ID_VerificationCodeExpiredSubTitle: String = "ID_VerificationCodeExpiredSubTitle"
	let ID_IncompleteLoginAlertMainTitle: String = "ID_IncompleteLoginAlertMainTitle"
	let ID_IncompleteLoginAlertSubTitle: String = "ID_IncompleteLoginAlertSubTitle"
	let ID_AlertYes: String = "ID_AlertYes"
	let ID_AlertNo: String = "ID_AlertNo"
	let ID_NoMessageTitle: String = "ID_NoMessageTitle"
	let ID_NoMessageCheckSignalTitle: String = "ID_NoMessageCheckSignalTitle"
	let ID_NoMessageCloseFlightModeTitle: String = "ID_NoMessageCloseFlightModeTitle"
	let ID_NoMessageUnblockListTitle: String = "ID_NoMessageUnblockListTitle"
	let ID_NoMessageCloseUnknownSenderTitle_iOS: String = "ID_NoMessageCloseUnknownSenderTitle_iOS"
	let ID_NoMessageResetMessageSettingsTitle_Andriod: String = "ID_NoMessageResetMessageSettingsTitle_Andriod"
	let ID_NoMessageRestartTitle: String = "ID_NoMessageRestartTitle"
	let ID_NoMessageCheckSignalContent: String = "ID_NoMessageCheckSignalContent"
	let ID_NoMessageCloseFlightModeContent: String = "ID_NoMessageCloseFlightModeContent"
	let ID_NoMessageUnblockListContent_iOS: String = "ID_NoMessageUnblockListContent_iOS"
	let ID_NoMessageUnblockListContent_Android: String = "ID_NoMessageUnblockListContent_Android"
	let ID_NoMessageCloseUnknownSenderContent_iOS: String = "ID_NoMessageCloseUnknownSenderContent_iOS"
	let ID_NoMessageResetMessageSettingsContent_Android: String = "ID_NoMessageResetMessageSettingsContent_Android"
	let ID_NoMessageRestartContent: String = "ID_NoMessageRestartContent"
	let ID_SetNickNameMainTitle: String = "ID_SetNickNameMainTitle"
	let ID_SetNickNameSubTitle: String = "ID_SetNickNameSubTitle"
	let ID_NickNameRealTimeValidator1: String = "ID_NickNameRealTimeValidator1"
	let ID_NickNameRealTimeValidator2: String = "ID_NickNameRealTimeValidator2"
	let ID_GetStarted: String = "ID_GetStarted"
	let ID_PickInterestMainTitle: String = "ID_PickInterestMainTitle"
	let ID_PickInterestSubTitle: String = "ID_PickInterestSubTitle"
	let ID_VideoCategory: String = "ID_VideoCategory"
	let ID_PickedCompletely: String = "ID_PickedCompletely"
	let ID_SuccessfullyCompleted: String = "ID_SuccessfullyCompleted"
	let ID_CompleteLoginMainTitle: String = "ID_CompleteLoginMainTitle"
	let ID_CompleteLoginSubTitle: String = "ID_CompleteLoginSubTitle"
	let ID_ReceiveNewbieGift: String = "ID_ReceiveNewbieGift"
	let ID_GoToHomepage: String = "ID_GoToHomepage"
	let ID_GoToRecentBrowsedPage: String = "ID_GoToRecentBrowsedPage"
	let errorHTTPNumber400: String = "errorHTTPNumber400"
	let errorHTTPNumber401: String = "errorHTTPNumber401"
	let errorHTTPNumber500: String = "errorHTTPNumber500"
	let errorNum1001: String = "errorNum1001"
	let errorNum1002: String = "errorNum1002"
	let errorNum1003: String = "errorNum1003"
	let errorNum1004: String = "errorNum1004"
	let errorNum1005: String = "errorNum1005"
	let errorNum1006: String = "errorNum1006"
	let errorNum1007: String = "errorNum1007"
	let errorNum1008: String = "errorNum1008"
	let errorNum2001: String = "errorNum2001"
	let errorNum2002: String = "errorNum2002"
	let errorNum2003: String = "errorNum2003"
	let errorNum2004: String = "errorNum2004"
	let errorNum2005: String = "errorNum2005"
	let errorNum9999: String = "errorNum9999"
 }
enum LanguageType: ThemeProvider {
    case ko,en,zhHans,zhHant,ja,th,id,vi
    var associatedObject: LocalizationList {
        return LanguageStringList()
    }
    
    var languageCode: String{
        switch self {
        case .zhHant:
            return "zh-Hant"
        case .zhHans:
            return "zh-Hans"
        case .en:
            return "en"
        case .ja:
            return "ja"
        case .ko:
            return "ko"
        case .vi:
            return "vi"
        case .th:
            return "th"
        case .id:
            return "id"
        }
    }
}

let languageService = LanguageType.service(initial:.en)
func languaged<T>(_ mapper: @escaping ((LocalizationList) -> T)) -> ThemeAttribute<T> {
    return languageService.attribute(mapper)
}
