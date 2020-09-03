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
                else {
                    print(snapshot)
                }

             })
        if !userExists {
            print("user name does not exist")
            return
        }
        else {
            setExerciseFromDatabase()//async func problem - next screen has'nt the data when asked to print
            

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
        
        ref?.child("users").child(user.userName).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let values = snapshot.value as? [String:Any]
            if let exerciseDescription = values?["description"] {
                let ed = exerciseDescription as! String
                self.loginCalculator(exerciseDescription: ed)
            }
//            var counter = 0
            
//            for (key, val) in values! {
//                switch key {
//                case "exerciseNumbers":
//                    let array = val as! NSArray as! [String]
//                    self.user.exercise.numbers = array
//                    print("self \(self.user.exercise.numbers)")
//                    counter += 1
//                    print(counter)
//                    if counter == 3 {
//                        self.loginCalculator()
//                    }
//                case "exerciseIsOperations":
//                    self.user.exercise.isOperation = val as? Bool ?? false
//                    counter += 1
//                    print(counter)
//                    if counter == 3 {
//                        self.loginCalculator()
//                    }
//                case "exerciseIsDot":
//                    self.user.exercise.isDot = val as? Bool ?? false
//                    counter += 1
//                    print(counter)
//                    if counter == 3 {
//                        self.loginCalculator()
//                    }
//                case "exerciseOperations":
//                    var array = val as! NSArray as! [String]
//                    self.user.exercise.operations = array
//                    print("self \(self.user.exercise.operations)")
//                    counter += 1
//                    print(counter)
//                    if counter == 3 {
//                        self.loginCalculator()
//                    }
//                default:
//                    print("retrieval failed")
//                }
//            }
        })
    }
    
    func loginCalculator(exerciseDescription:String) {
        let calculatorVC = storyboard?.instantiateViewController(identifier: "CalculatorVC") as! CalculatorController
        
        calculatorVC.user = self.user
        calculatorVC.exerciseDescription = exerciseDescription
        present(calculatorVC, animated: true)
    }
}

