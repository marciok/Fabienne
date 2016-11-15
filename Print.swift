//
//  Print.swift
//  Fabienne
//
//  Created by Marcio Klepacz on 11/13/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import Foundation

@_silgen_name("printd")
public func printd(char: Int) -> Int {
    print("> \(char) <")
    
    return char
}

@_silgen_name("putchard")
public func putchard(char: Int) -> Int {
    print(Character(UnicodeScalar(char)!), terminator: "")
    
    return char
}

