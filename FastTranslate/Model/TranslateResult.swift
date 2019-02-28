//
//  TranslateResult.swift
//  FastTranslate
//
//  Created by 袁俊耀 on 2019/2/26.
//  Copyright © 2019 lvsecoto. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 Sample json:
 0: [["对于", "for", null, null, 2], [null, null, "Duìyú", "fôr,fər"]]
 1: [["介词", ["对于", "为", "于", "供", "给", "替", "遏"],…],…]
 2: "en"
 3: null
 4: null
 5: [["for", null, [["对于", 1000, true, false], ["为", 1000, true, false]], [[0, 3]], "for", 0, 0]]
 6: 0.97016865
 7: null
 8: [["en"], null, [0.97016865], ["en"]]
 9: null
 10: null
 11: null
 12: [["介词", [["in support of or in favor of (a person or policy).", "m_en_us1248322.001",…],…], "for"],…]
 13: [[,…]]
 */
class TranslateResult {
    let translation: String
    let partOfSpeaches: [PartOfSpeach]

    init(from json: JSON) {
        self.translation = json[0][0][0].stringValue
        self.partOfSpeaches = json[1].array?.map {
            PartOfSpeach.init(from: $0)
            } ?? []
    }
}

/**
 Sample json:
     0: "介词"
     1: ["对于", "为", "于", "供", "给", "替", "遏"]
     2: [["对于", ["for", "regarding", "about", "with regard to", "towards", "toward"], null, 0.2528396],…]
     3: "for"
     4: 5
 */
class PartOfSpeach {
    let partOfSpeach: String
    let translations: [String]
    let translationDetails: [TranslationDetail]
    
    init(from json: JSON) {
        self.partOfSpeach = json[0].stringValue
        self.translations = json[1].array?.map {
            $0.stringValue
        } ?? []
        self.translationDetails = json[2].array?.map {
            TranslationDetail(from: $0)
        } ?? []
    }
}

/**
 Sample json:
     0: "对于"
     1: ["for", "regarding", "about", "with regard to", "towards", "toward"]
     2: null
     3: 0.2528396
 */
class TranslationDetail {
    let translation: String
    let translationsToOrigin: [String]
    
    init(from json: JSON) {
        self.translation = json[0].stringValue
        self.translationsToOrigin = json[1].array?.map {
            $0.stringValue
        } ?? []
    }
}
