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
        let tree = TreeNode.init(value: Character("+"))
        let left = TreeNode.init(value: Character("1"))
        let right = TreeNode.init(value: Character("2"))
        
        tree.append(child: left)
        tree.append(child: right)
        
        let result = try!  Interpreter.eval(tree)
        
        XCTAssertTrue(expectedResult == result)
    }
    
    func testResultOfLongExpression() {
        let expectedResult = 5
        let tree = TreeNode.init(value: Character("+"))
        let left = TreeNode.init(value: Character("-"))
        tree.append(child: left)
        let right = TreeNode.init(value: Character("4"))
        tree.append(child: right)
        let left1stChild = TreeNode.init(value: Character("2"))
        let left2ndChild = TreeNode.init(value: Character("1"))
        
        left.append(child: left1stChild)
        left.append(child: left2ndChild)
        
        let result = try! Interpreter.eval(tree)
        
        XCTAssertTrue(expectedResult == result)
    }
}
