//
//  Parser.swift
//  Fabienne
//
//  Created by Marcio Klepacz on 10/6/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//
import Foundation

public enum ParsingError: Error {
    case invalidTokens(expecting: String)
    case incompleteExpression
}

/**
 Parse Grammar:
 
 program           : [statement | expression]*;
 
 statement         : [declaration | definition];
 
 declaration       : prefix prototype
 
 definition        : 'def' prototype expression 'end'
 
 prototype         : [identifier | 'operator' op [binary num | unary] ]'(' [identifier] ')'

 expression        : [ primaryExpression (binaryOperator primaryExpression)* ]
 
 primaryExpression : [ number | identifier | callExpression | '(' expression ')' | ifExpression | loopExpression, unaryExpression ]
 
 unaryExpression   : op primaryExpression
 
 loopExpression    : [ 'for' identifier '=' expression ',' expression ',' expression? 'in' expression  'end']
 
 ifExpression      : 'if' expression 'then' expression 'else' expression
 
 callExpression    : identifier '(' expression ')'
 
 binaryOperator    : [+-]
 
 number            : [0..9]
 
 identifer         : [aZ-0..9]
 
 */
var operatorPrecedence: [String: Int] = [
    "=": 5,
    "<": 10,
    "+": 20,
    "-": 20,
    "*": 40,
    "/": 40
]
struct Parser {
    
    var tokens: [Token]
    var index = 0
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    mutating func number() throws -> Expression {
        
        guard case let .number(num) = popCurrentToken() else {
            throw ParsingError.invalidTokens(expecting: "Expecting number")
        }
        
        return .literalExpr(num)
    }
    
    mutating func identifier() throws -> Expression {
        
        guard case let .identifier(id) = popCurrentToken() else {
            throw ParsingError.invalidTokens(expecting: "Expecting identifier")
        }
        
       return .variableExpr(id)
    }
    
    mutating func binaryOperator() throws -> String {
        
        guard case let ._operator(op) = popCurrentToken() else {
            throw ParsingError.invalidTokens(expecting: "Expecting Operator")
        }
        
        return op
    }
    
    func getCurrentTokenPrecedence() throws -> Int {
        guard index < tokens.count else {
            return -1
        }
        
        guard case let Token._operator(op) = try peekCurrentToken() else {
            return -1
        }
        
        guard let precedence = operatorPrecedence[op] else { throw ParsingError.invalidTokens(expecting: "Invalid operator") }
        
        return precedence
    }
    
    /// (binaryOperator primaryExpression)*
    mutating func binaryExpression(_ node: Expression, exprPrecedence: Int = 0) throws -> Expression {
        var lhs = node
        
        // TODO: Understand better this algorithm
        while true {
            let tokenPrecedence = try getCurrentTokenPrecedence()
            if tokenPrecedence < exprPrecedence {
                // get out when there's an expression with less precedence or if there are no more tokens
                return lhs
            }
            
            // if you are here the current token has at least the precendence as the expression
            let binOpNode = try binaryOperator()
            
            var rhs = try primaryExpression()
            let nextPrecedence = try getCurrentTokenPrecedence()
            
            if tokenPrecedence < nextPrecedence {
                rhs = try binaryExpression(rhs, exprPrecedence: tokenPrecedence + 1)
            }
            
            lhs = Expression.binaryExpr(binOpNode, lhs, rhs)
        }
    }
    
    /// primaryExpression : [ number | identifier | callExpression | callExternExpression | '(' expression ')' | ifExpression | loopExpression | unaryExpression]
    mutating func primaryExpression() throws -> Expression {
        let currentToken = try peekCurrentToken()
        
        switch currentToken {
        case .parensOpen:
            _ = popCurrentToken() // Removing '('
            let expressionNode = try expression()
            
            
            if index >= tokens.count {
                throw ParsingError.incompleteExpression
            }
            _ = popCurrentToken() // Removing ')'
            
            return expressionNode
        case .number:
            return try number()
        case .identifier:
            let iden = try identifier()
            
            if index >= tokens.count {
                return iden
            }
            
            if try peekCurrentToken() == .parensOpen  {
                
                guard case let .variableExpr(id) = iden else {
                    throw ParsingError.invalidTokens(expecting: "Expecting identifier")
                }
                return try callExpression(id)
            }
            
            return iden
        case ._if:
            return try ifExpression()
        case ._for:
            return try loopExpression()
        case .prefix:
            return try callExternExpression()
        case ._operator:
           return try unaryExpression()
        default:
            throw ParsingError.invalidTokens(expecting: "Expecting number or another expression")
        }
    }
    
