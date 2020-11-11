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
    var window: UIWindow?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var Duke_Email: UITextField!
    @IBOutlet weak var netID: UITextField!
    @IBOutlet weak var Password_stud: UITextField!
    @IBOutlet weak var Confirm_Password_Stud: UITextField!
    
    var validSignIn = false;
    var loggedInUserName = "";
    var uid = "";
    
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if !self.validSignIn  {
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destination.
        let tabBarC : UITabBarController = segue.destination as! UITabBarController
        let mapView = tabBarC.viewControllers?.first as! studentMapViewController
        let profView = tabBarC.viewControllers?.last as! studentProfileViewController
        mapView.currentUserId = self.uid
        mapView.currentUsername = self.loggedInUserName
        
        profView.currentUserId = self.uid
        profView.currentUsername = self.loggedInUserName
        
    }
    
    @IBAction func SignUp_Button_stud(_ sender: Any) {
        
        if Duke_Email.text?.isEmpty == true{
            print(" Please enter a valid Duke email.")
            showAlert(message: "Please enter a valid Duke email, ending in 'duke.edu'.")
            return
        }
        if netID.text?.isEmpty == true{
            print(" Please Insert a valid netID ")
            showAlert(message: "Please enter your NetID.")
            
            
            return
        }
        if Password_stud.text?.isEmpty == true{
            print(" Please Insert a password ")
            showAlert(message: "Please enter a password.")
            return
        }
        if Confirm_Password_Stud.text?.isEmpty == true {
            print("Please confirm password")
            showAlert(message: "Please confirm your password.")
            return
        }
        if Password_stud.text != Confirm_Password_Stud.text {
            print("Make sure passwords match")
            showAlert(message: "Your passwords do not match. Please re-enter them.")
            return
        }
        
        Auth.auth().createUser(withEmail: Duke_Email.text!, password: Password_stud.text!) { authResult, error in
                guard let user = authResult?.user, error == nil else {
                    print("Error in creating account")
                    self.showAlert(message: error!.localizedDescription)
                    return
                }
                print("\(user.email!) created")
                let db = Firestore.firestore()
                self.uid = user.uid
                self.loggedInUserName = self.netID.text!
                let email = user.email!
                db.collection("students").document(user.uid).setData([
                    "netId": self.netID.text!,
                    "email": email
                ]) { err in
                    if let err = err {
                        print("Error writing document for user: \(err)")
                        self.showAlert(message: "There seemed to be an error retrieving your login information. Please try again.")
                        return
                    } else {
                        print("Document successfully written for student!")
                        self.validSignIn = true;
                        self.performSegue(withIdentifier: "login", sender: nil)
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
    
    
    func showAlert(message:String)
    {
    let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    self.present(alert, animated: true)
    }

}
