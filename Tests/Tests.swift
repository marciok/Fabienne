//
//  Tests.swift
//  Tests
//
//  Created by Marcio Klepacz on 9/29/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import XCTest
import RecursiveDescentParser

class Tests: XCTestCase {
    
    
    func test_validInputWithParemIndie() {
        let input = "(+ (- 1 2) 4)"
        
        let r = parse(expr: Array(input.characters))
        
        XCTAssertTrue(r)
    }
    
    func test_validInputWithParem() {
        let input = "(+ 1 2)"
        
        let r = parse(expr: Array(input.characters))
        
        XCTAssertTrue(r)
    }

    
    func test_validInputWithMinus() {
        let input = "(- 1 2)"
        
        let r = parse(expr: Array(input.characters))
        
        XCTAssertTrue(r)
    }
    
    func test_invalidInput() {
        let input = "(1 + 2)"
        
        let r = parse(expr: Array(input.characters))
        
        XCTAssertFalse(r)
    }
    
    func test_invalidInputNoNumbers() {
        let input = "(+12)"
        
        let r = parse(expr: Array(input.characters))
        
        XCTAssertFalse(r)
    }
    
}
