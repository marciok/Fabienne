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
        let expectedTokens = [Token.parensOpen, Token.other("+"), Token.number(1), Token.number(2),  Token.parensClose]
        let tokens = Lexer.tokenize(string: "(+ 1 2)")
        XCTAssertTrue(tokens.count == expectedTokens.count)
    }
    
    func test_lexerForCorrectLongString() {
        let expectedTokens = [Token.parensOpen, Token.other("+"), Token.number(12), Token.parensClose]
        let tokens = Lexer.tokenize(string: "(+12)")
        XCTAssertTrue(tokens.count == expectedTokens.count)
    }
    
    func test_lexerForGarbage() {
        let expectedTokens = [Token.other("d"), Token.other("e"), Token.other("f")]
        let tokens = Lexer.tokenize(string: "def")
        XCTAssertTrue(tokens.count == expectedTokens.count)
    }
    
}
