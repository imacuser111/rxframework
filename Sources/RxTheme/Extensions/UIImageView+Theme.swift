//
//  UIImageView+Theme.swift
//  RxSample
//
//  Created by user on 2022/3/25.
//
#if os(iOS) || os(tvOS)

import UIKit
import RxSwift
import RxCocoa


public extension ThemeProxy where Base: UIImageView {

    /// (set only) bind a stream to font
    var image: ThemeAttribute<String> {
        get { fatalError("set only") }
        set {
            base.image = UIImage(named:newValue.value)
            let disposable = newValue.stream
                .map({UIImage(named:$0)})
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.image)
            hold(disposable, for: "image")
        }
    }
}
#endif
