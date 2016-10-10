//
//  Parser.swift
//  Fabienne
//
//  Created by Marcio Klepacz on 10/6/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//


/*
 Grammar:
 expr -> form | num
 form -> '(' op spc expr spc expr ')'
 op   -> [+-]
 num  -> [0..9]
 spc  -> " "
 */

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
    
    mutating func num() throws -> ASTNode {
        
        switch try peekCurrentToken() {
        case .number:
            let token = TreeNode(value: popCurrentToken())
            
            return token
        default:
            throw ParsingError.invalidTokens(expecting: "Expecting number")
        }
    }
    
    mutating func op() throws -> ASTNode {
        
        switch try peekCurrentToken() {
        case .other("-"),
             .other("+"):
            
            return TreeNode(value: popCurrentToken())
        default:
            throw ParsingError.invalidTokens(expecting: "Expected operator: +, -")
        }
    }
    
    mutating func form() throws -> ASTNode {
        
        _ = popCurrentToken() // Removing '('
        
        let opNode = try op()
        
        let exprNode1 = try expr()
        
        let exprNode2 = try expr()
        
        switch try peekCurrentToken() {
        case .parensClose:
            _ = popCurrentToken()
            break
        default:
            throw ParsingError.invalidTokens(expecting: ")")
        }
        
        // Building tree
        let tree = opNode
        tree.append(child: exprNode1)
        tree.append(child: exprNode2)
        
        return tree
    }
    
    mutating func expr() throws -> ASTNode {
        let currentToken = try peekCurrentToken()
        
        switch currentToken {
        case .parensOpen:
            return try form()
        case .number:
            return try num()
        default:
            throw ParsingError.invalidTokens(expecting: "not able to parse expression")
        }
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
    
    public mutating func parse() throws -> ASTNode? {
        var nodes: ASTNode? = nil
        
        while index < tokens.count {
            nodes = try expr()
        }
        
        return nodes
    }
}

