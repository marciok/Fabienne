//
//  Lexer.swift
//  Fabienne
//
//  Created by Marcio Klepacz on 10/7/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import Foundation

public enum Token {
    case parensOpen
    case parensClose
    case other(String)
    case number(Int)
}

typealias TokenGenerator = (String) -> Token?

public struct Lexer {
    
    public static func tokenize(string input: String) -> [Token] {
        
        let tokensGenerator: [(String, TokenGenerator)] = [
            ("\\(", { _ in .parensOpen }),
            ("[ ]", { _ in nil }),
            ("[0-9]+", { (r: String) in
                guard let n = Int(r) else { return nil }
                return .number(n)
            }),
            ("\\)", { _ in .parensClose })
        ]
        
        var tokens = [Token]()
        var content = input
        
        while content.characters.count > 0 {
            var matched = false
    
            for (pattern, generator) in tokensGenerator {
                if let match = content.match(regex: pattern) {
                    
                    if let token = generator(match) {
                        tokens.append(token)
                    }
                    content = content.substring(from: content.characters.index(content.startIndex, offsetBy: match.characters.count))
                    matched = true
                    break
                }
            }
            
            if !matched {
                let index = content.characters.index(content.startIndex, offsetBy: 1)
                tokens.append(.other(content.substring(to: index)))
                content = content.substring(from: index)
            }
        }
        
        return tokens
    }
}
