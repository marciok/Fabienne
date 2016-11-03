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
    
    static func eval(expression: Expression, ctx: [(String, Int)]) throws -> Int {
        
        switch expression {
        case .binaryExpr(let op, let lhs, let rhs):
            let lhsResult = try eval(expression: lhs, ctx: ctx)
            let rhsResult = try eval(expression: rhs, ctx: ctx)
            
            //TOOD: Let's make that dynamic in the future, if it's possible
            
            switch op {
            case "+": return lhsResult + rhsResult
            case "-": return lhsResult - rhsResult
            case "*": return lhsResult * rhsResult
            case "/": return lhsResult / rhsResult
            case "<": return lhsResult < rhsResult ? 1 : 0
            default:
                throw InterpreterError.undefinedFunction
            }
            
        case .literalExpr(let num):
            return num
        case .callExpr(let funName, let args):
            //1. Find fun 
            guard let function = functionsTable[funName] else { throw InterpreterError.undefinedFunction }
            
            //2. Evaluate args
            let argsResult = try args.map { try eval(expression: $0, ctx: ctx) }
            
            //3. Bindings
            var bindings = Array(zip(function.prototype.args, argsResult))
            bindings += ctx
            
            //4. Evaluate body
            let result = try eval(expression: function.body, ctx: bindings)
            
            return result
        case .conditionalExpr(condExpr: let condExpr, thenExpr: let thenExpr, elseExpression: let elseExpr):
            
            let condResult = try eval(expression: condExpr, ctx: ctx)
            
            if condResult != 0 {
                return try eval(expression: thenExpr, ctx: ctx)
            }
            
           return try eval(expression: elseExpr, ctx: ctx)
        
        case .variableExpr(let variable):
            let result = ctx.first(where: { $0.0 == variable }).flatMap { $0.1 }
            guard let num = result else { throw InterpreterError.undefinedVariable } // Unbound is better
            
            return num
        }
    }
    
    public static func eval(node: ASTNode) throws -> Int? {
        
        switch node {
        case .functionNode(let fun):
            
            if fun.isAnonymous {
                return try eval(expression: fun.body, ctx: [])
            }
            
            functionsTable[fun.prototype.name] = fun
        case .prefixedFunctionNode:
            print("TODO: NOT DOING ANYTHING")
            break;
            
        }
        
        return nil
    }
}
