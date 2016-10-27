//
//  Driver.swift
//  Fabienne
//
//  Created by Marcio Klepacz on 10/25/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import Foundation

struct Driver {
    static func mainLoop() {
        
        let ModuleName = "Fabienne"
        var ctx = Context.global()
        let mod = MCJIT(name: ModuleName)
        print("🐙  Greetings to Fabienne REPL 🍻")
        
        let args = CommandLine.arguments
        let displayAST = args.contains("--ast")
        let displayIR = args.contains("--ir")
        
        var input: String?
        
        while true {
            print("> ", separator: "", terminator: "")
            input = readLine()
            guard let content = input else { continue }
            if content == ":q" { exit(0) }
            
            let tokens = Lexer.tokenize(string: content)
            var parser = Parser(tokens: tokens)
            
            do {
                let ast = try parser.parse()
                for node in ast {
                    
                    if displayAST { print(ast) }
                    
                    let result = try node.codeGenerate(context: &ctx, module: mod)
                    
                    switch node {
                    case .functionNode(let fun):
                        if fun.isAnonymous {
                            print(try mod.run(function: result!))
                        }
                        
                        if displayIR { mod.dump() }
                        continue
                    }
                }
            } catch let error {
                print("\u{001B}[0;31m ❌  \(error.localizedDescription) \u{001B}[0m")
                //TODO: Maybe clean last instruction?
            }
        }
    }
}
