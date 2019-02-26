//
//  ViewController.swift
//  FastTranslate
//
//  Created by 袁俊耀 on 2019/2/17.
//  Copyright © 2019 lvsecoto. All rights reserved.
//

import Cocoa
import RxCocoa
import RxSwift

class MainViewController:
    NSViewController,
    NSTableViewDataSource,
    NSTableViewDelegate
{

    @IBOutlet weak var container: NSTableView!
    
    @IBOutlet weak var queryTextField: NSTextField!
    
    private var translateModel = TranslateModel()
    
    private var translateResult : String? = nil {
        didSet {
            container.reloadData()
        }
    }
    
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        translateModel.input = queryTextField.rx.text.asObservable()
        
        translateModel.translate
            .subscribe(onNext: {result in
                self.translateResult = result
            })
            .disposed(by: disposeBag)

        configureContainer()
    }

    fileprivate func configureContainer() {
        container.dataSource = self
        container.delegate = self
        container.usesAutomaticRowHeights = true
        container.sizeLastColumnToFit()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 1
    }
    
    func tableView(_
        tableView: NSTableView,
        viewFor tableColumn: NSTableColumn?,
        row: Int) -> NSView? {
        
        if let resultCell = tableView.makeView(
            withIdentifier: NSUserInterfaceItemIdentifier(
                rawValue: "idResultCell"
            ),
            owner: self) as? ResultCellView {
            resultCell.result = self.translateResult
            return resultCell
        } else {
            return nil
        }
    }
    
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

