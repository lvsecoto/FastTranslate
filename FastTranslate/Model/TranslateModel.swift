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
    
    /// 第一个参数是翻译源语言，第二个是翻译目标语言
    var translation = BehaviorSubject<(String, String)>(value: ("en", "zh-CN"))

    /// 获取翻译结果
    lazy var translate = Observable.combineLatest(queryWithTkk, translation) { queryWithTkk, translation in
            (queryWithTkk.0, queryWithTkk.1, translation.0, translation.1)
        }
        .concatMap { (query, tkk, from, to) in
            return self.requestTranslate(query: query, tk: calcHash(query,tkk), from: from, to: to)
        }.map { data in
            return TranslateResult(from: try! JSON(data: data))
    }

    /// 要查询的单词
    private lazy var query: Observable<String?> = input!
    
    private lazy var queryWithTkk = Observable.zip(query, tkk) { query, tkk in
        (query!, tkk)
    }

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
    
    /// 请求翻译
    private func requestTranslate(query: String, tk: String, from: String, to: String) -> Observable<Data> {
        let header : HTTPHeaders = [
            "Accept-Language" : "zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7",
            "Accept-Encoding" : "gzip, deflate, br",
            "User-Agent" : "Mozilla/5.0",
        ]

        return Observable<Data>.create { observable in
            AF.request(
                self.makeRequestUrl(self.urlEncode(query: query), tk, translateFrom: from, translateTo: to),
                method: .get,
                headers: header
                ).responseData { response in
                    if response.result.isSuccess {
                        if let data = response.result.value {
                            observable.onNext(data)
                            observable.onCompleted()
                        }
                    }
            }
            return Disposables.create()
        }
    }

    /// 生成请求的URL
    private func makeRequestUrl(
        _ query: String,
        _ tk: String,
        translateFrom: String = "en",
        translateTo: String = "zh-CN"
    ) -> String {
        let URL_TRANSLATE = """
        https://translate.google.cn/translate_a/single?client=webapp&hl=zh-CN&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&otf=2&ssel=0&tsel=0&kc=1
        """
        return "\(URL_TRANSLATE)&tk=\(tk)&q=\(query)&sl=\(translateFrom)&tl=\(translateTo)"
    }
    
    /// 编码中文
    private func urlEncode(query: String) -> String {
        return query.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
    
}
