//
//  Interpreter.swift
//  Fabienne
//
//  Created by Marcio Klepacz on 10/6/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import Foundation

public enum InterpreterError: Error {
    case undefinedToken
}

public struct Interpreter {
    
    public static func eval(_ tree: ASTNode) throws -> Int? {
        switch tree.value {
        case .identifier:
            
            
            if let function = implTable[tree.value.rawValue()] {
                // There's a function, so it's calling
                // Bind arguments
                let argument = try eval(tree.children.first!)
                var mutArgs = function.arguments
                var firstArg = mutArgs.first!
                firstArg.value = argument
                mutArgs[firstArg.key] = firstArg.value
                
                function.arguments = mutArgs
                
                return try eval(function.body)
            }
            
            //This is very ineffecient but I'm doing just to see if it works
            let bindings = implTable.map { $0.value.arguments.filter { $0.key == tree.value.rawValue() }.first }
            
            if let binding = bindings.first {
                return binding?.value
            }

            
        default:
            return try evalExpression(tree)
        }
        
        return nil
    }
    
    static func evalExpression(_ tree: ASTNode) throws -> Int {
        
        let val = tree.value
        
        if  tree.children.isEmpty {
            return Int(val.rawValue())!
        }
        
        switch val {
        case .other("+"):
            let firstNumber = try eval(tree.children.first!)
            let secondNumber = try eval(tree.children.last!)
            
            return firstNumber! + secondNumber!
        case .other("-"):
            let firstNumber = try eval(tree.children.first!)
            let secondNumber = try eval(tree.children.last!)
            
            return firstNumber! - secondNumber!
            
        case .other("*"):
            let firstNumber = try eval(tree.children.first!)
            let secondNumber = try eval(tree.children.last!)
            
            return firstNumber! * secondNumber!
        case .other("/"):
            let firstNumber = try eval(tree.children.first!)
            let secondNumber = try eval(tree.children.last!)
            
            return firstNumber! / secondNumber!
        default:
            throw InterpreterError.undefinedToken
        }
    }
}
