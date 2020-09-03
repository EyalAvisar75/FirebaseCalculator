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
    var exerciseDescription = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        if user != nil {
            print("received : \(exerciseDescription)")
            loadExercise()
        }
    }
    
    @IBAction func touchedKey(sender:UIButton){
        if Int((sender.titleLabel?.text)!) == nil {
            touchedNoneNumber(sender: sender)
            return
        }
        
        //The following lines allow to enter terms and operands successively
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
        print(exercise)
    }
    
    func calculateExpression() {
        if exercise.numbers.count > 1 {
            calculate()
        }
    }
    
    func calculate() {
        print("before: \(exercise)")
        if exercise.operations[0] == "="{
            exercise.operations.remove(at: 0)
            exercise.numbers.remove(at: 0)
        }
        if exercise.numbers.count >= 2 {
            divideOrMultiply()
        }
        if exercise.numbers.count > 2 {
            addOrSubtract()
        }
        if exercise.numbers.count == 2 && exercise.operations.contains("="){
            addOrSubtract()
        }
        
        //write to firebase
        if user != nil {
            ref?.child("users").child(user!.userName).child("description").setValue(exercise.description)
        }
        
        print("exercise: \(exercise)")
        resultLabel.text = exercise.numbers.last
        
    }
    
    func addOrSubtract() {
        var result:Double?
        if exercise.operations[1] == "X" || exercise.operations[1] == "/" {
            divideOrMultiply(index: 1)
            return
        }
        if exercise.operations[0] == "+" {
            result = Double(exercise.numbers[0])! + Double(exercise.numbers[1])!
        }
        else if exercise.operations[0] == "-" {
            result = Double(exercise.numbers[0])! - Double(exercise.numbers[1])!
        }
        
        if result == nil {
            return
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
    
    func loadExercise() {
        
        if exerciseDescription == "" {
            return
        }
        
        let elements = exerciseDescription.components(separatedBy:",")
        exercise.isDot = Bool(elements[0])!
        exercise.isOperation = Bool(elements[1])!
        exercise.operations = elements[2].replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").components(separatedBy: " ")
        exercise.numbers = elements[3].replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").components(separatedBy: " ")

        var index = 0

        while index < exercise.operations.count {
            if exercise.operations[index].count == 0 {
                exercise.operations.remove(at: index)
            }
            else {
                exercise.operations[index] = exercise.operations[index].replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "\\", with: "")
                
                if exercise.operations[index] == "" {
                    exercise.operations[index] = "\\"
                }
                index += 1
            }
        }
        
        index = 0
        
        while index < exercise.numbers.count {
            if exercise.numbers[index].count == 0 {
                exercise.numbers.remove(at: index)
            }
            else {
                exercise.numbers[index] = exercise.numbers[index].replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "\\", with: "")
                
                index += 1
            }
        }        
    }
}
