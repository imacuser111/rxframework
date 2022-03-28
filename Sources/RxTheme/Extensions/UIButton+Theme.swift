//
//  UIButton+Theme.swift
//  Pods
//
//  Created by duan on 2019/01/23.
//

#if os(iOS) || os(tvOS)

import UIKit
import RxSwift
import RxCocoa

//MARK: Color
extension Reactive where Base: UIButton {

    /// Bindable sink for `titleColor` property
    func titleColor(for state: UIControl.State) -> Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.setTitleColor(attr, for: state)
        }
    }

}

public extension ThemeProxy where Base: UIButton {

    func titleColor(from newValue: ThemeAttribute<UIColor?>, for state: UIControl.State) {
        base.setTitleColor(newValue.value, for: state)
        let disposable = newValue.stream
            .take(until: base.rx.deallocating)
            .observe(on: MainScheduler.instance)
            .bind(to: base.rx.titleColor(for: state))
        hold(disposable, for: "titleColor.forState.\(state.rawValue)")
    }
}

//MARK: Image
public extension ThemeProxy where Base: UIButton {

    func image(from newValue: ThemeAttribute<String?>, for state: UIControl.State) {
        base.setImage(UIImage(named:newValue.value ?? ""), for:state)
        let disposable = newValue.stream.map({UIImage(named:$0 ?? "")})
            .take(until: base.rx.deallocating)
            .observe(on: MainScheduler.instance)
            .bind(to: base.rx.image(for:state))
        hold(disposable, for: "image.forState.\(state.rawValue)")
    }
}

//MARK: Text
public extension ThemeProxy where Base: UIButton {

    func title(from newValue: ThemeAttribute<String?>, for state: UIControl.State) {
        base.setTitle(newValue.value ?? "", for: state)
        let disposable = newValue.stream
            .take(until: base.rx.deallocating)
            .observe(on: MainScheduler.instance)
            .bind(to: base.rx.title(for:state))
        hold(disposable, for: "title.forState.\(state.rawValue)")
    }
}
#endif
