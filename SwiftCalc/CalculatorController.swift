//
//  CalculatorController.swift
//  SwiftCalc
//
//  Created by eyal avisar on 21/08/2020.
//  Copyright © 2020 eyal avisar. All rights reserved.
//git remote add origin https:
//github.com/EyalAvisar75/FirebaseCalculator.git
//git push -u origin master

import UIKit
import FirebaseDatabase

class CalculatorController: UIViewController {

    @IBOutlet weak var resultLabel: UILabel!
    
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?
    var exercise = Exercise()
    var user:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        if user != nil {
            exercise = user!.exercise
        }
    }
    
    @IBAction func touchedKey(sender:UIButton){
        
        if Int((sender.titleLabel?.text)!) == nil {
            touchedNoneNumber(sender: sender)
            return
        }
        
        if exercise.isOperation {
            resultLabel.text = ""
        }
        
        exercise.isOperation = false
        if resultLabel.text! == "0" {
            resultLabel.text! = ""
        }
        resultLabel.text! += (sender.titleLabel?.text)!
        
    }
    
    func touchedNoneNumber(sender:UIButton) {
        if sender.titleLabel?.text == "." {
            if exercise.isDot {
                return
            }
            resultLabel.text! += (sender.titleLabel?.text)!
            exercise.isDot = true
            return
        }
        exercise.isDot = false
        touchedOperation(sender: sender)
    }
    
    func touchedOperation(sender:UIButton) {
        if !exercise.isOperation {
            exercise.numbers += [resultLabel.text!]
            exercise.operations.append((sender.titleLabel?.text)!)
        }
        else {
            exercise.operations.popLast()
            exercise.operations.append((sender.titleLabel?.text)!)
        }
        exercise.isOperation = true
        calculateExpression()
//        print(exercise.numbers)
//        print(exercise.operations)
    }
    
    func calculateExpression() {
        if exercise.numbers.count > 1 {
            calculate()
        }
    }
    
    func calculate() {
        //i think it is better to work on operations and write it as
        // X, /, +, -, +=, -=, X=... etc
        if exercise.numbers.count >= 2 {
            divideOrMultiply()
        }
        if exercise.numbers.count > 2 {
            addOrSubtract()
        }
        //TODO: write to firebase
        if user != nil {
//            self.ref.child("users").child(user.uid).setValue(["username": username])
            ref?.child("users").child(user!.userName).child("exerciseIsDot").setValue(exercise.isDot)
            ref?.child("users").child(user!.userName).child("exerciseIsOperation").setValue(exercise.isOperation)
            ref?.child("users").child(user!.userName).child("exerciseNumbers").setValue(exercise.numbers)
            ref?.child("users").child(user!.userName).child("exerciseOperations").setValue(exercise.operations)
            
            ref?.child("users").child("exerciseIsOperation").setValue(exercise.isOperation)
            ref?.child("users").child("exerciseNumbers").setValue(exercise.numbers.description)
            ref?.child("users").child("exerciseOperations").setValue(exercise.operations.description)
        }
        

        resultLabel.text = exercise.numbers.last
        
//        var newExercise = Exercise()
//        var component = ""
//
//        for key in newExercise.variables {
//            databaseHandle = ref?.child(key).observe(.value, with: { (snapshot) in
//                switch key {
//                case "exerciseNumbers":
//                    component = snapshot.value as! String
//                    let components = component.components(separatedBy: [",", "\""])
//                    for item in components {
//                        newExercise.numbers += [item]
//                    }
//                    var index = 0
//                    while index < newExercise.numbers.count {
//                        if Double(newExercise.numbers[index]) == nil {
//                            newExercise.numbers.remove(at: index)
//                            index -= 1
//                        }
//                        index += 1
//                    }
//
//                case "exerciseIsOperations":
//                    newExercise.isOperation = snapshot.value as? Bool ?? false
//                case "exerciseIsDot":
//                    newExercise.isDot = snapshot.value as? Bool ?? false
//                case "exerciseOperations":
//                    component = snapshot.value as! String
//                    let components = component.components(separatedBy: [",", "\""])
//                    for item in components {
//                        if ["+", "-", "X", "/", "X=", "/=", "+=", "-="].contains(item) {
//                            newExercise.operations += [item]
//                        }
//                    }
//                default:
//                    print("retrieval failed")
//                }
//
//                print("component: \(component)")
//                print("numbers: \(newExercise.numbers) \(newExercise.operations) dot \(newExercise.isDot) isop \(newExercise.isOperation)")
//            })
//        }

    }
    
    func addOrSubtract() {
        var result:Double?

        let lastIndex = exercise.numbers.count
        
        for operation in 0..<lastIndex {
            if exercise.operations[operation] == "X" || exercise.operations[operation] == "/" {
                if exercise.numbers.count > operation {
                    divideOrMultiply(index: operation)
                }
                return
            }
        }
        
        if exercise.operations[0] == "+" {
            result = Double(exercise.numbers[0])! + Double(exercise.numbers[1])!
        }
        else {
            result = Double(exercise.numbers[0])! - Double(exercise.numbers[1])!
        }
        
        exercise.numbers.remove(at: 0)
        exercise.numbers[0] = "\(result!)"
        exercise.operations.remove(at: 0)
    }
    
    func divideOrMultiply(index:Int=0) {
        var result:Double?
        if exercise.numbers.count <= index {
            return
        }
        
        if exercise.operations[index] == "X" {
            result = Double(exercise.numbers[index])! * Double(exercise.numbers[index+1])!
        }
        else if exercise.operations[index] == "/" {
            if exercise.numbers[index+1] != "0"{
                result = Double(exercise.numbers[index])! / Double(exercise.numbers[index+1])!
            }
        }
        else {return}
        
        if let result = result {
            exercise.numbers[index] = "\(result)"
            exercise.numbers.popLast()
        }
        else {
            exercise.numbers = ["Not A Number"]
        }
        exercise.operations.remove(at: index)
    }
    
//    func setExerciseFromDatabase() {
//        var component = ""
//        
//        for key in exercise.variables {
//            databaseHandle = ref?.child(key).observe(.value, with: { (snapshot) in
//                switch key {
//                case "exerciseNumbers":
//                    component = snapshot.value as! String
//                    let components = component.components(separatedBy: [",", "\""])
//                    for item in components {
//                        self.exercise.numbers += [item]
//                    }
//                    var index = 0
//                    while index < self.exercise.numbers.count {
//                        if Double(self.exercise.numbers[index]) == nil {
//                            self.exercise.numbers.remove(at: index)
//                            index -= 1
//                        }
//                        index += 1
//                    }
//
//                case "exerciseIsOperations":
//                    self.exercise.isOperation = snapshot.value as? Bool ?? false
//                case "exerciseIsDot":
//                    self.exercise.isDot = snapshot.value as? Bool ?? false
//                case "exerciseOperations":
//                    component = snapshot.value as! String
//                    let components = component.components(separatedBy: [",", "\""])
//                    for item in components {
//                        if ["+", "-", "X", "/", "X=", "/=", "+=", "-="].contains(item) {
//                            self.exercise.operations += [item]
//                        }
//                    }
//                default:
//                    print("retrieval failed")
//                }
//                
//                print("component: \(component)")
//                print("numbers: \(self.exercise.numbers) \(self.exercise.operations) dot \(self.exercise.isDot) isop \(self.exercise.isOperation)")
//            })
//
//        }
//    }
}
