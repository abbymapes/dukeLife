//
//  guestSignUpViewController.swift
//  dukeLife
//
//  Created by Abby Mapes on 10/23/20.
//

import UIKit
import Firebase
import FirebaseAuth

class guestSignUpViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var Password_guest: UITextField!
    @IBOutlet weak var Confirm_Password_guest: UITextField!

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.view.endEditing(true)
            return false
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Confirm_Password_guest.delegate = self
        self.Password_guest.delegate = self
        self.firstName.delegate = self
        self.lastName.delegate = self
        self.email.delegate = self
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardDidShow(notification:)),
            name: UIResponder.keyboardDidShowNotification, object: nil)
            NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardDidHide(notification:)),
            name: UIResponder.keyboardDidHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func SignUp_Button_guest(_ sender: Any) {
        if email.text?.isEmpty == true{
            print(" Please Insert a valid email ")
            showAlert(message: " Please Insert a valid email ")
            return
        }
        if firstName.text?.isEmpty == true{
            print(" Please Insert a valid first name")
            showAlert(message: " Please enter your first name ")
            return
        }
        if lastName.text?.isEmpty == true{
            print(" Please enter your last name ")
            return
        }
        if Password_guest.text?.isEmpty == true{
            print(" Please Insert a password ")
            showAlert(message: " Please Insert a password ")
            return
        }
        if Confirm_Password_guest.text?.isEmpty == true {
            print("Please confirm password")
            showAlert(message: " Please confirm password ")
            return
        }
        if Password_guest.text != Confirm_Password_guest.text {
            print("Make sure passwords match")
            showAlert(message: " Passwords do not Match ")
            return
        }
        
        Auth.auth().createUser(withEmail: email.text!, password: Password_guest.text!) { authResult, error in
                guard let user = authResult?.user, error == nil else {
                    print("Error in creating account")
                    self.showAlert(message: " Error in creating account ")
                    return
                }
                print("\(user.email!) created")
                let db = Firestore.firestore()
                let uid = user.uid
                let email = user.email!
                db.collection("guests").document(uid).setData([
                    "name": self.firstName.text! + " " + self.lastName.text!,
                    "email": email
                ]) { err in
                    if let err = err {
                        print("Error writing document for guest user: \(err)")
                    } else {
                        print("Document successfully written for guest!")
                    }
                }
            }
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
    
    // Ignore this, but keep it. It adjusts scroll when keyboard shows
    //MARK: Methods to manage keybaord
    @objc func keyboardDidShow(notification: NSNotification) {
        let info = notification.userInfo
        let keyBoardSize = info![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyBoardSize.height, right: 0.0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyBoardSize.height, right: 0.0)
    }

    @objc func keyboardDidHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    
    
    func showAlert(message:String)
    {
    let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    self.present(alert, animated: true)
    }

}
