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


var index = 0;
var tree: TreeNode<Character>?
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

public func parse(expr input: Array<Character>) -> Bool {
    
    func num() -> TreeNode<Character>? {
        var node: TreeNode<Character>? = nil
        let result =  (Int(input[index].description) != nil)
        
        if result {
            node = TreeNode(value: input[index])

            index += 1
        }
        
        return node
    }
    
    func spc() -> TreeNode<Character>? {
        var node: TreeNode<Character>? = nil
        let result = input[index].description == " "
        
        if result {
            node = TreeNode(value: input[index])
            index += 1
        }
        
        return node
    }
    
    func op() -> TreeNode<Character>? {
        var node: TreeNode<Character>? = nil
        
        switch input[index] {
        case "-", "+":
            node = TreeNode(value: input[index])
            
            index += 1
            
            return node
        default:
            return node
        }
    }
    
    
    func form() -> TreeNode<Character>? {
        
        let p1 = hasChar("(")
        if !p1 {
            return nil
        }
        
        let opNode = op()
        let spcNode1 = spc()
        let exprNode1 = expr()
        let spcNode2 = spc()
        let exprNode2 = expr()
        
        let r1 = opNode != nil
        let r2 = spcNode1 != nil
        let r3 = exprNode1 != nil
        let r4 = spcNode2 != nil
        let r5 = exprNode2 != nil
        let p2 = hasChar(")")
            
        if !(p1 && r1 && r2 && r3 && r4 && r5 && p2) {
            return nil
        }
         // Building tree
        let tree = opNode!
        exprNode1!.parent = tree
        tree.append(child: exprNode1!)
        exprNode2!.parent = tree
        tree.append(child: exprNode2!)
        
        return tree
    }

    func hasChar(_ exptected: Character) -> Bool {
        let has = exptected.description == input[index].description
        
        if has {
            index += 1
        }
        
        return has
    }
    
    func expr() -> TreeNode<Character>? {
        print("Index at: \(index)")
        let firstExpr = form()
        // It's over
        if input.count == index {
            return firstExpr
        }
        
        let secondExpr = num()
        
        if firstExpr != nil {
            return firstExpr
        }
        
        if secondExpr != nil {
            return secondExpr
        }
        
        return nil
    }
    
    index = 0
    let tree = expr()
    print(tree)
    return tree != nil
}

print("Parsing: \(parse(expr: chars))")



