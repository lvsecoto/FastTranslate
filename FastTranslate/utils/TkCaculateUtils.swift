//
//  TkCaculateUtils.swift
//  SpikeMacos
//
//  Created by 袁俊耀 on 2019/2/16.
//  Copyright © 2019 袁俊耀. All rights reserved.
//

import Foundation

func hexCharAsNumber(_ char: String) -> Int64 {
    assert(char.count == 1)
    
    let c = Int64((char as NSString).character(at: 0))
    
    if c >= Int(("a" as NSString).character(at: 0)) {
        return c - 87
    }  else {
        return Int64(char) ?? 0
    }
}

func normalizeHash(_ encondindRound2: Int64) -> Int64 {
    var result = encondindRound2
    
    if (encondindRound2 < 0) {
        result = (encondindRound2 & 0x7fffffff) + 0x80000000
    }
    return result % 1000000
}

func transformQuery(_ query: String) -> [Int64] {
    var result = [Int64]()
    
    var i = 0
    while i < query.count {
//    for (int i = 0 i < query.length() i++) {
        
        var c = Int64((query as NSString).character(at: i))
        if (c < 128) {
            result.append(c)                    //    0{l[6-0]}
        } else if (c < 2048) {
            result.append(Int64(c >> 6 | 0xC0))        //    110{l[10-6]}
            result.append(Int64(c & 0x3F | 0x80))    //    10{l[5-0]}
        } else if (0xD800 == (c & 0xFC00) && c + 1 < query.count && 0xDC00 == ((query as NSString).character(at: i + 1) & 0xFC00)) {
            //    that's pretty rare... (avoid ovf?)
            i = i + 1
            c = Int64((query as NSString).character(at: i))
            
            let pre = Int64((1 << 16) + ((c & 0x03FF) << 10))
            c = pre + (c & 0x03FF)
            result.append(c >> 18 | 0xF0)        //    111100{l[9-8*]}
            result.append(c >> 12 & 0x3F | 0x80)    //    10{l[7*-2]}
            result.append(c & 0x3F | 0x80)        //    10{(l+1)[5-0]}
        } else {
            result.append(c >> 12 | 0xE0)        //    1110{l[15-12]}
            result.append(c >> 6 & 0x3F | 0x80)    //    10{l[11-6]}
            result.append(c & 0x3F | 0x80)        //    10{l[5-0]}
        }
        
        i = i + 1
    }
    return result
}

func shiftLeftOrRightThenSumOrXor(_ opArray: [String], _ num: Int64) -> Int64 {
    var result = num
    
    for opString in opArray {
        let op1 = opString[1]   //    '+' | '-' ~ SUM | XOR
        let op2 = opString[0]    //    '+' | '^' ~ SLL | SRL
        let xd = opString[2]    //    [0-9a-f]

        let shiftAmount = hexCharAsNumber(xd)
        let mask = (op1 == "+") ?  result.unsignedRightShift(count: shiftAmount) : result << shiftAmount
        result = (op2 == "+") ? ((result + mask) & Int64(0xffffffff)) : (result ^ mask)
    }
    
    return result
}

fileprivate extension Int64 {
    func unsignedRightShift(count: Int64) -> Int64 {
        return Int64(bitPattern: (UInt64(bitPattern: self) >> count))
    }
}

fileprivate extension String {
    subscript (index: Int) -> String {
        return String(self[self.index(self.startIndex, offsetBy: index)])
    }
}



//    EXAMPLE:
//
//    INPUT: query: 'hola', windowTkk: '409837.2120040981'
//    OUTPUT: '70528.480109'
func calcHash(_ query: String, _ windowTkk: String) -> String {
    //    STEP 1: spread the the query char codes on a byte-array, 1-3 bytes per char
    let bytesArray = transformQuery(query)

    //    STEP 2: starting with TKK index, add the array from last step one-by-one, and do 2 rounds of shift+add/xor
    let d = windowTkk.split(separator: ".")
    let tkkIndex = Int64(d[0]) ?? 0
    let tkkKey = Int64(d[1]) ?? 0

    var acc = tkkIndex
    for current in bytesArray {
        acc += current
        acc = shiftLeftOrRightThenSumOrXor(["+-a", "^+6"], acc)
    }

    let encondingRound1 = acc

    //    STEP 3: apply 3 rounds of shift+add/xor and XOR with they TKK key
    let encondingRound2 = shiftLeftOrRightThenSumOrXor(["+-3", "^+b", "+-f"], encondingRound1) ^ tkkKey

    //    STEP 4: Normalize to 2s complement & format
    let normalizedResult = normalizeHash(encondingRound2)

    return "\(normalizedResult).\(normalizedResult ^ tkkIndex)"
}

