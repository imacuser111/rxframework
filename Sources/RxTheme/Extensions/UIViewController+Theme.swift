//
//  UIViewController+Theme.swift
//  RxSample
//
//  Created by user on 2022/3/25.
//
#if os(iOS)

import UIKit
import RxSwift
import RxCocoa

//MARK: Text
public extension ThemeProxy where Base: UIViewController {
    /// (set only) bind a stream to barTintColor
    var title: ThemeAttribute<String?> {
        get { fatalError("set only") }
        set {
            base.title = newValue.value
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.title)
            hold(disposable, for: "title")
        }
    }
}

#endif
