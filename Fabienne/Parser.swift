//
//  Parser.swift
//  Fabienne
//
//  Created by Marcio Klepacz on 10/6/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//
import Foundation

//TODO: Naïve implementation. REFACTOR!!!
final class FunctionNode {
    var arguments: [String : Int?] = [:]
    var body: ASTNode
    
    init(arguments: [String : Int?], body: ASTNode) {
        self.arguments = arguments
        self.body = body
    }
}

var implTable: [String : FunctionNode] = [:]

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
    
    var tree: ASTNode?
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
    
    mutating func number() throws -> ASTNode {
        
        switch try peekCurrentToken() {
        case .number:
            let token = TreeNode(value: popCurrentToken())
            
            return token
        default:
            throw ParsingError.invalidTokens(expecting: "Expecting number")
        }
    }
    
    mutating func identifier() throws -> ASTNode {
        
        switch try peekCurrentToken() {
        case .identifier:
            let token = TreeNode(value: popCurrentToken())
            
            return token
        default:
            throw ParsingError.invalidTokens(expecting: "Expecting identifier")
        }
    }
    
    mutating func binaryOperator() throws -> ASTNode {
        switch try peekCurrentToken() {
        case .other("-"),
             .other("*"),
             .other("/"),
             .other("+"):
            
            return TreeNode(value: popCurrentToken())
        default:
            throw ParsingError.invalidTokens(expecting: "Expecting operator")
        }
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
    mutating func binaryExpression(_ node: ASTNode, exprPrecedence: Int = 0) throws -> ASTNode {
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
            
            binOpNode.append(child: lhs)
            binOpNode.append(child: rhs)
            
            lhs = binOpNode
        }
    }
    
    /// primaryExpression -> number | identifier | callExpression | '(' expression ')'
    mutating func primaryExpression() throws -> ASTNode {
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
            let id = try identifier()
            
            if index >= tokens.count {
                return id
            }
            
            if try peekCurrentToken() == .parensOpen  {
                return try callExpression(id)
            }
            
            return id
            
        default:
            throw ParsingError.invalidTokens(expecting: "Expecting number or another expression")
        }
    }
    
    /// expression -> [primaryExpression (binaryOperator primaryExpression)* ];
    mutating func expression() throws -> ASTNode {
        
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
    
    /// callExpression    : identifier '(' expression ')'
    mutating func callExpression(_ id: ASTNode) throws -> ASTNode {
        
        if try peekCurrentToken() != .parensOpen {
            throw ParsingError.invalidTokens(expecting: "Expecting: (")
        }
        
        _ = popCurrentToken() // Removing '('
        
       let expression = try self.expression()
        
        if try peekCurrentToken() != .parensClose {
            throw ParsingError.invalidTokens(expecting: "Expecting: )")
        }
        
        _ = popCurrentToken() // Removing ')'
        
        id.append(child: expression)
        
        return id
    }
    mutating func prototype() throws -> ProtoNode {
        
        switch try peekCurrentToken() {
        case .identifier:
            let protoNode = ProtoNode(value: popCurrentToken())
            
            if try peekCurrentToken() != .parensOpen {
                throw ParsingError.invalidTokens(expecting: "Expecting: (")
            }
            
            _ = popCurrentToken() // Removing '('
            
            switch try peekCurrentToken() {
            case .identifier:
                let argument = popCurrentToken() //TODO: Increase number of arguments
                protoNode.arguments.append(argument)
                
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
    
    mutating func definition() throws -> ASTNode {
        _ = popCurrentToken() // Removing 'def'
        let proto = try prototype()
        let body = try expression()
        
        if try peekCurrentToken() != .definitionEnd {
            throw ParsingError.invalidTokens(expecting: "Expecting: end")
        }
        
        _ = popCurrentToken() // Removing 'end'
        
        proto.append(child: body)
        
        let function = FunctionNode(arguments: [proto.arguments.first!.rawValue() : nil] , body: body)
        implTable[proto.value.rawValue()] = function
        
        return proto
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
    
    public mutating func parse() throws -> ASTNode {
        
        switch try peekCurrentToken() {
        case .definitionBegin:
            return try definition()
        default:
            return try expression()
        }
        
    }
}

