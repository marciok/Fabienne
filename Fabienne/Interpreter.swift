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
    case undefinedFunction
    case undefinedVariable
}

var functionsTable: [String : Function] = [:]

public struct Interpreter {
    
    static func evalExpression(_ expression: Expression, ctx: String? = nil) throws -> Int {
        
        switch expression {
        case .binaryExpr(let op, let lhs, let rhs):
            let lhsResult = try evalExpression(lhs, ctx: ctx)
            let rhsResult = try evalExpression(rhs, ctx: ctx)
            
            //TOOD: Let's make that dynamic in the future
            
            switch op {
            case "+":
                return lhsResult + rhsResult
            case "-":
                return lhsResult - rhsResult
            case "*":
                return lhsResult * rhsResult
            case "/":
                return lhsResult / rhsResult
            default:
                throw InterpreterError.undefinedFunction
            }
            
        case .literalExpr(let num):
            return num
        case .callExpr(let funName, let args):
            //1. Find fun 
            guard var function = functionsTable[funName] else { throw InterpreterError.undefinedFunction }
            
            //2. Evaluate args
            let argsResult = try args.map { try evalExpression($0, ctx: ctx) }
            
            //3. Bind args
            for index in 0..<argsResult.count {
                var argument = function.prototype.args[index]
                argument.1 = argsResult[index]
                function.prototype.args[index] = argument
            }
            
            functionsTable[funName] = function
            
            //4. Evaluate body
            return try evalExpression(function.body, ctx: function.prototype.name)
        case .variableExpr(let variable):
            guard let funName = ctx,
                  let function = functionsTable[funName] else { throw InterpreterError.undefinedVariable }
            
            let binding = function.prototype.args.filter{ variable == $0.0 }.first
            guard let result = binding, let num = result.1 else {
                 throw InterpreterError.undefinedVariable
            }
            
            return num
        }
    }
    
    public static func eval(_ nodes: ASTNode) throws -> Int? {
        
        switch nodes {
        case.functionNode(let fun):
            
            if fun.prototype.name.isEmpty {
                return try evalExpression(fun.body)
            }
            
            functionsTable[fun.prototype.name] = fun
        }
        
        return nil
    }
}
