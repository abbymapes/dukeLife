//
//  studentSignUpViewController.swift
//  dukeLife
//
//  Created by Abby Mapes on 10/23/20.
//

import UIKit
import Firebase
import FirebaseAuth
class studentSignUpViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var Duke_Email: UITextField!
    @IBOutlet weak var netID: UITextField!
    @IBOutlet weak var Password_stud: UITextField!
    @IBOutlet weak var Confirm_Password_Stud: UITextField!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.view.endEditing(true)
            return false
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Confirm_Password_Stud.delegate = self
        self.Password_stud.delegate = self
        self.netID.delegate = self
        self.Duke_Email.delegate = self

        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardDidShow(notification:)),
            name: UIResponder.keyboardDidShowNotification, object: nil)
            NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardDidHide(notification:)),
            name: UIResponder.keyboardDidHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
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
        if Password_stud.text != Confirm_Password_Stud.text {
            print("Make sure passwords match")
            return
        }
        
        Auth.auth().createUser(withEmail: Duke_Email.text!, password: Password_stud.text!) { authResult, error in
                guard let user = authResult?.user, error == nil else {
                    print("Error in creating account")
                    return
                }
                print("\(user.email!) created")
                let db = Firestore.firestore()
                let uid = user.uid
                let email = user.email!
                db.collection("students").document(uid).setData([
                    "netId": self.netID.text!,
                    "email": email
                ]) { err in
                    if let err = err {
                        print("Error writing document for user: \(err)")
                    } else {
                        print("Document successfully written for student!")
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
        print("keyboard did hide")
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }

}
