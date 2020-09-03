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
            let emptyUserAlert = UIAlertController(title: "Please enter a user name", message: "", preferredStyle: .alert)
            emptyUserAlert.addAction(UIAlertAction(title: "Continue", style: .cancel))
            self.present(emptyUserAlert, animated: true)
            print("Please enter a user name")
            newUserTextField.text = ""
            return
        }
        
        user.userName = userNameTextField.text!
        
        let  requestListenRefo = self.ref!.child("users/\(self.user.userName)")

            requestListenRefo.observe(DataEventType.value, with: { (snapshot) in
                
                if(!snapshot.exists())
                {
                    let noneUserAlert = UIAlertController(title: "No Such User \(self.user.userName)", message: "", preferredStyle: .alert)
                    noneUserAlert.addAction(UIAlertAction(title: "Continue", style: .cancel))
                    self.present(noneUserAlert, animated: true)
                    self.userNameTextField.text = ""
                    self.user = User()
                }
             })

            setExerciseFromDatabase()
    }
    
    @IBAction func tappedCreateUser(_ sender: Any) {
        guard newUserTextField.text != "" else {
            let emptyUserAlert = UIAlertController(title: "Please enter a new user name", message: "", preferredStyle: .alert)
            emptyUserAlert.addAction(UIAlertAction(title: "Continue", style: .cancel))
            self.present(emptyUserAlert, animated: true)
            return
        }
        
        user.userName = newUserTextField.text!
        
        let  requestListenRefo = self.ref!.child("users/\(self.user.userName)")

        requestListenRefo.observe(DataEventType.value, with: { (snapshot) in
            
            if(snapshot.exists())
            {
                let userExistsAlert = UIAlertController(title: "User \(self.user.userName) Already Exists", message: "", preferredStyle: .alert)
                userExistsAlert.addAction(UIAlertAction(title: "Continue", style: .cancel))
                self.present(userExistsAlert, animated: true)
                self.newUserTextField.text = ""
                self.user = User()
            }
            else {
                self.ref!.child("users").child(self.user.userName).setValue(["userName": self.user.userName])
                
                let calculatorVC = self.storyboard?.instantiateViewController(identifier: "CalculatorVC") as! CalculatorController
                
                calculatorVC.user = self.user
                self.present(calculatorVC, animated: true)
            }
         })
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
            else {
                let calculatorVC = self.storyboard?.instantiateViewController(identifier: "CalculatorVC") as! CalculatorController
                
                calculatorVC.user = self.user
                self.present(calculatorVC, animated: true)
            }
        })
    }
    
    func loginCalculator(exerciseDescription:String) {
        let calculatorVC = storyboard?.instantiateViewController(identifier: "CalculatorVC") as! CalculatorController
        
        calculatorVC.user = self.user
        calculatorVC.exerciseDescription = exerciseDescription
        present(calculatorVC, animated: true)
    }
}
