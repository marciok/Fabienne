//
//  main.swift
//  RecursiveDescentParser
//
//  Created by Marcio Klepacz on 9/28/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import Foundation

var tokens = Lexer.tokenize(string: readLine()!)
var parser = Parser(tokens: tokens)
let ast = try parser.parse()
print(try! Interpreter.eval(ast))




