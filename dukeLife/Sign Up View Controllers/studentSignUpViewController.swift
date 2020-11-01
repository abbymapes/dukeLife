//
//  studentSignUpViewController.swift
//  dukeLife
//
//  Created by Abby Mapes on 10/23/20.
//

import UIKit
import Firebase
import FirebaseAuth
class studentSignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Do any additional setup after loading the view.
    }


    
    @IBOutlet weak var Duke_Email: UITextField!
    @IBOutlet weak var netID: UITextField!

    @IBOutlet weak var Password_stud: UITextField!
    @IBOutlet weak var Confirm_Password_Stud: UITextField!
    
    
    @IBAction func SignUp_Button_stud(_ sender: Any) {
        
        if Duke_Email.text?.isEmpty == true{
            print(" Please Insert a valid Duke email ")
            return
        }
        
        if netID.text?.isEmpty == true{
            print(" Please Insert a valid netID ")
            return
        }
        if Password_stud.text?.isEmpty == true{
            print(" Please Insert a password ")
            return
        }
        
        if Confirm_Password_Stud.text?.isEmpty == true {
            print("Please confirm password")
            return
    }
        if Password_stud.text != Confirm_Password_Stud.text == true {
            print("Make sure passwords match")
            return
        }
    
    /*
    // MARK: - Navigation

     @IBAction func Password_field(_ sender: Any) {
     }
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
