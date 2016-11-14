//
//  LexerTests.swift
//  Fabienne
//
//  Created by Marcio Klepacz on 10/7/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import XCTest

class LexerTests: XCTestCase {

    func test_lexerForCorrectString() {
        let expectedTokens = [Token.parensOpen, Token._operator("+"), Token.number(1), Token.number(2),  Token.parensClose]
        let tokens = Lexer.tokenize(string: "(+ 1 2)")
        
        XCTAssertTrue(tokens.count == expectedTokens.count)
        for index in 0..<expectedTokens.count {
            XCTAssertTrue(tokens[index] == expectedTokens[index])
        }
    }
    
    func test_lexerForCorrectLongString() {
        let expectedTokens = [Token.parensOpen, Token._operator("+"), Token.number(12), Token.parensClose]
        let tokens = Lexer.tokenize(string: "(+12)")
        XCTAssertTrue(tokens.count == expectedTokens.count)
        for index in 0..<expectedTokens.count {
            XCTAssertTrue(tokens[index] == expectedTokens[index])
        }
    }
    
    func test_lexerForIdentifierAndNumbers() {
        let expectedTokens: [Token] = [.number(1), ._operator("+"), .identifier("x")]
        let tokens = Lexer.tokenize(string: "1+x")
        
        XCTAssertTrue(tokens.count == expectedTokens.count)
        for index in 0..<expectedTokens.count {
            XCTAssertTrue(tokens[index] == expectedTokens[index])
        }
    }
    
    func test_lexerForDefinitions() {
        let expectedTokens: [Token] = [.definitionBegin, .identifier("foo"), .parensOpen,  .identifier("x"),  .parensClose, .number(1), ._operator("+"), .identifier("x"), .end]
        let tokens = Lexer.tokenize(string: "def foo(x) 1+x end")
        
        XCTAssertTrue(tokens.count == expectedTokens.count)
        for index in 0..<expectedTokens.count {
            XCTAssertTrue(tokens[index] == expectedTokens[index])
        }
    }
    
    
}
