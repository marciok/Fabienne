//
//  ASTNode.swift
//  Fabienne
//
//  Created by Marcio Klepacz on 10/6/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import Foundation

public struct Prototype {
    let name: String
    var args: [String] = []
}

public indirect enum Expression {
    case literalExpr(Int)
    case variableExpr(String)
    case binaryExpr(String, Expression, Expression)
    case callExpr(String, [Expression])
    case loopExpr(varName: String, startExpr: Expression, endExpr: Expression, stepExpr: Expression, bodyExpr: Expression)
    case conditionalExpr(condExpr: Expression, thenExpr:
        Expression, elseExpression: Expression)
}

public struct Function {
    var prototype: Prototype
    let body: Expression
    
    var isAnonymous: Bool {
        get { return prototype.name == "" }
    }
}

public enum ASTNode {
    case functionNode(Function)
    case prefixedFunctionNode(Prototype)
}

extension ASTNode: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .functionNode(let fun):
            return fun.description
        case .prefixedFunctionNode(let proto):
            return proto.description
        }
    }
}

extension Prototype: CustomStringConvertible {
    
    public var description: String {
        return "\(name)  arguments:\(args)"
    }
}

extension Function: CustomStringConvertible {
    
    public var description: String {
        return "\(prototype.description): \(body.description)"
    }
}

extension Expression: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .binaryExpr(let op, let lhs, let rhs):
            return  op + " { " + lhs.description + ", " + rhs.description + " }"
        case .literalExpr(let num):
            return String(num)
        case .variableExpr(let variable):
            return variable
        case .loopExpr(varName: let name, startExpr: let start, endExpr: let end, stepExpr: let step, bodyExpr: let body):
            return name + " " + start.description + " " + step.description + " " + end.description + " " + body.description
        case .callExpr(let iden, let expr):
            return iden + expr.description
        case .conditionalExpr(condExpr: let cond, thenExpr: let thenExpr, elseExpression:let elseExpr):
            
            return "if \(cond) then \(thenExpr) else \(elseExpr)"
        }
        
    }
}

