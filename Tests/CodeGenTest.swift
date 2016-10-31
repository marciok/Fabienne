//
//  CodeGenTest.swift
//  Fabienne
//
//  Created by Marcio Klepacz on 10/21/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import XCTest
import LLVM_C

class CodeGenTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSimpleExpression() {
        let binExpr = Expression.binaryExpr("+", .literalExpr(1), .literalExpr(2))
        let proto = Prototype(name: "", args: [])
        let lambda = Function(prototype: proto, body: binExpr)
        let ast = ASTNode.functionNode(lambda)
        var ctx = Context.global()
        let mod = SimpleModuleProvider(name: "Fabienne")
        let expected = "; ModuleID = \'Fabienne\'source_filename = \"Fabienne\"define i32 @0() {entry:  ret i32 3}"
        
        _ = try! ast.codeGenerate(context: &ctx, module: mod)
        
        let output = String(cString: LLVMPrintModuleToString(mod.module)).replacingOccurrences(of: "\n", with: "", options: [])
        
       XCTAssertTrue(expected == output)
    }
    
    func testDefinition() {
        let proto = Prototype(name: "foo", args: ["x"])
        let body = Expression.binaryExpr("+", .literalExpr(1), .variableExpr("x"))
        let definition = Function(prototype: proto, body: body)
        let ast = ASTNode.functionNode(definition)
        
        var ctx = Context.global()
        let mod = SimpleModuleProvider(name: "Fabienne")
        let expected = "; ModuleID = \'Fabienne\'source_filename = \"Fabienne\"define i32 @foo(i32 %x) {entry:  %addtemp = add i32 %x, 1  ret i32 %addtemp}"
        
        _ = try! ast.codeGenerate(context: &ctx, module: mod)
        
        let output = String(cString: LLVMPrintModuleToString(mod.module)).replacingOccurrences(of: "\n", with: "", options: [])
        
        XCTAssertTrue(expected == output)
    }
    
    func testDefinitionCall() {
        let proto = Prototype(name: "foo", args: ["x"])
        let body = Expression.binaryExpr("+", .literalExpr(1), .variableExpr("x"))
        let definition = Function(prototype: proto, body: body)
        
        let protoLambda = Prototype(name: "", args: ["x"])
        let callExpr = Expression.callExpr("foo", [.binaryExpr("+", .literalExpr(1), .literalExpr(1))])
        let lambda = Function(prototype: protoLambda, body: callExpr)

        let ast = [ASTNode.functionNode(definition), ASTNode.functionNode(lambda)]
        
        var ctx = Context.global()
        let mod = SimpleModuleProvider(name: "Fabienne")
        let expected = "; ModuleID = \'Fabienne\'source_filename = \"Fabienne\"define i32 @foo(i32 %x) {entry:  %addtemp = add i32 %x, 1  ret i32 %addtemp}define i32 @0(i32 %x) {entry:  %calltmp = call i32 @foo(i32 2)  ret i32 %calltmp}"
        
        _ = try! ast.codeGenerate(context: &ctx, module: mod)
        
        let output = String(cString: LLVMPrintModuleToString(mod.module)).replacingOccurrences(of: "\n", with: "", options: [])
        
        XCTAssertTrue(expected == output)
    }

}
