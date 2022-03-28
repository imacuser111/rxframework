//
//  UITabBarItem+Theme.swift
//  RxSample
//
//  Created by user on 2022/3/25.
//
#if os(iOS)

import UIKit
import RxSwift
import RxCocoa


public extension ThemeProxy where Base: UITabBarItem {

    /// (set only) bind a stream to barStyle
    var image: ThemeAttribute<String?> {
        get { fatalError("set only") }
        set {
            base.image = UIImage(named:newValue.value ?? "")?.withRenderingMode(.alwaysOriginal)
            let disposable = newValue.stream.map({UIImage(named:$0 ?? "")?.withRenderingMode(.alwaysOriginal)})
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.image)
            hold(disposable, for: "barImage")
        }
    }

    /// (set only) bind a stream to barTintColor
    var selectImage: ThemeAttribute<String?> {
        get { fatalError("set only") }
        set {
            base.selectedImage = UIImage(named:newValue.value ?? "")?.withRenderingMode(.alwaysOriginal)
            let disposable = newValue.stream.map({UIImage(named: $0 ?? "")?.withRenderingMode(.alwaysOriginal)})
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.selectedImage)
            hold(disposable, for: "barSelectImage")
        }
    }
}

//MARK: Text
public extension ThemeProxy where Base: UITabBarItem {
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
