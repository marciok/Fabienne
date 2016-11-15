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
        let tokens: [Token] = [.number(1), ._operator("+"), .number(2)]
        let binExpr = Expression.binaryExpr("+", .literalExpr(1), .literalExpr(2))
        let proto = Prototype(name: "", funType: .normal, args: [])
        let lambda = Function(prototype: proto, body: binExpr)
        
        var parser = Parser(tokens: tokens)
        let tree = try! parser.parse().first!
        XCTAssert(String(describing: lambda) == String(describing: tree))
    }
    
    func test_binaryExpressionWithIdentifier(){
        let tokens: [Token] = [.number(1), ._operator("+"), .identifier("x")]
        let binExpr = Expression.binaryExpr("+", .literalExpr(1), .variableExpr("x"))
        let proto = Prototype(name: "", funType: .normal, args: [])
        let lambda = Function(prototype: proto, body: binExpr)
        
        var parser = Parser(tokens: tokens)
        let tree = try! parser.parse().first!
        XCTAssert(String(describing: lambda) == String(describing: tree))
    }
    
    func test_expressionWithoutParenthesis(){
        let tokens: [Token] = [.number(3), ._operator("-"), .number(4), ._operator("+"), .number(2)]
        let lhs = Expression.binaryExpr("-", .literalExpr(3), .literalExpr(4))
        let binExpr = Expression.binaryExpr("+", lhs, .literalExpr(2))
        let proto = Prototype(name: "", funType: .normal, args: [])
        let lambda = Function(prototype: proto, body: binExpr)
        
        var parser = Parser(tokens: tokens)
        let tree = try! parser.parse().first!
        XCTAssert(String(describing: lambda) == String(describing: tree))
    }
    
    func test_validInputWithParemIndie() {
        let tokens: [Token] = [.number(5), ._operator("-"), .parensOpen, .number(2), ._operator("+"), .number(3), .parensClose]
        let rhs = Expression.binaryExpr("+", .literalExpr(2), .literalExpr(3))
        let binExpr = Expression.binaryExpr("-", .literalExpr(5), rhs)
        let proto = Prototype(name: "", funType: .normal, args: [])
        let lambda = Function(prototype: proto, body: binExpr)
        
        var parser = Parser(tokens: tokens)
        let tree = try! parser.parse().first!
        XCTAssert(String(describing: lambda) == String(describing: tree))
    }
    
    func test_validInputWithParem() {
        let tokens: [Token] = [.number(1), ._operator("+"), .parensOpen, .number(2), ._operator("+"), .parensOpen, .number(3), ._operator("-"), .number(2), .parensClose, .parensClose]
        
        let lhs1 = Expression.binaryExpr("-", .literalExpr(3), .literalExpr(2))
        let rhs = Expression.binaryExpr("+", .literalExpr(2), lhs1)
        let binExpr = Expression.binaryExpr("+", .literalExpr(1), rhs)
        let proto = Prototype(name: "", funType: .normal, args: [])
        let lambda = Function(prototype: proto, body: binExpr)

        var parser = Parser(tokens: tokens)
        let tree = try! parser.parse().first!
        
        XCTAssert(String(describing: lambda) == String(describing: tree))
    }
    
    func test_multiplication()  {
        let tokens: [Token] = [.number(3), ._operator("*"), .number(2)]
        let binExpr = Expression.binaryExpr("*", .literalExpr(3), .literalExpr(2))
        let proto = Prototype(name: "", funType: .normal, args: [])
        let lambda = Function(prototype: proto, body: binExpr)
        
        var parser = Parser(tokens: tokens)
        let tree = try! parser.parse().first!
        
        XCTAssert(String(describing: lambda) == String(describing: tree))
    }
    
    func test_OperatorPrecedence()  {
        let tokens: [Token] = [.number(2), ._operator("+"), .number(3), ._operator("*"), .number(5)]
        let rhs = Expression.binaryExpr("*", .literalExpr(3), .literalExpr(5))
        let binExpr = Expression.binaryExpr("+", .literalExpr(2), rhs)
        let proto = Prototype(name: "", funType: .normal, args: [])
        let lambda = Function(prototype: proto, body: binExpr)
        
        var parser = Parser(tokens: tokens)
        let tree = try! parser.parse().first!
        
        XCTAssert(String(describing: lambda) == String(describing: tree))
    }
    
    func test_ParenthesisOverOperatorPrecedence()  {
        let tokens: [Token] = [.parensOpen, .number(2), ._operator("+"),  .number(3), .parensClose, ._operator("*"), .number(5)]
        let rhs = Expression.binaryExpr("+", .literalExpr(2), .literalExpr(3))
        let binExpr = Expression.binaryExpr("*", rhs, .literalExpr(5))
        let proto = Prototype(name: "", funType: .normal, args: [])
        let lambda = Function(prototype: proto, body: binExpr)

        var parser = Parser(tokens: tokens)
        let tree = try! parser.parse().first!
        
        XCTAssert(String(describing: lambda) == String(describing: tree))
    }
    
    func test_definitionDeclaration() {
     let tokens: [Token] = [.definitionBegin, .identifier("foo"), .parensOpen,  .identifier("x"),  .parensClose, .number(1), ._operator("+"), .identifier("x"), .end]
        
        let proto = Prototype(name: "foo", funType: .normal, args: ["x"])
        let body = Expression.binaryExpr("+", .literalExpr(1), .variableExpr("x"))
        let definition = Function(prototype: proto, body: body)
        
        var parser = Parser(tokens: tokens)
        let tree = try! parser.parse().first!
        
        XCTAssert(String(describing: definition) == String(describing: tree))
    }
    
    func test_callExpression() {
        let tokens: [Token] = [.identifier("foo"), .parensOpen,  .number(4),  .parensClose]
        let callExpr = Expression.callExpr("foo", [.literalExpr(4)])
        let proto = Prototype(name: "", funType: .normal, args: [])
        let lambda = Function(prototype: proto, body: callExpr)
        
        var parser = Parser(tokens: tokens)
        let tree = try! parser.parse().first!
        
        XCTAssert(String(describing: lambda) == String(describing: tree))
    }
    
    func test_condExpression() {
        let tokens: [Token] = [._if ,.number(2), ._operator("<"),  .number(4), .then, .number(8), ._else, .number(18)]
        let condExpr = Expression.conditionalExpr(condExpr: .binaryExpr("<", .literalExpr(2), .literalExpr(4)), thenExpr: .literalExpr(8), elseExpression: .literalExpr(18))
        
        let proto = Prototype(name: "", funType: .normal, args: [])
        let lambda = Function(prototype: proto, body: condExpr)
        
        var parser = Parser(tokens: tokens)
        let tree = try! parser.parse().first!
        
        XCTAssert(String(describing: lambda) == String(describing: tree))
    }

    
    func test_declareAndcallExpression() {
        let tokens: [Token] = [.definitionBegin, .identifier("foo"), .parensOpen, .identifier("x"), .parensClose, .number(1), ._operator("+"), .identifier("x"), .end, .identifier("foo"), .parensOpen,  .number(4),  .parensClose]
        
        let protoFoo = Prototype(name: "foo", funType: .normal, args: ["x"])
        let body = Expression.binaryExpr("+", .literalExpr(1), .variableExpr("x"))
        let funcFoo = Function(prototype: protoFoo, body: body)
        
        let callExpr = Expression.callExpr("foo", [.literalExpr(4)])
        let proto = Prototype(name: "", funType: .normal, args: [])
        let lambda = Function(prototype: proto, body: callExpr)
        
        let expectedNodes: [ASTNode] = [.functionNode(funcFoo), .functionNode(lambda)]
        
        var parser = Parser(tokens: tokens)
        let nodes = try! parser.parse()
        
        XCTAssert(expectedNodes.count == nodes.count)
        XCTAssert(String(describing: expectedNodes) == String(describing: nodes))
    }
    
    func test_callExpressionWithOtherExpresssion() {
        let tokens: [Token] = [.identifier("foo"), .parensOpen,  .number(2), ._operator("+"), .number(2),  .parensClose]
        let expr = Expression.binaryExpr("+", .literalExpr(2), .literalExpr(2))
        let callExpr = Expression.callExpr("foo", [expr])
        let proto = Prototype(name: "", funType: .normal, args: [])
        let lambda = Function(prototype: proto, body: callExpr)
        
        var parser = Parser(tokens: tokens)
        let tree = try! parser.parse().first!
        
        XCTAssert(String(describing: lambda) == String(describing: tree))
    }
    
    func test_invalidInputNoNumbers() {
        let tokens: [Token] = [.parensOpen, .number(1), ._operator("+"), .number(2)]
        var expectedError: Error? = nil
        
        do {
            var parser = Parser(tokens: tokens)
            _ = try parser.parse()
        } catch let error   {
            expectedError = error
        }
        
        if let error = expectedError,
            case ParsingError.incompleteExpression = error {
            XCTAssertTrue(true)
        } else {
            XCTFail()
        }
    }
    
    func test_invalidTokensExpectingNumber() {
        let tokens: [Token] = [.number(1), ._operator("+"), ._operator("-")]
        var expectedError: Error? = nil
        
        do {
            var parser = Parser(tokens: tokens)
            _ = try parser.parse()
        } catch let error   {
            expectedError = error
        }
        
        if let error = expectedError,
            case ParsingError.incompleteExpression = error {
            XCTAssertTrue(true)
        } else {
            XCTFail()
        }
    }
    
//    func test_invalidTokensExpectingValidOperator() {
//        let tokens: [Token] = [.number(1), .number(2)]
//        var expectedError: Error? = nil
//        
//        do {
//            var parser = Parser(tokens: tokens)
//            _ = try parser.parse()
//        } catch let error   {
//            expectedError = error
//        }
//        
//        if let error = expectedError,
//            case ParsingError.invalidTokens(expecting: "Expecting operator") = error {
//            XCTAssertTrue(true)
//        } else {
//            XCTFail()
//        }
//    }
}
