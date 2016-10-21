//
//  CodeGen.swift
//  Fabienne
//
//  Created by Marcio Klepacz on 10/21/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import Foundation
import LLVM_C

enum CodeGenErrors : Error {
    case emptyAST
    case unknownFunction
    case functionAlreadyDefined
    case variableNotDeclared
    case undefinedOperator
}

struct Context {
    let context: LLVMContextRef
    let builder: LLVMBuilderRef
    var namedValues: [String : LLVMValueRef] = [:]
    let type: LLVMTypeRef?
    
    static func global() -> Context {
        return Context(
            context: LLVMGetGlobalContext(),
            builder: LLVMCreateBuilder(),
            namedValues: [:],
            type: LLVMInt32Type()
        )
    }
}

protocol ModuleProvider {
    func dump()
    var module: LLVMModuleRef { get }
    func function(name: String) -> LLVMTypeRef?
}

struct SimpleModuleProvider {
    let module: LLVMModuleRef
    
    init(name: String) {
        self.module = LLVMModuleCreateWithName(name)
    }
}

extension SimpleModuleProvider: ModuleProvider {
    
    func function(name: String) -> LLVMTypeRef? {
        return LLVMGetNamedFunction(module, name)
    }
    
    func dump() {
        LLVMDumpModule(module)
    }
}

typealias IRResult = LLVMValueRef?

protocol IRBuilder {
    func codeGenerate(context: inout Context, module: ModuleProvider) throws-> IRResult
}

extension Expression: IRBuilder {
    func codeGenerate(context: inout Context, module: ModuleProvider) throws -> IRResult {
        switch self {
        case .literalExpr(let num):
            return LLVMConstInt(context.type, UInt64(num), 0)
        case .variableExpr(let variable):
            
            if let value = context.namedValues[variable] {
                return value
            }
            
            throw CodeGenErrors.variableNotDeclared
        case .callExpr(let funName, let expr):
            guard let function = module.function(name: funName) else {
                throw CodeGenErrors.unknownFunction
            }
            
            //TODO: Handle incorrent number of parameters
            
            let argValue = try expr.codeGenerate(context: &context, module: module)
            
            let argPointer = UnsafeMutablePointer<LLVMValueRef?>.allocate(capacity: 1)
            argPointer.initialize(from: [argValue])
            
            defer { argPointer.deallocate(capacity: 1) }
            
            return LLVMBuildCall(context.builder, function, argPointer, 1, "calltmp")
            
        case .binaryExpr(let op, let lhs, let rhs):
            let lhsResult = try lhs.codeGenerate(context: &context, module: module)
            let rhsResult = try rhs.codeGenerate(context: &context, module: module)
            
            switch op {
            case "+": return LLVMBuildAdd(context.builder, lhsResult, rhsResult, "addtemp")
            case "-": return LLVMBuildSub(context.builder, lhsResult, rhsResult, "subtemp")
            case "*": return LLVMBuildMul(context.builder, lhsResult, rhsResult, "multemp")
            case "/": return LLVMBuildSDiv(context.builder, lhsResult, rhsResult, "divtemp")
            default:
                throw CodeGenErrors.undefinedOperator
            }
        }
    }
}

extension Function: IRBuilder {
    func codeGenerate(context: inout Context, module: ModuleProvider) throws -> IRResult {
        context.namedValues.removeAll()
        let function = try prototype.codeGenerate(context: &context, module: module)
        let basicBlock = LLVMAppendBasicBlockInContext(context.context, function, "entry")
        LLVMPositionBuilderAtEnd(context.builder, basicBlock)
        
        let param = LLVMGetParam(function, 0)
        if let arg = prototype.args.first {
            context.namedValues[arg.key] = param
        }
        
        let bodyCode = try body.codeGenerate(context: &context, module: module)
        
        LLVMBuildRet(context.builder, bodyCode) //Last instruction is the return
        
        //Needs verify here?
        
        context.namedValues.removeAll()
        
        return function
    }
}

extension Prototype: IRBuilder {
    func codeGenerate(context: inout Context, module: ModuleProvider) throws -> IRResult {
        
        if let _ = module.function(name: name) {
            throw CodeGenErrors.functionAlreadyDefined
        }
        
        let paramType = UnsafeMutablePointer<LLVMTypeRef?>.allocate(capacity: 1) //TODO: Replace for number of arguments
        paramType.initialize(from: [context.type])
        
        let funType = LLVMFunctionType(context.type, paramType, 1, 0)
        
        let function = LLVMAddFunction(module.module, name, funType)
        if let arg = args.first {
            let param = LLVMGetParam(function, 0)
            LLVMSetValueName(param, arg.key)
        }
        
        defer { paramType.deallocate(capacity: 1) }
        
        return function
    }
}

extension ASTNode: IRBuilder {
    func codeGenerate(context: inout Context, module: ModuleProvider) throws -> IRResult {
        switch self {
        case .functionNode(let fun):
            return try fun.codeGenerate(context: &context, module: module)
        }
    }
}

extension Collection where Iterator.Element == ASTNode {
    
    /// Note: This method is not the one implemented by `IRBuilder` this is just a workaround. I cannot implement a protocl for an array of an specific type
    func codeGenerate(context: inout Context, module: ModuleProvider) throws -> IRResult {
        guard self.count > 0 else { throw CodeGenErrors.emptyAST }
        var result: IRResult = nil
        
        for node in self {
            result = try node.codeGenerate(context: &context, module: module)
        }
        
        return result
    }
}
