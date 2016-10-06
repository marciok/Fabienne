//
//  main.swift
//  RecursiveDescentParser
//
//  Created by Marcio Klepacz on 9/28/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import Foundation

//print("Let's parse: ")
let chars = Array(readLine()!.characters)

//print("Exiting status: \(match(expr: chars))")

public class TreeNode<T> {
    public var value: T
    public var parent: TreeNode?
    public var children = [TreeNode<T>]()
    
    public init(value: T) {
        self.value = value
    }
    
    public func append(child node: TreeNode<T>) {
        self.children.append(node)
        node.parent = self
    }
}

extension TreeNode: CustomStringConvertible {
    public var description: String {
        var s = "\(value)"
        if !children.isEmpty {
            s += " {" + children.map { $0.description }.joined(separator: ", ") + "}"
        }
        return s
    }
}



/*
 expr: form | num
 form: '(' op spc expr spc expr ')'
 op: [+-]
 num: [0..9]
 spc: " "
 
 */

enum ParsingError: Error {
    case invalidInput(expecting: String)
    case missingCharacter(missing: String)
}

struct Parser {
    
    var tree: TreeNode<Character>?
    var input: [Character]
    var index = 0
        
    init(input: [Character]) {
        self.input = input
    }
    
    mutating func num() throws -> TreeNode<Character> {
        let result = (Int(peekCurrentChar().description) != nil)
        
        if !result {
            throw ParsingError.invalidInput(expecting: "expecting number")
        }
        
        return TreeNode(value: peekCurrentChar())
    }
    
    mutating func spc() throws -> TreeNode<Character> {
        let result = peekCurrentChar().description == " "
        
        if !result {
            throw ParsingError.invalidInput(expecting: "expecting empty space")
        }
        
        return TreeNode(value: peekCurrentChar())
    }
    
    mutating func op() throws -> TreeNode<Character> {
        
        switch peekCurrentChar() {
        case Character("-"), Character("+"):
            
            return TreeNode(value: peekCurrentChar())
        default:
            throw ParsingError.invalidInput(expecting: "expecting operator: +, -")
        }
    }
    
    mutating func form() throws -> TreeNode<Character> {
        
        _ = popCurrentToken() // Removing '('
        
        let opNode = try op()
        _ = popCurrentToken() // Removing '+ or -'
        
        _ = try spc()
        _ = popCurrentToken() // Removing ' '
        
        let exprNode1 = try expr()
        
        _ = try spc()
        _ = popCurrentToken() // Removing ' '
        
        let exprNode2 = try expr()
        
        if peekCurrentChar() == Character(")") {
            _ = popCurrentToken() // Removing number or expression    
        } else {
            throw ParsingError.missingCharacter(missing: ")")
        }
        
        // Building tree
        let tree = opNode
        exprNode1.parent = tree
        tree.append(child: exprNode1)
        exprNode2.parent = tree
        tree.append(child: exprNode2)
        
        return tree
    }
    
    mutating func expr() throws -> TreeNode<Character> {
        let currentChar = peekCurrentChar()
        
        if currentChar == Character("(") {
            return try form()
        } else if Int(currentChar.description) != nil {
            let numParsed = try num()
            popCurrentToken()
            return numParsed
        } else {
            throw ParsingError.invalidInput(expecting: "not able to parse expression")
        }
    }
    
    func peekCurrentChar() -> Character {
        return input[index]
    }
    
    mutating func popCurrentToken() -> Character {
        let char = input[index]
        index += 1
        
        return char
    }
    
    public mutating func parse() throws -> TreeNode<Character> {
        index = 0
        var nodes = TreeNode(value: Character(" "))
        
        while index < input.count {
            nodes = try expr()
        }
        
        return nodes
    }
}

var parser = Parser(input: chars)

do {
    let result = try parser.parse()
    print("Parsing Result: \(result)")
} catch let error as ParsingError {
    
    switch error {
    case .invalidInput:
        print("Invalid input: \(error)")
    case .missingCharacter:
        print("Missing Character: \(error)")
    }
}




