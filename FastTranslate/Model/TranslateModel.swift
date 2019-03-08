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
import RxSwift

class TranslateModel {
    
    var input: Observable<String?>? = nil
    
    /// 要查询的单词
    private lazy var query: Observable<String?> = input!

    /// 获取tkk
    private lazy var tkk = query.concatMap { _ in
        self.getTkk()
    }
    
    private func getTkk() -> Observable<String> {
        let URL_TRANSLATE_WEB = "https://translate.google.cn"
        
        return Observable<String>.create { observable in
            AF.request(URL_TRANSLATE_WEB).responseString { response in
                if let body = response.result.value {
                    if let tkk = self.findTkk(body) {
                        observable.onNext(tkk)
                        observable.onCompleted()
                    } else {
                        observable.onError(NSError(
                            domain: "error",
                            code: 100,
                            userInfo: nil)
                        )
                    }
                } else {
                    observable.onError(NSError(
                        domain: "error",
                        code: 100,
                        userInfo: nil
                    ))
                }
            }
            return Disposables.create()
        }
    }
    
    /// 从响应的body找到Tkk值
    private func findTkk(_ body: String) -> String? {
        let tkkRegex = try! NSRegularExpression(
            pattern: "(?<=tkk:\\')[0-9.]+(?=\\')",
            options: .caseInsensitive)

        if let range = tkkRegex.firstMatch(
            in: body,
            options: NSRegularExpression.MatchingOptions(rawValue: 0),
            range: NSMakeRange(0, body.count)
            )?.range {
            let tkk = (body as NSString).substring(with: range)
            return tkk
        }
        return nil
    }
    
    /// 获取翻译结果
    lazy var translate = Observable.zip(query, tkk) { query, tkk in
        (query!, tkk)
        }
        .concatMap { (query, tkk) in
            return self.requestTranslate(query: query, tk: calcHash(query,tkk))
        }.map { data in
            return TranslateResult(from: try! JSON(data: data))
        }

    /// 请求翻译
    private func requestTranslate(query: String, tk: String) -> Observable<Data> {
        let headerTranslate : HTTPHeaders = [
            "Accept-Language" : "zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7",
            "Accept-Encoding" : "gzip, deflate, br",
            "User-Agent" : "Mozilla/5.0",
        ]

        return Observable<Data>.create { observable in
            AF.request(
                self.makeRequestUrl(self.urlEncode(query: query), tk),
                method: .get,
                headers: headerTranslate
                ).responseData { response in
                    if response.result.isSuccess {
                        if let data = response.result.value {
//                            let json: JSON = JSON(data)
//                            observable.onNext(
//                                json[0][0][0].stringValue
//                            )
//                            observable.onCompleted()
                            observable.onNext(data)
                            observable.onCompleted()
                        }
                    }
            }
            return Disposables.create()
        }
    }

    /// 生成请求的URL
    private func makeRequestUrl(_ query: String, _ tk: String) -> String {
        let URL_TRANSLATE = """
        https://translate.google.cn/translate_a/single?client=webapp&sl=en&tl=zh-CN&hl=zh-CN&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&otf=2&ssel=0&tsel=0&kc=1
        """
        return "\(URL_TRANSLATE)&tk=\(tk)&q=\(query)"
    }
    
    /// 编码中文
    private func urlEncode(query: String) -> String {
        return query.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
    
}
