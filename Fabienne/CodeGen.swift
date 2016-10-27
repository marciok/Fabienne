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
    case numberOfArgsDoNotMatch
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
    var module: LLVMModuleRef { get }
    func dump()
    func createFunctionPassManager() -> LLVMPassManagerRef?
    func function(name: String) -> LLVMTypeRef?
}

extension ModuleProvider {
    func function(name: String) -> LLVMTypeRef? {
        return LLVMGetNamedFunction(module, name)
    }
    
    func dump() {
        LLVMDumpModule(module)
    }
    
    func createFunctionPassManager() -> LLVMPassManagerRef? {
        
        let functionPassManager = LLVMCreateFunctionPassManagerForModule(module)
        add(optimization: functionPassManager)
        
        return functionPassManager
    }
    
    func add(optimization pass: LLVMPassManagerRef?) {
        LLVMAddBasicAliasAnalysisPass(pass)
        LLVMAddInstructionCombiningPass(pass)
        LLVMAddReassociatePass(pass)
        LLVMAddGVNPass(pass)
        LLVMAddCFGSimplificationPass(pass)
        LLVMInitializeFunctionPassManager(pass)
    }
}

//TODO: Is currently not being used (only for testing)
struct SimpleModuleProvider: ModuleProvider {
    let module: LLVMModuleRef
    
    init(name: String) {
        self.module = LLVMModuleCreateWithName(name)
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
        case .conditionalExpr(condExpr: let condExpr, thenExpr: let thenExpr, elseExpression: let elseExpr):
            
            let ifCondExprCode = try condExpr.codeGenerate(context: &context, module: module)
            let zero = LLVMConstInt(context.type, UInt64(0), 0)
            
            let ifCond = LLVMBuildICmp(context.builder, LLVMIntNE, ifCondExprCode, zero, "ifcond")
            
            let block = LLVMGetInsertBlock(context.builder)
            let function = LLVMGetBasicBlockParent(block)
            let thenBlock = LLVMAppendBasicBlockInContext(context.context, function, "then")
            let elseBlock = LLVMAppendBasicBlockInContext(context.context, function, "else")
            let mergeBlock = LLVMAppendBasicBlockInContext(context.context, function, "ifcont")
            
            LLVMBuildCondBr(context.builder, ifCond, thenBlock, elseBlock)
            
            LLVMPositionBuilderAtEnd(context.builder, thenBlock)
            let thenCode = try thenExpr.codeGenerate(context: &context, module: module)
            LLVMBuildBr(context.builder, mergeBlock)
            let thenEndBlock = LLVMGetInsertBlock(context.builder)
            
            LLVMPositionBuilderAtEnd(context.builder, elseBlock)
            let elseCode = try elseExpr.codeGenerate(context: &context, module: module)
            LLVMBuildBr(context.builder, mergeBlock)
            let elseEndBlock = LLVMGetInsertBlock(context.builder)
            
            LLVMPositionBuilderAtEnd(context.builder, mergeBlock)
            
            let phi = LLVMBuildPhi(context.builder, context.type, "ifphi")
            
            let incomingValues = UnsafeMutablePointer<LLVMValueRef?>.allocate(capacity: MemoryLayout<LLVMValueRef>.stride * 2)
            incomingValues.initialize(from: [thenCode, elseCode])
            let incomingBlocks = UnsafeMutablePointer<LLVMBasicBlockRef?>.allocate(capacity: MemoryLayout<LLVMBasicBlockRef>.stride * 2)
            incomingBlocks.initialize(from: [thenEndBlock, elseEndBlock])
            
            LLVMAddIncoming(phi, incomingValues, incomingBlocks, 2)
            
            defer {
                incomingBlocks.deallocate(capacity: MemoryLayout<LLVMBasicBlockRef>.stride * 2)
                incomingValues.deallocate(capacity: MemoryLayout<LLVMBasicBlockRef>.stride * 2)
            }
        
            return phi
        case .callExpr(let funName, let exprs):
            guard let function = module.function(name: funName) else { throw CodeGenErrors.unknownFunction }
            
            if LLVMCountParams(function) != UInt32(exprs.count) { throw CodeGenErrors.numberOfArgsDoNotMatch }
            
            var argValues: [IRResult] = []
            for expr in exprs {
                let argValue = try expr.codeGenerate(context: &context, module: module)
                argValues.append(argValue)
            }
            
            let argPointer = UnsafeMutablePointer<LLVMValueRef?>.allocate(capacity: argValues.count)
            argPointer.initialize(from: argValues)
            
            defer { argPointer.deallocate(capacity: argValues.count) }
            
            return LLVMBuildCall(context.builder, function, argPointer, UInt32(argValues.count), "calltmp")
            
        case .binaryExpr(let op, let lhs, let rhs):
            let lhsResult = try lhs.codeGenerate(context: &context, module: module)
            let rhsResult = try rhs.codeGenerate(context: &context, module: module)
            
            switch op {
            case "+": return LLVMBuildAdd(context.builder, lhsResult, rhsResult, "addtemp")
            case "-": return LLVMBuildSub(context.builder, lhsResult, rhsResult, "subtemp")
            case "*": return LLVMBuildMul(context.builder, lhsResult, rhsResult, "multemp")
            case "/": return LLVMBuildSDiv(context.builder, lhsResult, rhsResult, "divtemp")
            case "<":
                let cmp = LLVMBuildICmp(context.builder, LLVMIntSLT, lhsResult, rhsResult, "cmptmp")
                //TODO: Fix this hack, convert UI -> SI directly
                let cmp2 =  LLVMBuildUIToFP(context.builder, cmp, LLVMDoubleType(), "cmptmpT")
                
                return LLVMBuildFPToSI(context.builder, cmp2, context.type, "booltmp")
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
        
        for index in 0..<prototype.args.count {
            let param = LLVMGetParam(function, UInt32(index))
            let key = prototype.args[index].0
            context.namedValues[key] = param
        }
        
        let bodyCode = try body.codeGenerate(context: &context, module: module)
        
        LLVMBuildRet(context.builder, bodyCode) //Last instruction is the return
        
        LLVMVerifyFunction(function, LLVMAbortProcessAction)
        
        LLVMRunFunctionPassManager(module.createFunctionPassManager(), function)
        
        context.namedValues.removeAll()
        
        return function
    }
}

extension Prototype: IRBuilder {
    func codeGenerate(context: inout Context, module: ModuleProvider) throws -> IRResult {
        
        if let _ = module.function(name: name) { throw CodeGenErrors.functionAlreadyDefined }
        
        let paramType = UnsafeMutablePointer<LLVMTypeRef?>.allocate(capacity: self.args.count)
        let argType = context.type
        
        paramType.initialize(from: self.args.map { _,_ in argType })
        
        let funType = LLVMFunctionType(context.type, paramType, UInt32(self.args.count), 0)
        
        let function = LLVMAddFunction(module.module, name, funType)
        
        for index in 0..<self.args.count {
            let param = LLVMGetParam(function, UInt32(index))
            LLVMSetValueName(param, self.args[index].0)
        }
        
        defer { paramType.deallocate(capacity: self.args.count) }
        
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
