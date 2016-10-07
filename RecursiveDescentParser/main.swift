//
//  main.swift
//  RecursiveDescentParser
//
//  Created by Marcio Klepacz on 9/28/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import Foundation

let chars = Array(readLine()!.characters) // TODO: Remove
var tokens = Lexer.tokenize(string: readLine()!)

var parser = Parser(input: chars)
let ast = try parser.parse()
print(try! Interpreter.eval(ast!))




