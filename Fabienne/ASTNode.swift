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
    var args: [String : Int?] = [:]
}

public indirect enum Expression {
    case literalExpr(Int)
    case variableExpr(String)
    case binaryExpr(String, Expression, Expression)
    case callExpr(String, Expression)//TODO: Just one expression because it only takes one argument
}

public struct Function {
    var prototype: Prototype
    let body: Expression
}

public enum ASTNode {
    case functionNode(Function)
    case freeExpression(Expression)
}

extension ASTNode: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .functionNode(let fun):
            return fun.description
        case .freeExpression(let expr):
            return expr.description
            
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
        case.callExpr(let iden, let expr):
            return iden + expr.description
        }
        
    }
}

