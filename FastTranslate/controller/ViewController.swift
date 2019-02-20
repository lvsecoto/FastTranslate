//
//  ViewController.swift
//  FastTranslate
//
//  Created by 袁俊耀 on 2019/2/17.
//  Copyright © 2019 lvsecoto. All rights reserved.
//

import Cocoa
import RxCocoa

class MainViewController:
    NSViewController
//    &
//    NSTextFieldDelegate &
//    TranslateModelDelegate
{

    @IBOutlet weak var queryTextField: NSTextField!
    
    @IBOutlet weak var resultLabel: NSTextField!
    
    private var translateModel = TranslateModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        translateModel.input = queryTextField.rx.text.asObservable()
        
        translateModel.translate.bind(to: resultLabel.rx.text)
    }
    
//    func controlTextDidChange(_ obj: Notification) {
//        let query = (obj.object as! NSTextField).stringValue
//        translateModel.translate(query: query)
//    }
//
//    func didGetResult(stringResult: String) {
//        resultLabel.stringValue = stringResult
//    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension MainViewController {
    
    /// 从StoryBoard创建主控制器
    static func freshController() -> MainViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("MainViewController")
        let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as! MainViewController
        return viewcontroller
    }
}

