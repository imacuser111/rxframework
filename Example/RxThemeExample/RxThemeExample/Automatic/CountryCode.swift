enum CountryCode:String,CaseIterable{
    case ID_Canada
    case ID_UnitedStates
    case ID_UnitedKingdom
    case ID_Malaysia
    case ID_Australia
    case ID_Indonesia
    case ID_Philippines
    case ID_Singapore
    case ID_Thailand
    case ID_Japan
    case ID_SouthKorea
    case ID_Vietnam
    case ID_HongKong
    case ID_Macao
    case ID_China
    case ID_Taiwan
    case ID_India
}
extension CountryCode{
    var code:String{
        switch self{
        case .ID_Canada: return "+1"
        case .ID_UnitedStates: return "+1"
        case .ID_UnitedKingdom: return "+44"
        case .ID_Malaysia: return "+60"
        case .ID_Australia: return "+61"
        case .ID_Indonesia: return "+62"
        case .ID_Philippines: return "+63"
        case .ID_Singapore: return "+65"
        case .ID_Thailand: return "+66"
        case .ID_Japan: return "+81"
        case .ID_SouthKorea: return "+82"
        case .ID_Vietnam: return "+84"
        case .ID_HongKong: return "+852"
        case .ID_Macao: return "+853"
        case .ID_China: return "+86"
        case .ID_Taiwan: return "+886"
        case .ID_India: return "+91"
            
        }
    }
}
