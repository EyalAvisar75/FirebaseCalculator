//
//  Exercise.swift
//  SwiftCalc
//
//  Created by eyal avisar on 21/08/2020.
//  Copyright © 2020 eyal avisar. All rights reserved.
//

import Foundation

struct Exercise {
    var isDot:Bool
    var numbers:[String]
    var operations:[String]
    var isOperation:Bool
    let variables = ["exerciseIsDot", "exerciseNumbers", "exerciseOperations", "exerciseIsOperations"]
    
    init() {
        isDot = false
        isOperation = false
        numbers = []
        operations = []
    }
}

struct User {
    var userName = ""
    var exercise = Exercise()
}
