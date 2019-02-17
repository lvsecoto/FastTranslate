//
//  TranslateModel.swift
//  FastTranslate
//
//  Created by 袁俊耀 on 2019/2/17.
//  Copyright © 2019 lvsecoto. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

fileprivate let URL_TRANSLATE_WEB = "https://translate.google.cn"

fileprivate let URL_TRANSLATE = """
https://translate.google.cn/translate_a/single?client=webapp&sl=en&tl=zh-CN&hl=zh-CN&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&otf=2&ssel=0&tsel=0&kc=1
"""

fileprivate let headerTranslate : HTTPHeaders = [
    "Accept-Language" : "zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7",
    "Accept-Encoding" : "gzip, deflate, br",
    "User-Agent" : "Mozilla/5.0",
]

fileprivate let tkkRegex = try! NSRegularExpression(
    pattern: "(?<=tkk:\\')[0-9.]+(?=\\')",
    options: .caseInsensitive)

class TranslateModel {
    
    weak var delegate: TranslateModelDelegate?

    func translate(query: String) {
        getTkk(query) { tkk in
            self.requestTranslate(query, tkk) { result in
                self.delegate?.didGetResult(stringResult: result)
            }
        }
    }
    
    /// 爬取主页中的TKK值
    private func getTkk(_ query: String, _ completion: @escaping (String) -> Void ) {
        AF.request(URL_TRANSLATE_WEB).responseString { response in
            if let body = response.result.value {
                if let tkk = self.findTkk(body) {
                    completion(tkk)
                }
            }
        }
    }

    /// 从响应的body找到Tkk值
    private func findTkk(_ body: String) -> String? {
        if let range = tkkRegex.firstMatch(
            in: body,
            options: NSRegularExpression.MatchingOptions(rawValue: 0),
            range: NSMakeRange(0, body.count))?.range {
            
            let tkk = (body as NSString).substring(with: range)
            print("tkk is: \(tkk)")
            return tkk
        }
        
        return nil
    }
    
    /// 请求翻译
    private func requestTranslate(_ query: String, _ tkk: String, _ completion: @escaping (String) -> Void) {
        AF.request(
            makeRequestUrl(urlEncode(query: query), calcHash(query, tkk)),
            method: .get,
            headers: headerTranslate
            ).responseData { response in
                if response.result.isSuccess {
                    if let data = response.result.value {
                        print("request success")
                        let json: JSON = JSON(data)
                        print(json)
                        completion(json[0][0][0].stringValue)
                    }
                } else {
                    print("request failed")
                }
        }
    }
    
    /// 生成请求的URL
    private func makeRequestUrl(
        _ query: String, _ tk: String) -> String {
        return "\(URL_TRANSLATE)&tk=\(tk)&q=\(query)"
    }
    
    /// 编码中文
    private func urlEncode(query: String) -> String {
        return query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
    
}

protocol TranslateModelDelegate : class {
    func didGetResult(stringResult: String)
}
