//
//  Tests.swift
//  Tests
//
//  Created by Marcio Klepacz on 9/29/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import XCTest

class ParserTests: XCTestCase {
    
    func test_binaryExpressionWithoutParenthesis(){
        let tokens: [Token] = [.number(1), .other("+"), .number(2)]
        let root = TreeNode(value: Token.other("+"))
        let left = TreeNode(value: Token.number(1))
        root.append(child: left)
        let right = TreeNode(value: Token.number(2))
        root.append(child: right)
        
        var parser = Parser(tokens: tokens)
        let tree = try! parser.parse()
        XCTAssert(String(describing: root) == String(describing: tree!))
    }
    
    func test_expressionWithoutParenthesis(){
        let tokens: [Token] = [.number(3), .other("-"), .number(4), .other("+"), .number(2)]
        
        let root = TreeNode(value: Token.other("+"))
        
        let left = TreeNode.init(value: Token.other("-"))
        root.append(child: left)
        left.append(child: TreeNode(value: .number(3)))
        left.append(child: TreeNode(value: .number(4)))
        let right = TreeNode(value: Token.number(2))
        root.append(child: right)
        
        var parser = Parser(tokens: tokens)
        let tree = try! parser.parse()
        XCTAssert(String(describing: root) == String(describing: tree!))
    }
    
    func test_validInputWithParemIndie() {
        let tokens: [Token] = [.number(5), .other("-"), .parensOpen, .number(2), .other("+"), .number(3), .parensClose]
        
        let root = TreeNode(value: Token.other("-"))
        let right = TreeNode(value: Token.other("+"))
        let left = TreeNode(value: Token.number(5))
        root.append(child: left)
        root.append(child: right)
        
        
        let right1stChild = TreeNode.init(value: Token.number(2))
        let right2ndChild = TreeNode.init(value: Token.number(3))
        
        right.append(child: right1stChild)
        right.append(child: right2ndChild)
        
        var parser = Parser(tokens: tokens)
        let tree = try! parser.parse()
        XCTAssert(String(describing: root) == String(describing: tree!))
    }
    
    func test_validInputWithParem() {
        let tokens: [Token] = [.number(1), .other("+"), .parensOpen, .number(2), .other("+"), .parensOpen, .number(3), .other("-"), .number(2), .parensClose, .parensClose]
        
        let root = TreeNode(value: Token.other("+"))
        let left = TreeNode(value: Token.number(1))
        let right = TreeNode(value: Token.other("+"))
        
        root.append(child: left)
        root.append(child: right)
        
        right.append(child: TreeNode(value: .number(2)))
        let rightChild = TreeNode(value: Token.other("-"))
        right.append(child: rightChild)

        rightChild.append(child: TreeNode(value: .number(3)))
        rightChild.append(child: TreeNode(value: .number(2)))
        
        var parser = Parser(tokens: tokens)
        let tree = try! parser.parse()
        
        XCTAssert(String(describing: root) == String(describing: tree!))
    }
    
    func test_invalidInputNoNumbers() {
        let tokens: [Token] = [.parensOpen, .number(1), .other("+"), .number(2)]
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
    
    func test_invalidTokensExpectingNumber() {
        let tokens: [Token] = [.number(1), .other("+"), .other("-")]
        var expectedError: Error? = nil
        
        do {
            var parser = Parser(tokens: tokens)
            _ = try parser.parse()
        } catch let error   {
            expectedError = error
        }
        
        if let error = expectedError,
            case ParsingError.invalidTokens(expecting: "Expecting number or another expression") = error {
            XCTAssertTrue(true)
        } else {
            XCTFail()
        }
    }
    
    func test_invalidTokensExpectingValidOperator() {
        let tokens: [Token] = [.number(1), .number(2)]
        var expectedError: Error? = nil
        
        do {
            var parser = Parser(tokens: tokens)
            _ = try parser.parse()
        } catch let error   {
            expectedError = error
        }
        
        if let error = expectedError,
            case ParsingError.invalidTokens(expecting: "Expecting operator: +, -") = error {
            XCTAssertTrue(true)
        } else {
            XCTFail()
        }
    }
}
