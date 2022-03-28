//
//  Created by duan on 2018/3/7.
//  2018 Copyright (c) RxSwiftCommunity. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
import RxSwift
import RxCocoa

//MARK: Color
public extension ThemeProxy where Base: UIBarButtonItem {

    /// (set only) bind a stream to tintColor
    var tintColor: ThemeAttribute<UIColor?> {
        get { fatalError("set only") }
        set {
            base.tintColor = newValue.value
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.tintColor)
            hold(disposable, for: "tintColor")
        }
    }

}

//MARK: Image
public extension ThemeProxy where Base: UIBarButtonItem {

    /// (set only) bind a stream to tintColor
    var image: ThemeAttribute<String?> {
        get { fatalError("set only") }
        set {
            base.image = UIImage(named:newValue.value ?? "")
            let disposable = newValue.stream.map({UIImage(named:$0 ?? "")})
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.image)
            hold(disposable, for: "barButtonImage")
        }
    }
}

//MARK: Text
public extension ThemeProxy where Base: UIBarButtonItem {
    
    /// (set only) bind a stream to tintColor
    var title: ThemeAttribute<String?> {
        get { fatalError("set only") }
        set {
            base.title = newValue.value ?? ""
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.title)
            hold(disposable, for: "barButtontitleText")
        }
    }
}
#endif
