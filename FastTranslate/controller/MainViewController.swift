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
    NSTableViewDelegate,
    NSTextFieldDelegate
{

    @IBOutlet weak var container: NSTableView!
    
    @IBOutlet weak var queryTextField: NSTextField!
    
    @IBOutlet weak var labelTranslateFrom: NSTextField!
    
    @IBOutlet weak var labelTranslateTo: NSTextField!
    
    private var translateModel = TranslateModel()
    
    private var query = PublishSubject<String?>()
    
    private var queryRightNow = PublishSubject<String?>()
    
    private var translateResult : TranslateResult? = nil {
        didSet {
            container.reloadData()
        }
    }
    
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureContainer()

        queryTextField.delegate = self
        
        translateModel.input = Observable.merge(
            query.debounce(0.3, scheduler: MainScheduler.instance),
            queryRightNow
        )
        
        translateModel.translate
            .subscribe(onNext: {
                self.translateResult = $0
            })
            .disposed(by: disposeBag)
        
        translateModel.translation.map { (from, _) -> String in
                self.getDisplayLanguague(from)
            }
            .bind(to: labelTranslateFrom.rx.text)
            .disposed(by: disposeBag)
        
        translateModel.translation.map { (_, to) -> String in
                self.getDisplayLanguague(to)
            }
            .bind(to: labelTranslateTo.rx.text)
            .disposed(by: disposeBag)
    }
    
    fileprivate func getDisplayLanguague(_ language: String) -> String {
        switch language {
        case "en": return "英语"
        case "zh-CN": return "中文"
        default:
            return "无法检测"
        }
    }

    fileprivate func configureContainer() {
        container.dataSource = self
        container.delegate = self
        container.usesAutomaticRowHeights = true
        container.sizeLastColumnToFit()
    }
    
    @IBAction func exchangeTranslateDirection(_ sender: Any) {
        let (from, to) = try! translateModel.translation.value()
        translateModel.translation.onNext((to, from))
    }
    
    func controlTextDidChange(_ obj: Notification) {
        query.onNext(queryTextField.stringValue)
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        queryRightNow.onNext(queryTextField.stringValue)
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
                    text + detail + ";  "
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

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

