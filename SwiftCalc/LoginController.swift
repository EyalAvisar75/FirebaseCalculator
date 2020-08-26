//
//  LoginController.swift
//  SwiftCalc
//
//  Created by eyal avisar on 26/08/2020.
//  Copyright © 2020 eyal avisar. All rights reserved.
//

import UIKit
import FirebaseDatabase


class LoginController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var newUserTextField: UITextField!
    
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?

    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
    }
    
    @IBAction func tappedLogin(_ sender: Any) {
        let calculatorVC = storyboard?.instantiateViewController(identifier: "CalculatorVC")
        present(calculatorVC!, animated: true)
    }
    
    @IBAction func tappedCreateUser(_ sender: Any) {
        if userNameTextField.text != "" {
            user.userName = userNameTextField.text!
        }
        
        ref?.child("userName").setValue(user.userName)
        let calculatorVC = storyboard?.instantiateViewController(identifier: "CalculatorVC")
        present(calculatorVC!, animated: true)
    }
    
    @IBAction func tappedAnoynmousUser(_ sender: Any) {
        let calculatorVC = storyboard?.instantiateViewController(identifier: "CalculatorVC")
        present(calculatorVC!, animated: true)
    }
    
    func setExerciseFromDatabase() {
        var component = ""
        
        for key in user.exercise.variables {
            databaseHandle = ref?.child(key).observe(.value, with: { (snapshot) in
                switch key {
                case "exerciseNumbers":
                    component = snapshot.value as! String
                    let components = component.components(separatedBy: [",", "\""])
                    for item in components {
                        self.user.exercise.numbers += [item]
                    }
                    var index = 0
                    while index < self.user.exercise.numbers.count {
                        if Double(self.user.exercise.numbers[index]) == nil {
                            self.user.exercise.numbers.remove(at: index)
                            index -= 1
                        }
                        index += 1
                    }

                case "exerciseIsOperations":
                    self.user.exercise.isOperation = snapshot.value as? Bool ?? false
                case "exerciseIsDot":
                    self.user.exercise.isDot = snapshot.value as? Bool ?? false
                case "exerciseOperations":
                    component = snapshot.value as! String
                    let components = component.components(separatedBy: [",", "\""])
                    for item in components {
                        if ["+", "-", "X", "/", "X=", "/=", "+=", "-="].contains(item) {
                            self.user.exercise.operations += [item]
                        }
                    }
                default:
                    print("retrieval failed")
                }
                
                print("component: \(component)")
                print("numbers: \(self.user.exercise.numbers) \(self.user.exercise.operations) dot \(self.user.exercise.isDot) isop \(self.user.exercise.isOperation)")
            })

        }
    }
}
