//
//  studentLogInViewController.swift
//  dukeLife
//
//  Created by Abby Mapes on 10/23/20.
//

import UIKit
import Firebase
import FirebaseAuth

class studentLogInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func NetID_field(_ sender: UITextField) {
    }
    
    @IBAction func Password_field(_ sender: UITextField) {
    }
    
    @IBAction func Log_in_button(_ sender: Any) {
        if email.text?.isEmpty == true {
            print(" Please Insert a valid Duke Email")
            return
        }
        if password.text?.isEmpty == true{
            print(" Please Insert a password ")
            return
        }
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
            
        }
    }
    
    /*// MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
