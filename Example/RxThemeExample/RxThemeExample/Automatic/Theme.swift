#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
#endif
#if os(macOS)
    import Cocoa
#endif
import RxSwift
import RxTheme

protocol Theme{
    var image:ImageTheme{get}
    var color:ColorTheme{get}
}

struct LightTheme: Theme {
    
    let image : ImageTheme = LightImageTheme()
    let color : ColorTheme = LightColorTheme()
}

struct DarkTheme: Theme {
    
    let image : ImageTheme = DarkImageTheme()
    let color : ColorTheme = DarkColorTheme()
}

enum ThemeType: ThemeProvider {
    case light, dark
    var associatedObject: Theme {
        switch self {
        case .light: return LightTheme()
        case .dark: return DarkTheme()
        }
    }
}

let themeService = ThemeType.service(initial: .light)
func themed<T>(_ mapper: @escaping ((Theme) -> T)) -> ThemeAttribute<T> {
    return themeService.attribute(mapper)
}