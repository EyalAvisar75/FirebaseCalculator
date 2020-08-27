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
        guard userNameTextField.text != "" else {
            print("Please enter a user name")
            return
        }
        
        user.userName = userNameTextField.text!
        var userExists = true
        
        let  requestListenRefo = self.ref!.child("users/\(self.user.userName)")

            requestListenRefo.observe(DataEventType.value, with: { (snapshot) in

               let value = snapshot.value as? String

                if(value == nil)
                {
                    userExists = false
                }

             })
        if !userExists {
            print("user name does not exist")
            return
        }
        else {
            let calculatorVC = storyboard?.instantiateViewController(identifier: "CalculatorVC") as! CalculatorController
            
            setExerciseFromDatabase()
            calculatorVC.user = user
            present(calculatorVC, animated: true)
        }
    }
    
    @IBAction func tappedCreateUser(_ sender: Any) {
        guard newUserTextField.text != "" else {
            print("Please enter a user name")
            return
        }
        
        user.userName = newUserTextField.text!
        var userExists = false
        
        ref?.observeSingleEvent(of: .value, with: { snapshot in

                guard let dict = snapshot.value as? [String:[String:Any]] else {
                    print("No info")
                    return
                }
                Array(dict.values).forEach {
                    let currentUser = $0["userName"] as? String
                    if currentUser == self.user.userName {
                        print("user name already exists")
                        userExists = true
                        self.newUserTextField.text = ""
                        return
                    }
                }
        })
        if userExists {
            return
        }
        else {
            self.ref!.child("users").child(user.userName).setValue(["userName": user.userName])
            
            let calculatorVC = storyboard?.instantiateViewController(identifier: "CalculatorVC") as! CalculatorController
            
            calculatorVC.user = user
            present(calculatorVC, animated: true)
        }
        
    }
    
    @IBAction func tappedAnoynmousUser(_ sender: Any) {
        let calculatorVC = storyboard?.instantiateViewController(identifier: "CalculatorVC")
        present(calculatorVC!, animated: true)
    }
    
    func setExerciseFromDatabase() {
        var component = ""
        
        for key in user.exercise.variables {
            databaseHandle = ref?.child("users").child(key).observe(.value, with: { (snapshot) in
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
