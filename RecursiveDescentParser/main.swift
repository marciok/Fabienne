//
//  main.swift
//  RecursiveDescentParser
//
//  Created by Marcio Klepacz on 9/28/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import Foundation

// Grammar
// s : '(' s ')' | e
// i.e, ( ), (( ))

func match(expr input: Array<Character>) -> Int? {
    var index = 0;
    var r: Bool = false
    
    func advanceAndCheck(expected: Character) -> Bool {
//        var backtrack = index
        
        if input.count == index {
            return false
        }
        let result = input[index] == expected
        
        if result {
            index += 1
        } else {
//            backtrack = index
        }
        
        return result
    }

    // s : '(' s ')' | e
    func s() -> Bool {
//        var backtrack = index
        
        let first = advanceAndCheck(expected: "(") && s() && advanceAndCheck(expected: ")")
        if input.count == index {
            
            if !first {
                return false
            }
            
            return r
        }
        
        let second = input[index] == " ".characters.first!
        
        if second {
            index += 1
        } else {
//            backtrack = index
        }
        
        if first {
            r = first
        }
        
        if !first && second {
            r = second
        }
            
//        print(r)
        
        return r
    }
    
    if s() {
        return index
    }
    
    return nil;
}

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

public func parse(expr input: Array<Character>) -> Bool {
    
    func num() -> Bool {
        let result =  (Int(input[index].description) != nil)
        
        if result {
            let node = TreeNode(value: input[index])
            tree?.append(child: node)

            index += 1
        }
        
        return result
    }
    
    func spc() -> Bool {
        let result = input[index].description == " "
        
        if result {
            index += 1
        }
        
        return result
    }
    
    func op() -> Bool {
        switch input[index] {
        case "+":
            if tree == nil {
                tree = TreeNode(value: input[index])
            } else {
                let node = TreeNode(value: input[index])
                tree?.append(child: node)
            }
            
            index += 1
            
            return true
        case "-":
            if tree == nil {
                tree = TreeNode(value: input[index])
            } else {
                let node = TreeNode(value: input[index])
                tree?.append(child: node)
            }
            
            index += 1
            return true
        default:
            return false
        }
    }
    
    
    func form() -> Bool {
        
        let p1 = hasChar("(")
        if !p1 {
            return false
        }
        let r1 = op()
        let r2 = spc()
        let r3 = expr()
        let r4 = spc()
        let r5 = expr()
        let p2 = hasChar(")")
            
        return p1 && r1 && r2 && r3 && r4 && r5 && p2
    }

    func hasChar(_ exptected: Character) -> Bool {
        let has = exptected.description == input[index].description
        
        if has {
            index += 1
        }
        
        return has
    }
    
    func expr() -> Bool {
        print("Index at: \(index)")
        let firstExpr = form()
        // It's over
        if input.count == index {
            return firstExpr
        }
        
        let secondExpr = num()
        
        if firstExpr {
            return firstExpr
        }
        
        if secondExpr {
            return secondExpr
        }
        
        return false
    }
    
    index = 0
    return expr()
}

print("Exiting status: \(parse(expr: chars))")

print(tree)

