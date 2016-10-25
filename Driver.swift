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
        print("Greeting to Fabienne REPL 🍻")
        
        var input: String?
        
        while input != ":q" {
            input = readLine()
            guard let content = input else { continue }
            //    let content = "def test(x) (1+2+x)*(x+(1+2)) end"
            
            let tokens = Lexer.tokenize(string: content)
            var parser = Parser(tokens: tokens)
            
            do {
                let ast = try parser.parse()
                for node in ast {
                    let result = try node.codeGenerate(context: &ctx, module: mod)
                    
                    switch node {
                    case .functionNode(let fun):
                        if fun.isAnonymous {
                            print(try mod.run(function: result!))
                            continue
                        }
                        mod.dump()
                    }
                    
                }
            } catch let error {
                print(error)
                //TODO: Maybe clean last instruction?
            }
            
        }
    }
}
