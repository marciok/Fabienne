//
//  InterpreterTests.swift
//  Fabienne
//
//  Created by Marcio Klepacz on 10/6/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import XCTest

class InterpreterTests: XCTestCase {

    func testResultOfExpression() {
        let expectedResult = 3
        let tree = TreeNode.init(value: Token.other("+"))
        let left = TreeNode.init(value: Token.number(1))
        let right = TreeNode.init(value: Token.number(2))
        
        tree.append(child: left)
        tree.append(child: right)
        
        let result = try! Interpreter.eval(tree)
        
        XCTAssertTrue(expectedResult == result)
    }
    
    func testResultOfExpressionMultplication() {
        let expectedResult = 6
        let tree = TreeNode.init(value: Token.other("*"))
        let left = TreeNode.init(value: Token.number(3))
        let right = TreeNode.init(value: Token.number(2))
        
        tree.append(child: left)
        tree.append(child: right)
        
        let result = try! Interpreter.eval(tree)
        
        XCTAssertTrue(expectedResult == result)
    }
    
    func testResultOfLongExpression() {
        let expectedResult = 5
        let tree = TreeNode.init(value: Token.other("+"))
        let left = TreeNode.init(value: Token.other("-"))
        tree.append(child: left)
        let right = TreeNode.init(value: Token.number(4))
        tree.append(child: right)
        let left1stChild = TreeNode.init(value: Token.number(2))
        let left2ndChild = TreeNode.init(value: Token.number(1))
        
        left.append(child: left1stChild)
        left.append(child: left2ndChild)
        
        let result = try! Interpreter.eval(tree)
        
        XCTAssertTrue(expectedResult == result)
    }
    
}
