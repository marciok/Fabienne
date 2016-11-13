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
    case _operator(String)
    case number(Int)
    case prefix(String)
    case identifier(String)
    case definitionBegin
    case definitionEnd
    case comma
    case _for
    case _in
    case _if
    case then
    case _else
    
    func rawValue() -> String {
        
        switch self {
        case .parensOpen:
            return "("
        case .parensClose:
            return ")"            
        case ._operator(let op):
            return op
        case .number(let num):
            return String(num)
        case .identifier(let id):
            return String(id)
        case .definitionBegin:
            return "def"
        case .definitionEnd:
            return "end"
        case ._if:
            return "if"
        case .then:
            return "then"
        case ._for:
            return "for"
        case .comma:
            return ","
        case ._in:
            return "in"
        case .prefix(let name):
            return name
        case ._else:
            return "else"
        }
    }
    
    static func == (lhs: Token, rhs: Token) -> Bool {
        return lhs.rawValue() == rhs.rawValue()
    }
    
    static func !=(lhs: Token, rhs: Token) -> Bool {
        return !(lhs == rhs)
    }
}

typealias TokenGenerator = (String) -> Token?

public struct Lexer {
    
    public static func tokenize(string input: String) -> [Token] {
        
        let tokensGenerator: [(String, TokenGenerator)] = [
            ("\\(", { _ in .parensOpen }),
            ("[ ]", { _ in nil }),
            ("[,]", { _ in .comma }),
            ("_[a-z]*_\\s", { .prefix($0) }), //TODO: will have to change once there're more then one type
            ("[a-zA-Z][a-zA-Z0-9]*", {
                switch $0 {
                case Token.definitionBegin.rawValue():
                    return .definitionBegin
                case Token.definitionEnd.rawValue():
                    return .definitionEnd
                case Token._if.rawValue():
                    return ._if
                case Token._else.rawValue():
                    return ._else
                case Token.then.rawValue():
                    return .then
                case Token._for.rawValue():
                    return ._for
                case Token._in.rawValue():
                    return ._in
                default:
                    return .identifier($0)
                }
            }),
            ("[0-9]+", { (r: String) in
                guard let n = Int(r) else { return nil }
                return .number(n)
            }),
            ("\\)", { _ in .parensClose }),
            ("\\S", { ._operator($0) })
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
                content = content.substring(from: index)
            }
        }
        
        return tokens
    }
}
