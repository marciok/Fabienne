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

try! Driver.mainLoop(option)
