//
//  Driver.swift
//  Fabienne
//
//  Created by Marcio Klepacz on 10/25/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import Foundation

enum OptionsError: Error {
    case inconsistentFlags
}

struct DriverOption {
    let printAST: Bool
    let printIR: Bool
    let useNativeInterpreter: Bool
    let readFromFile: String?
    
    init(arguments args: [String]) throws {
        self.printAST = args.contains("--ast")
        let containsNativeFlag = args.contains("--use-native-interpreter")
        let containsIRFlag = args.contains("--ir")
        self.useNativeInterpreter = containsNativeFlag
        
        if containsNativeFlag && containsIRFlag {
            throw OptionsError.inconsistentFlags
        }
        
        self.printIR = containsIRFlag

        if let fileFlagIndex = args.index(of: "--file") {
            self.readFromFile = try String(contentsOfFile: args[fileFlagIndex + 1])
        } else {
            self.readFromFile = nil
        }
    }
}

struct Driver {
    
    private static func run(from input: String, withOption: DriverOption, module: MCJIT?, context: inout Context?) throws  {
        
        let tokens = Lexer.tokenize(string: input)
        var parser = Parser(tokens: tokens)
        
        let ast = try parser.parse()
        for node in ast {
            
            if option.printAST { print(node) }
            
            if option.useNativeInterpreter {
                let result = try Interpreter.eval(node: node)
                print(result ?? "")
                
                continue
            }
            
            let codeGenerated = try node.codeGenerate(context: &context!, module: module!)
            
            switch node {
            case .prefixedFunctionNode:
                
                if option.printIR { module?.dump() }
                
                continue
            case .functionNode(let fun):
                if fun.isAnonymous {
                    let result = try module!.run(function: codeGenerated!)
                    print(result)
                }
                
                if option.printIR { module?.dump() }
                
                continue
            }
        }
    }
    
    static func mainLoop(_ option: DriverOption) throws {
        
        var ctx: Context?
        var mod: JITter?
        
        if !option.useNativeInterpreter {
            ctx = Context.global()
            mod = MCJIT(name: "main")
        }
        
        // Reading from file
        if let fileContent = option.readFromFile {
            try run(from: fileContent, withOption: option, module: mod as! MCJIT?, context: &ctx)
            
            return
        }
        
        // REPL
        print("🐙  Welcome to Fabienne REPL 🍻")
        
        var input: String?
        while true {
            print("> ", separator: "", terminator: "")
            input = readLine()
            guard let content = input else { continue }
            if content == ":q" { exit(EXIT_SUCCESS) }
            
            do {
                try run(from: content, withOption: option, module: mod as! MCJIT?, context: &ctx)
            } catch let error {
                print("\u{001B}[0;31m ❌  \(error) \u{001B}[0m")
                //TODO: Maybe clean last instruction?
            }
        }
    }
}
