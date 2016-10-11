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
    public static func eval(_ tree: ASTNode) throws -> Int {
        let val = tree.value
    
        if  tree.children.isEmpty {
            return Int(val.rawValue())!
        }
        switch val {
        case .other("+"):
            let firstNumber = try eval(tree.children.first!)
            let secondNumber = try eval(tree.children.last!)
    
            return firstNumber + secondNumber
        case .other("-"):
            let firstNumber = try eval(tree.children.first!)
            let secondNumber = try eval(tree.children.last!)
            
            return firstNumber - secondNumber
            
        case .other("*"):
            let firstNumber = try eval(tree.children.first!)
            let secondNumber = try eval(tree.children.last!)
            
            return firstNumber * secondNumber
        default:
            throw InterpreterError.undefinedToken
        }
    }
}
