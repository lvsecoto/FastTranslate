//
//  ResultTableCell.swift
//  FastTranslate
//
//  Created by 袁俊耀 on 2019/2/26.
//  Copyright © 2019 lvsecoto. All rights reserved.
//

import Cocoa

class ResultCellView: NSTableCellView {

    @IBOutlet weak var textResult: NSTextField!
    
    var result : String? = nil {
        didSet {
            textResult.stringValue = result ?? ""
        }
    }
}
