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
    case inclompleteExpression
}

struct Parser {
    
    var tree: ASTNode?
    var tokens: [Token]
    var index = 0
    
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
    
    mutating func binaryOperator() throws -> ASTNode {
        switch try peekCurrentToken() {
        case .other("-"),
             .other("*"),
             .other("+"):
            
            return TreeNode(value: popCurrentToken())
        default:
            throw ParsingError.invalidTokens(expecting: "Expecting operator: +, -")
        }
    }
    
    /// (binaryOperator primaryExpression)*
    mutating func binaryExpression(_ lhs: ASTNode) throws -> ASTNode {
        
        if index >= tokens.count {
            return lhs
        }
        
        if try peekCurrentToken() == Token.parensClose {
            return lhs
        }
        
        let binOpNodeFetched = try binaryOperator()
        
        binOpNodeFetched.append(child: lhs)
        
        let rhs = try primaryExpression()
    
        binOpNodeFetched.append(child: rhs)
        
        return try binaryExpression(binOpNodeFetched)
    }
    
    /// primaryExpression -> number | '(' expression ')'
    mutating func primaryExpression() throws -> ASTNode {
        let currentToken = try peekCurrentToken()
        
        switch currentToken {
        case .parensOpen:
            _ = popCurrentToken() // Removing '('
            let expressionNode = try expression()
            
            
            if index >= tokens.count {
                throw ParsingError.inclompleteExpression
            }
            _ = popCurrentToken() // Removing ')'
            
            return expressionNode
        case .number:
            return try number()
        default:
            throw ParsingError.invalidTokens(expecting: "Expecting number or another expression")
        }
    }
    
    /// expression -> [primaryExpression (binaryOperator primaryExpression)* ];
    mutating func expression() throws -> ASTNode {
        
        let primaryExprNode = try primaryExpression()
        let binaryOpNode = try binaryExpression(primaryExprNode)
        
        return binaryOpNode
    }
    
    func peekCurrentToken() throws -> Token {
        
        if index < tokens.count {
            return tokens[index]
        }
        
        throw ParsingError.inclompleteExpression
    }
    
    mutating func popCurrentToken() -> Token {
        let token = tokens[index]
        index += 1
        
        return token
    }
    
    
    /**
     Grammar:
     expression -> [primaryExpression (binaryOperator primaryExpression)* ];
     primaryExpression -> [number | '(' expression ')']
     binaryOperator   -> [+-]
     number -> [0..9]
     
     **/
    public mutating func parse() throws -> ASTNode? {
        var nodes: ASTNode? = nil //TODO: Remove optional
        
        while index < tokens.count {
            nodes = try expression()
        }
        
        return nodes
    }
}

