//
//  JIT.swift
//  Fabienne
//
//  Created by Marcio Klepacz on 10/25/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import Foundation
import LLVM_C

enum RuntimeErrors: Error {
   case unknown(String)
}

protocol JITter: ModuleProvider {
    func run(function: LLVMValueRef) throws -> Int
}

struct MCJIT: JITter {
    var module: LLVMModuleRef
    
    init(name: String) {
        LLVMLinkInMCJIT()
        LLVMInitializeNativeTarget()
        LLVMInitializeNativeAsmPrinter()
        
        self.module = LLVMModuleCreateWithName(name)
    }
    
    func run(function: LLVMValueRef) throws -> Int {
        let executionEngine = UnsafeMutablePointer<LLVMExecutionEngineRef?>.allocate(capacity: MemoryLayout<LLVMExecutionEngineRef>.stride)
        let error = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: MemoryLayout<UnsafeMutablePointer<Int8>>.stride)
        
        defer {
            error.deallocate(capacity: MemoryLayout<UnsafeMutablePointer<Int8>>.stride)
            executionEngine.deallocate(capacity: MemoryLayout<LLVMExecutionEngineRef>.stride)
        }
        
        if LLVMCreateExecutionEngineForModule(executionEngine, module, error) != 0 {
            throw RuntimeErrors.unknown(String(cString: error.pointee!))
        }
        
        let value = LLVMRunFunction(executionEngine.pointee, function, 0, nil)
        
        let finalResult = Int(Int64(bitPattern: LLVMGenericValueToInt(value, 1)))
        
        LLVMDeleteFunction(function)
        
        return finalResult
    }
}
