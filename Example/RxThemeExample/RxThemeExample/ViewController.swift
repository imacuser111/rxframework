//
//  ViewController.swift
//  RxThemeExample
//
//  Created by user on 2022/3/28.
//

import UIKit
import RxTheme

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //color Update
        self.view.theme.backgroundColor = themed({$0.color.bgColor})
        
        setupGesture()
        //Localization String Update
        let label = UILabel(frame:.init(x:20, y: 20, width: 100, height: 30))
        label.backgroundColor = .blue
        label.theme.text = languaged({$0.ID_Continue.localized()})
        view.addSubview(label)
        //all Update(color/image/localization)
        let btn = UIButton(frame:.init(x:100, y:100, width:400, height:30))
        btn.theme.titleColor(from:themed({$0.color.inputBgColor}), for:.normal)
        btn.theme.image(from:themed({$0.image.pic_like}), for: .normal)
        btn.theme.title(from:languaged({$0.ID_Continue.localized()}), for:.normal)
        view.addSubview(btn)
    }

    private func setupGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(click))
        view.addGestureRecognizer(tap)
    }
    
    
    @objc func click(){
        let type : ThemeType = themeService.type == .dark ? .light : .dark
        themeService.switch(type)
        
        let lang : LanguageType = languageService.type == .en ? .zhHant : .en
        currentLanguage = lang.languageCode
        languageService.switch(lang)
        
//        let navi = UINavigationController(rootViewController:UIViewController())
//        navi.viewControllers.first?.theme.title = languaged({$0.ID_Resend.localized()})
//        navi.viewControllers.first?.view.theme.backgroundColor = themed({$0.color.bgColor})
//        navi.navigationBar.theme.tintColor = themed({$0.color.labelColor})
        
//        navi.navigationBar.theme.titleTextAttributes = themed({[NSAttributedString.Key.foregroundColor: $0.color.labelColor]})
//
//        self.present(navi, animated: true, completion: nil)
        
    }}

