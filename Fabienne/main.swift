//
//  main.swift
//  RecursiveDescentParser
//
//  Created by Marcio Klepacz on 9/28/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import Foundation

var input = readLine()

while input != ":q" {
    guard let content = input else { exit(0) }
    
    print("fab> ", terminator:"")
    var tokens = Lexer.tokenize(string: content)    
    var parser = Parser(tokens: tokens)
    let ast = try parser.parse()
    print(ast)

    do {
        let result = try Interpreter.eval(ast)
        if let r = result {
            print(r)
        } else {
            print("nil")
        }
    } catch let error {
        print(error)
    }
    
    input = readLine()
}





