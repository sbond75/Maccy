//
//  leet.swift
//  Maccy
//
//  Created by sbond75 on 9/23/21.
//  Copyright © 2021 p0deje. All rights reserved.
//
// For fun
// https://github.com/heinthanth/1337

import Foundation

var dict:[String: String] = [

    "a": "4",
    "b": "8",
    "e": "3",
    "g": "9",
    "i": "1",
    "l": "1",
    "o": "0",
    "q": "kw",
    "s": "5",
    "t": "7",
    "z": "2",

    "A": "4",
    "B": "8",
    "E": "3",
    "G": "6",
    "I": "1",
    "O": "0",
    "Q": "O",
    "S": "5",
    "T": "7",
    "Z": "2",

    "0": "O",
    "1": "l",
    "2": "z",
    "3": "E",
    "4": "A",
    "5": "S",
    "6": "G",
    "7": "T",
    "8": "B",
    "9": "g",

    " 4ND ": " && ",
    " 4nd ": " && ",
    " 47 ": " @ ",
    " 0R ": " || ",
    " 0r ": " || ",
    " N07 ": " ! ",
    " n07 ": " ! "

]

//if CommandLine.arguments.count == 1 {
//    print("\n\t usage: swift leet.swift <input character(s)>\n")
//} else {
func leet(_ input: String) -> String {
    var string :String = input //CommandLine.arguments[1]
    
    for x in string {
        if dict[String(x)] != nil {
            let replaceString = dict[String(x)]!
            string = string.replacingOccurrences(of: String(x), with: replaceString)
        }
    }

    for y in string.components(separatedBy: " ") {
        if dict[String(" " + y + " ")] != nil {
            let replaceString = dict[String(" " + y + " ")]!
            string = string.replacingOccurrences(of: String(" " + y + " "), with: replaceString)
        }
    }

    //print(string)
    return string
}
//}