    // unaryExpression : op primaryExpression
    mutating func unaryExpression() throws -> Expression {
        
        guard case let Token._operator(op) = popCurrentToken() else {
            throw ParsingError.invalidTokens(expecting: "Expecting operator")
        }
        
        let primExpression = try primaryExpression()
        
        return .unaryExpr(op, primExpression)
    }
    
    // loopExpression    : [ 'for' identifier '=' expression ',' expression ',' expression? 'in' expression 'end' ]
    mutating func loopExpression() throws -> Expression {
        _ = popCurrentToken() // Removing 'for'
        
        guard case let Token.identifier(varName) = popCurrentToken() else {
            throw ParsingError.invalidTokens(expecting: "Expecting identifier ")
        }
        
        guard Token._operator("=") == popCurrentToken() else {
            throw ParsingError.invalidTokens(expecting: "Expecting identifier: = ")
        }
        
        let startExpr = try expression()
        
        guard Token.comma == popCurrentToken() else {
            throw ParsingError.invalidTokens(expecting: "Expecting identifier: , ")
        }
        
        let endExpr = try expression()
        
        guard Token.comma == popCurrentToken() else {
            throw ParsingError.invalidTokens(expecting: "Expecting identifier: , ")
        }
        
        let stepExpr = try expression()
        
        guard Token._in == popCurrentToken() else {
            throw ParsingError.invalidTokens(expecting: "Expecting identifier: , ")
        }
        
        let bodyExpr = try expression()
        
        guard Token.end == popCurrentToken() else {
            throw ParsingError.invalidTokens(expecting: "Expecting identifier: end ")
        }
        
       return .loopExpr(varName: varName, startExpr: startExpr, endExpr: endExpr, stepExpr: stepExpr, bodyExpr: bodyExpr)
    }
    
    /// callExternExpression : prefix callExpression
    mutating func callExternExpression() throws -> Expression {
        _ = popCurrentToken() // Removing prefix (Later try to get language)
        let iden = try identifier()
        
        guard case let .variableExpr(id) = iden else {
            throw ParsingError.invalidTokens(expecting: "Expecting identifier")
        }
        
        return try callExpression(id)
    }
    
    /// expression : [primaryExpression (binaryOperator primaryExpression)* ];
    mutating func expression() throws -> Expression {
        
        let primaryExprNode = try primaryExpression()
        let binaryOpNode = try binaryExpression(primaryExprNode)

        //TODO: It's related with this test: test_invalidTokensExpectingValidOperator
//        switch binaryOpNode.value {
//        case Token.other:
            return binaryOpNode
//        default:
//            throw ParsingError.invalidTokens(expecting: "Expecting operator")
//        }
    }
    
    /// ifExpression      : if expression then expression else expression
    mutating func ifExpression() throws -> Expression {
        _ = popCurrentToken() // Removing 'if'
        let condExpression = try expression()
        
        if popCurrentToken() != .then {
            throw ParsingError.invalidTokens(expecting: "then")
        }
        
        let thenExpression = try expression()
        
        if popCurrentToken() != ._else {
            throw ParsingError.invalidTokens(expecting: "else")
        }
        
        let elseExpression = try expression()
        
        
        return .conditionalExpr(condExpr: condExpression, thenExpr: thenExpression, elseExpression: elseExpression)
    }
    
    /// callExpression    : identifier '(' expression* ')'
    mutating func callExpression(_ id: String) throws -> Expression {
        
        if try peekCurrentToken() != .parensOpen {
            throw ParsingError.invalidTokens(expecting: "Expecting: (")
        }
        
        _ = popCurrentToken() // Removing '('
        
        if try peekCurrentToken() == .parensClose {
            _ = popCurrentToken() // Removing ')'
            
            return .callExpr(id, []) // If there are no arguments
        }
        
        var expressions: [Expression] = []
        commaParseLoop: while try peekCurrentToken() != .parensClose {
            let expression = try self.expression()
            expressions.append(expression)
            
            switch try peekCurrentToken() {
            case .comma:
                _ = popCurrentToken() // Removing comma
                continue
            case .parensClose:
                _ = popCurrentToken() // Removing parensClose
                break commaParseLoop
            default:
                throw ParsingError.invalidTokens(expecting: "Expecting: , or )")
            }
        }
        
        return .callExpr(id, expressions)
    }
    
