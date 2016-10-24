//
//  InterpreterTests.swift
//  Fabienne
//
//  Created by Marcio Klepacz on 10/6/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import XCTest

class InterpreterTests: XCTestCase {

    func test_ResultOfExpression() {
        let expectedResult = 3
        let binExpr = Expression.binaryExpr("+", .literalExpr(1), .literalExpr(2))
        let proto = Prototype(name: "", args: [])
        let lambda = Function(prototype: proto, body: binExpr)
        let nodes = ASTNode.functionNode(lambda)
        
        let result = try! Interpreter.eval(nodes)
        
        XCTAssertTrue(expectedResult == result)
    }
    
    func test_ResultOfExpressionMultplication() {
        let expectedResult = 6
        let binExpr = Expression.binaryExpr("*", .literalExpr(2), .literalExpr(3))
        let proto = Prototype(name: "", args: [])
        let lambda = Function(prototype: proto, body: binExpr)
        let nodes = ASTNode.functionNode(lambda)
        
        let result = try! Interpreter.eval(nodes)
        
        XCTAssertTrue(expectedResult == result)
    }
    
    func test_ResultOfExpressionDivision() {
        let expectedResult = 4
        let binExpr = Expression.binaryExpr("/", .literalExpr(8), .literalExpr(2))
        let proto = Prototype(name: "", args: [])
        let lambda = Function(prototype: proto, body: binExpr)
        let nodes = ASTNode.functionNode(lambda)
        
        let result = try! Interpreter.eval(nodes)
        
        XCTAssertTrue(expectedResult == result)
    }
    
    func test_ResultDeclaringFunction() {
        let body = Expression.binaryExpr("/", .variableExpr("x"), .literalExpr(2))
        let proto = Prototype(name: "foo", args: [("x", nil)])
        let function = Function(prototype: proto, body: body)
        let nodes = ASTNode.functionNode(function)
        
        let result = try! Interpreter.eval(nodes)
        
        XCTAssertNil(result)
    }
    
    func test_ResultDeclaringFunctionAndCalling() {
        let body = Expression.binaryExpr("/", .variableExpr("x"), .literalExpr(2))
        let proto = Prototype(name: "foo", args: [("x", nil)])
        let function = Function(prototype: proto, body: body)
        let nodes = ASTNode.functionNode(function)
        
        let callExpr = Expression.callExpr("foo", [.literalExpr(8)])
        let lambda = ASTNode.functionNode(Function(prototype: Prototype(name: "", args: []), body: callExpr))
        
        _ = try! Interpreter.eval(nodes)
        let result = try! Interpreter.eval(lambda)
        
        XCTAssertTrue(result == 4)
    }

}
