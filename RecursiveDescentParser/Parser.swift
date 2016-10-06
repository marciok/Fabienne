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
 op -> [+-]
 num -> [0..9]
 spc -> " "
 */

import Foundation


public enum ParsingError: Error {
    case invalidInput(expecting: String)
    case inclompleteExpression
}

struct Parser {
    
    var tree: ASTNode?
    var input: [Character]
    var index = 0
    
    init(input: [Character]) {
        self.input = input
    }
    
    mutating func num() throws -> ASTNode {
        
        if Int((try peekCurrentChar()).description) == nil {
            throw ParsingError.invalidInput(expecting: "Expecting number")
        }
        
        return TreeNode(value: popCurrentChar())
    }
    
    mutating func op() throws -> ASTNode {
        
        switch try peekCurrentChar() {
        case Character("-"),
             Character("+"):
            
            return TreeNode(value: popCurrentChar())
        default:
            throw ParsingError.invalidInput(expecting: "Expected operator: +, -")
        }
    }
    
    mutating func popIfHas(char: Character) throws {
        if try peekCurrentChar() == char {
            _ = popCurrentChar()
            
            return
        }
        
        throw ParsingError.invalidInput(expecting: "Exptected '\(char)' character")
    }
    
    mutating func form() throws -> ASTNode {
        
        _ = popCurrentChar() // Removing '('
        
        let opNode = try op()
        
        try popIfHas(char: Character(" "))
        
        let exprNode1 = try expr()
        
        try popIfHas(char: Character(" "))
        
        let exprNode2 = try expr()
        
        try popIfHas(char: Character(")"))
        
        // Building tree
        let tree = opNode
        tree.append(child: exprNode1)
        tree.append(child: exprNode2)
        
        return tree
    }
    
    mutating func expr() throws -> ASTNode {
        let currentChar = try peekCurrentChar()
        
        if currentChar == Character("(") {
            return try form()
        } else if Int(currentChar.description) != nil {
            return try num()
        }
        
        throw ParsingError.invalidInput(expecting: "not able to parse expression")
    }
    
    func peekCurrentChar() throws -> Character {
        
        if index < input.count {
            return input[index]
        }
        
        throw ParsingError.inclompleteExpression
    }
    
    mutating func popCurrentChar() -> Character {
        let char = input[index]
        index += 1
        
        return char
    }
    
    public mutating func parse() throws -> ASTNode? {
        var nodes: ASTNode? = nil
        
        while index < input.count {
            nodes = try expr()
        }
        
        return nodes
    }
}

