//
//  main.swift
//  RecursiveDescentParser
//
//  Created by Marcio Klepacz on 9/28/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import Foundation

let args = CommandLine.arguments
let option = try! DriverOption(arguments: args)

do {
    try Driver.mainLoop(option)
} catch let error {
    print("\u{001B}[0;31m Error: \(error) \u{001B}[0m")
    exit(EXIT_FAILURE)
}