    //prototype         : [identifier | 'operator' op [binary num | unary] ]'(' [identifier] ')'
    mutating func prototype() throws -> Prototype {
        
        let funType: FunctionType
        let name: String
        
        switch try peekCurrentToken() {
        case .defOperator:
            _ = popCurrentToken() // Removing 'operator' 
            
            guard case let Token._operator(op) = popCurrentToken() else {
                throw ParsingError.invalidTokens(expecting: "expecting operator")
            }
            
            switch try peekCurrentToken() {
            case .unary:
                _ = popCurrentToken() // Remove unary
                
                name = "unary" + op
                funType = FunctionType.unary(op)
                
            case .binary:
                _ = popCurrentToken() // Remove binary
                
                name = "binary" + op
                
                guard case let Token.number(n) = popCurrentToken() else {
                    throw ParsingError.invalidTokens(expecting: "expecting number")
                }
                
                funType = FunctionType.binary(op, n)
            default:
                throw ParsingError.invalidTokens(expecting: "expecing: binary or unary")
            }
        case .identifier(let iden):
            _ = popCurrentToken() // Remove identifier
            
            funType = FunctionType.normal
            name = iden
        default:
            throw ParsingError.invalidTokens(expecting: "Expecting identifier or operator")
        }
        
        if popCurrentToken() != .parensOpen {
            throw ParsingError.invalidTokens(expecting: "Expecting: (")
        }
        
        var args: [String] = []
        
        switch try peekCurrentToken() {
        case .identifier:
            
            commaParseLoop: while case let .identifier(id) = popCurrentToken() {
                args.append(id)
                
                switch try peekCurrentToken() {
                case .comma:
                    _ = popCurrentToken() // Removing comma
                    continue
                case .parensClose:
                    _ = popCurrentToken() // Removing ')'
                    break commaParseLoop
                default:
                    throw ParsingError.invalidTokens(expecting: "Expecting: , or )")
                }
            }
            
        case .parensClose:
            _ = popCurrentToken() // Removing ')'
        default:
            throw ParsingError.invalidTokens(expecting: "Expecting identifier")
        }
        
        return Prototype(name: name, funType: funType, args: args)
    }
    
    /// definition        : def prototype expression end
    mutating func definition() throws -> Function {
        _ = popCurrentToken() // Removing 'def'
        let proto = try prototype()
        let body = try expression()
        
        if case let .binary(op, precedence) = proto.funType {
            operatorPrecedence[op] = precedence
        }
        
        if popCurrentToken() != .end {
            throw ParsingError.invalidTokens(expecting: "Expecting: end")
        }
        
        let function = Function(prototype: proto, body: body)
        
        return function
    }
    
    func peekCurrentToken() throws -> Token {
        
        if index < tokens.count {
            return tokens[index]
        }
        
        throw ParsingError.incompleteExpression
    }
    
    mutating func popCurrentToken() -> Token {
        let token = tokens[index]
        index += 1
        
        return token
    }
    
    public mutating func parse() throws -> [ASTNode] {
        var nodes = [ASTNode]()
        while index < tokens.count {
            switch try peekCurrentToken() {
            case .prefix(let name):
                _ = popCurrentToken() // Removing prefix
                
                if  name != "_ext_ " {
                    throw ParsingError.invalidTokens(expecting: "Does not know this prefix")
                }
                
                let proto = try prototype()
                
                nodes.append(ASTNode.prefixedFunctionNode(proto))
                
            case .definitionBegin:
                let def = try definition()
                
                nodes.append(ASTNode.functionNode(def))
            default:
                let expr = try expression()
                //Create lambda
                let proto = Prototype(name: "", funType: .normal, args: [])
                let lambda = Function(prototype: proto, body: expr)
                
                nodes.append(ASTNode.functionNode(lambda))
            }
        }
        
        return nodes
    }
}

