//
//  Parser.swift
//  Fabienne
//
//  Created by Marcio Klepacz on 10/6/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//
import Foundation

public enum ParsingError: Error {
    case invalidTokens(expecting: String)
    case incompleteExpression
}

/**
 Parse Grammar:
 
 program           : [definition | expression]*;
 
 definition        : def prototype expression end
 
 prototype         : identifier '(' [identifier] ')'

 expression        : [primaryExpression (binaryOperator primaryExpression)* ]
 
 primaryExpression : [number | identifier | callExpression | '(' expression ')']
 
 callExpression    : identifier '(' expression ')'
 
 binaryOperator    : [+-]
 
 number            : [0..9]
 
 identifer         : [aZ-0..9]
 
 */
struct Parser {
    
    var tokens: [Token]
    var index = 0
    let operatorPrecedence: [String: Int] = [
        "+": 20,
        "-": 20,
        "*": 40,
        "/": 40
    ]
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    mutating func number() throws -> Expression {
        
        guard case let .number(num) = popCurrentToken() else {
            throw ParsingError.invalidTokens(expecting: "Expecting number")
        }
        
        return .literalExpr(num)
    }
    
    mutating func identifier() throws -> Expression {
        
        guard case let .identifier(id) = popCurrentToken() else {
            throw ParsingError.invalidTokens(expecting: "Expecting identifier")
        }
        
       return .variableExpr(id)
    }
    
    mutating func binaryOperator() throws -> String {
        
        guard case let .other(op) = popCurrentToken() else {
            throw ParsingError.invalidTokens(expecting: "Expecting Operator")
        }
        
        return op
    }
    
    func getCurrentTokenPrecedence() throws -> Int {
        guard index < tokens.count else {
            return -1
        }
        
        guard case let Token.other(op) = try peekCurrentToken() else {
            return -1
        }
        
        guard let precedence = operatorPrecedence[op] else {
            throw ParsingError.invalidTokens(expecting: "some operator")
        }
        
        return precedence
    }
    
    /// (binaryOperator primaryExpression)*
    mutating func binaryExpression(_ node: Expression, exprPrecedence: Int = 0) throws -> Expression {
        var lhs = node
        
        // TODO: Understand better this algorithm
        while true {
            let tokenPrecedence = try getCurrentTokenPrecedence()
            if tokenPrecedence < exprPrecedence {
                // get out when there's an expression with less precedence or if there are no more tokens
                return lhs
            }
            
            // if you are here the current token has at least the precendence as the expression
            let binOpNode = try binaryOperator()
            
            var rhs = try primaryExpression()
            let nextPrecedence = try getCurrentTokenPrecedence()
            
            if tokenPrecedence < nextPrecedence {
                rhs = try binaryExpression(rhs, exprPrecedence: tokenPrecedence + 1)
            }
            
            lhs = Expression.binaryExpr(binOpNode, lhs, rhs)
        }
    }
    
    /// primaryExpression -> number | identifier | callExpression | '(' expression ')'
    mutating func primaryExpression() throws -> Expression {
        let currentToken = try peekCurrentToken()
        
        switch currentToken {
        case .parensOpen:
            _ = popCurrentToken() // Removing '('
            let expressionNode = try expression()
            
            
            if index >= tokens.count {
                throw ParsingError.incompleteExpression
            }
            _ = popCurrentToken() // Removing ')'
            
            return expressionNode
        case .number:
            return try number()
        case .identifier:
            let iden = try identifier()
            
            if index >= tokens.count {
                return iden
            }
            
            if try peekCurrentToken() == .parensOpen  {
                
                guard case let .variableExpr(id) = iden else {
                    throw ParsingError.invalidTokens(expecting: "Expecting identifier")
                }
                return try callExpression(id)
            }
            
            return iden
            
        default:
            throw ParsingError.invalidTokens(expecting: "Expecting number or another expression")
        }
    }
    
    /// expression -> [primaryExpression (binaryOperator primaryExpression)* ];
    mutating func expression() throws -> Expression {
        
        let primaryExprNode = try primaryExpression()
        let binaryOpNode = try binaryExpression(primaryExprNode)

        //TODO: It's related with this test: test_invalidTokensExpectingValidOperator
//        switch binaryOpNode.value {
//        case Token.other:
            return binaryOpNode
//        default:
//            throw ParsingError.invalidTokens(expecting: "Expecting operator")
//        }
    }
    
    /// callExpression    : identifier '(' expression* ')'
    mutating func callExpression(_ id: String) throws -> Expression {
        
        if try peekCurrentToken() != .parensOpen {
            throw ParsingError.invalidTokens(expecting: "Expecting: (")
        }
        
        _ = popCurrentToken() // Removing '('
        
        if try peekCurrentToken() == .parensClose {
            _ = popCurrentToken() // Removing ')'
            
            return .callExpr(id, [Expression.literalExpr(0)]) // If there's no arguments
        }
        
        var expressions: [Expression] = []
        while try peekCurrentToken() != .parensClose {
            let expression = try self.expression()
            expressions.append(expression)
        }
        
        _ = popCurrentToken() // Removing ')'
        
        return .callExpr(id, expressions)
    }
    mutating func prototype() throws -> Prototype {
        
        switch try peekCurrentToken() {
        case .identifier:
            var protoNode = Prototype(name: popCurrentToken().rawValue(), args: [])
            
            if try peekCurrentToken() != .parensOpen {
                throw ParsingError.invalidTokens(expecting: "Expecting: (")
            }
            
            _ = popCurrentToken() // Removing '('
            
            switch try peekCurrentToken() {
            case .identifier:
                
                var args: [(String, Int?)] = []
                while case let .identifier(id) = try peekCurrentToken() {
                    args.append((id, nil))
                    _ = popCurrentToken() // Removing variable
                }
                
                protoNode.args = args
                
                if try peekCurrentToken() != .parensClose {
                    throw ParsingError.invalidTokens(expecting: "Expecting: )")
                }
                
                _ = popCurrentToken() // Removing ')'
                return protoNode
            case .parensClose:
                _ = popCurrentToken() // Removing ')'
                
                return protoNode
            default:
                throw ParsingError.invalidTokens(expecting: "Expecting identifier")
            }
            
        default:
            throw ParsingError.invalidTokens(expecting: "Expecting identifier")
        }
        
    }
    
    mutating func definition() throws -> Function {
        _ = popCurrentToken() // Removing 'def'
        let proto = try prototype()
        let body = try expression()
        
        if try peekCurrentToken() != .definitionEnd {
            throw ParsingError.invalidTokens(expecting: "Expecting: end")
        }
        
        _ = popCurrentToken() // Removing 'end'
        let function = Function(prototype: proto, body: body)
        
        return function
    }
    
    func peekCurrentToken() throws -> Token {
        
        if index < tokens.count {
            return tokens[index]
        }
        
        throw ParsingError.incompleteExpression
    }
    
    mutating func popCurrentToken() -> Token {
        let token = tokens[index]
        index += 1
        
        return token
    }
    
    public mutating func parse() throws -> [ASTNode] {
        var nodes = [ASTNode]()
        while index < tokens.count {
            switch try peekCurrentToken() {
            case .definitionBegin:
                let def = try definition()
                
                nodes.append(ASTNode.functionNode(def))
            default:
                let expr = try expression()
                //Create a lambda
                let proto = Prototype(name: "", args: [])
                let lambda = Function(prototype: proto, body: expr)
                
                nodes.append(ASTNode.functionNode(lambda))
            }
        }
        
        return nodes
    }
}

