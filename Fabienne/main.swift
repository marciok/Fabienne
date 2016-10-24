//
//  main.swift
//  RecursiveDescentParser
//
//  Created by Marcio Klepacz on 9/28/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import Foundation
let ModuleName = "Fabienne"


//var input = readLine()

//while input != ":q" {
//    guard let content = input else { exit(0) }
    let content = "def f(a) a*a + a*a end"

    print("fab> ", terminator:"")
    var tokens = Lexer.tokenize(string: content)    
    var parser = Parser(tokens: tokens)
    let ast = try parser.parse()
    print(ast)
    
    var ctx = Context.global()
    let mod = SimpleModuleProvider(name: ModuleName)
    _ = try ast.codeGenerate(context: &ctx, module: mod)
    mod.dump()


//
//    for a in ast {
//        do {
//            let result = try Interpreter.eval(a)
//            if let r = result {
//                print(r)
//            } else {
//                print("nil")
//            }
//        } catch let error {
//            print(error)
//        }
//
//    }
//
//    input = readLine()
//}




