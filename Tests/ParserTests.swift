//
//  Tests.swift
//  Tests
//
//  Created by Marcio Klepacz on 9/29/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import XCTest
import RecursiveDescentParser

class ParserTests: XCTestCase {
    
    
    func test_validInputWithParemIndie() {
        let input = Array("(+ (- 1 2) 4)".characters)
        
        let root = TreeNode.init(value: Character("+"))
        let left = TreeNode.init(value: Character("-"))
        root.append(child: left)
        let right = TreeNode.init(value: Character("4"))
        root.append(child: right)
        let left1stChild = TreeNode.init(value: Character("1"))
        let left2ndChild = TreeNode.init(value: Character("2"))
        
        left.append(child: left1stChild)
        left.append(child: left2ndChild)
        
        var parser = Parser(input: input)
        let tree = try! parser.parse()
        XCTAssert(String(describing: root) == String(describing: tree!))

    }
    
    func test_validInputWithParem() {
        let input = Array("(+ 1 2)".characters)
        
        let root = TreeNode.init(value: Character("+"))
        let left = TreeNode.init(value: Character("1"))
        let right = TreeNode.init(value: Character("2"))
        
        root.append(child: left)
        root.append(child: right)
        
        var parser = Parser(input: input)
        let tree = try! parser.parse()
        
        XCTAssert(String(describing: root) == String(describing: tree!))
    }
    
    func test_validInputWithMinus() {
        let input = Array("(- 1 2)".characters)
        
        let root = TreeNode.init(value: Character("-"))
        let left = TreeNode.init(value: Character("1"))
        let right = TreeNode.init(value: Character("2"))
        
        root.append(child: left)
        root.append(child: right)
        
        var parser = Parser(input: input)
        let tree = try! parser.parse()
        
        XCTAssert(String(describing: root) == String(describing: tree!))
    }

    func test_invalidInput() {
        let input = Array("(1 + 2)".characters)
        var expectedError: Error? = nil
        
        do {
            var parser = Parser(input: input)
            _ = try parser.parse()
        } catch let error   {
            expectedError = error
        }
        
        if let error = expectedError,
            case ParsingError.invalidInput(expecting: "Expected operator: +, -") = error {
            XCTAssertTrue(true)
        } else {
            XCTFail()
        }
    }

    func test_invalidInputNoNumbers() {
        let input = Array("(+62)".characters)
        var expectedError: Error? = nil
        
        do {
            var parser = Parser(input: input)
            _ = try parser.parse()
        } catch let error   {
            expectedError = error
        }
        
        if let error = expectedError,
            case ParsingError.invalidInput(expecting: "Exptected ' ' character") = error {
            XCTAssertTrue(true)
        } else {
            XCTFail()
        }
    }
    
    func test_invalidInputNoOperator() {
        let input = Array("(1 2)".characters)
        var expectedError: Error? = nil
        
        do {
            var parser = Parser(input: input)
            _ = try parser.parse()
        } catch let error   {
            expectedError = error
        }
        
        if let error = expectedError,
            case ParsingError.invalidInput(expecting: "Expected operator: +, -") = error {
            XCTAssertTrue(true)
        } else {
            XCTFail()
        }
    }
    
    func test_incompleteExpression() {
        let input = Array("(+ 1 2".characters)
        var expectedError: Error? = nil
        
        do {
            var parser = Parser(input: input)
            _ = try parser.parse()
        } catch let error   {
            expectedError = error
        }
        
        if let error = expectedError,
            case ParsingError.inclompleteExpression = error {
            XCTAssertTrue(true)
        } else {
            XCTFail()
        }
    }
    
    func test_incompleteExpressionLarge() {
        let input = Array("(+ (- 1 2) ".characters)
        var expectedError: Error? = nil
        
        do {
            var parser = Parser(input: input)
            _ = try parser.parse()
        } catch let error   {
            expectedError = error
        }
        
        if let error = expectedError,
            case ParsingError.inclompleteExpression = error {
            XCTAssertTrue(true)
        } else {
            XCTFail()
        }
    }
}
