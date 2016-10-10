//
//  Tests.swift
//  Tests
//
//  Created by Marcio Klepacz on 9/29/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import XCTest

class ParserTests: XCTestCase {
    
    
    func test_validInputWithParemIndie() {
        let tokens: [Token] = [.parensOpen, .other("+"), .parensOpen, .other("-"), .number(2), .number(1), .parensClose, .number(4), .parensClose]
        
        let root = TreeNode.init(value: Token.other("+"))
        let left = TreeNode.init(value: Token.other("-"))
        root.append(child: left)
        let right = TreeNode.init(value: Token.number(4))
        root.append(child: right)
        let left1stChild = TreeNode.init(value: Token.number(2))
        let left2ndChild = TreeNode.init(value: Token.number(1))
        
        left.append(child: left1stChild)
        left.append(child: left2ndChild)
        
        var parser = Parser(tokens: tokens)
        let tree = try! parser.parse()
        XCTAssert(String(describing: root) == String(describing: tree!))
    }
    
    func test_validInputWithParem() {
        let tokens: [Token] = [.parensOpen, .other("+"), .number(1), .number(2), .parensClose]
        
        let root = TreeNode.init(value: Token.other("+"))
        let left = TreeNode.init(value: Token.number(1))
        let right = TreeNode.init(value: Token.number(2))
        
        root.append(child: left)
        root.append(child: right)
        
        var parser = Parser(tokens: tokens)
        let tree = try! parser.parse()
        
        XCTAssert(String(describing: root) == String(describing: tree!))
    }
    
    func test_validInputWithMinus() {
        let tokens: [Token] = [.parensOpen, .other("-"), .number(1), .number(2), .parensClose]
        
        let root = TreeNode.init(value: Token.other("-"))
        let left = TreeNode.init(value: Token.number(1))
        let right = TreeNode.init(value: Token.number(2))
        
        root.append(child: left)
        root.append(child: right)
        
        var parser = Parser(tokens: tokens)
        let tree = try! parser.parse()
        
        XCTAssert(String(describing: root) == String(describing: tree!))
    }

    func test_invalidInput() {
        let tokens: [Token] = [.parensOpen, .number(1), .other("+"), .number(2), .parensClose]
        var expectedError: Error? = nil
        
        do {
            var parser = Parser(tokens: tokens)
            _ = try parser.parse()
        } catch let error   {
            expectedError = error
        }
        
        if let error = expectedError,
            case ParsingError.invalidTokens(expecting: "Expected operator: +, -") = error {
            XCTAssertTrue(true)
        } else {
            XCTFail()
        }
    }

    func test_invalidInputNoNumbers() {
        let tokens: [Token] = [.parensOpen, .other("-"), .number(12), .parensClose]
        var expectedError: Error? = nil
        
        do {
            var parser = Parser(tokens: tokens)
            _ = try parser.parse()
        } catch let error   {
            expectedError = error
        }
        
        if let error = expectedError,
            case ParsingError.invalidTokens(expecting: "not able to parse expression") = error {
            XCTAssertTrue(true)
        } else {
            XCTFail()
        }
    }
    
    func test_invalidInputNoOperator() {
        let tokens: [Token] = [.parensOpen, .number(1), .number(2), .parensClose]
        var expectedError: Error? = nil
        
        do {
            var parser = Parser(tokens: tokens)
            _ = try parser.parse()
        } catch let error   {
            expectedError = error
        }
        
        if let error = expectedError,
            case ParsingError.invalidTokens(expecting: "Expected operator: +, -") = error {
            XCTAssertTrue(true)
        } else {
            XCTFail()
        }
    }
    
    func test_incompleteExpression() {
        let tokens: [Token] = [.parensOpen, .other("+"), .number(1), .number(2)]
        var expectedError: Error? = nil
        
        do {
            var parser = Parser(tokens: tokens)
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
        let tokens: [Token] = [.parensOpen, .other("+"), .parensOpen, .other("-"), .number(1), .number(2), .parensClose]
        var expectedError: Error? = nil
        
        do {
            var parser = Parser(tokens: tokens)
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
