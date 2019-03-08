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

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

class MainViewController:
    NSViewController,
    NSTableViewDataSource,
    NSTableViewDelegate
{

    @IBOutlet weak var container: NSTableView!
    
    @IBOutlet weak var queryTextField: NSTextField!
    
    private var translateModel = TranslateModel()
    
    private var translateResult : TranslateResult? = nil {
        didSet {
            container.reloadData()
        }
    }
    
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureContainer()

        translateModel.input = queryTextField.rx.text.asObservable()
        translateModel.translate
            .subscribe(onNext: {
                self.translateResult = $0
            })
            .disposed(by: disposeBag)
    }

    fileprivate func configureContainer() {
        container.dataSource = self
        container.delegate = self
        container.usesAutomaticRowHeights = true
        container.sizeLastColumnToFit()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let rowOfResult = self.translateResult == nil ? 0 : 1
        let rowOfPartOfSpeach = self.translateResult?.partOfSpeaches.count ?? 0
        return rowOfResult + rowOfPartOfSpeach
    }
    
    func tableView(_
        tableView: NSTableView,
        viewFor tableColumn: NSTableColumn?,
        row: Int) -> NSView? {
        
        switch row {
            
        case 0:
            let resultCell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(
                    rawValue: "idResultCell"
                ),
                owner: nil) as! ResultCellView
            resultCell.textResult.stringValue = self.translateResult!.translation
            return resultCell
            
        case 1...1 + self.translateResult!.partOfSpeaches.count:
            let partOfSpeachCell = tableView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(
                    rawValue: "idPartOfSpeachCell"
                ),
                owner: nil) as! PartOfSpeachCellView
            
            partOfSpeachCell.partOfSpeach.stringValue =
                self.translateResult!.partOfSpeaches[row - 1].partOfSpeach
            
            let details = self.translateResult!.partOfSpeaches[row - 1].translations
            partOfSpeachCell.details.stringValue =
                details.reduce("", { (text, detail) -> String in
                    text + " " + detail
                })

            return partOfSpeachCell
            
        default:
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

