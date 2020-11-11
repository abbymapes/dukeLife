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
    func showAlert(message:String)
    {
    let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    self.present(alert, animated: true)
    }
    

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
  
        
        
        
        
    if email.text?.isEmpty == true || password.text?.isEmpty == true
        {
            print(" Please Insert a valid Duke Email")
            showAlert(message: " Please Insert email and password")
            return
        }
        else{
            Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!) { (user, error) in
                        
                        if error == nil {
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                                            self.present(vc!, animated: true, completion: nil)
                        }
                        else {
                            
                            //Tells the user that there is an error and then gets firebase to tell them the error
                                          let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                                          
                                          let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                          alertController.addAction(defaultAction)
                                          
                                          self.present(alertController, animated: true, completion: nil)
                          
                        }
        }
        
        //login()
        
    }
    
    /*// MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
        /*
    func login (){
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (user, error) in
            //if let strongSelf = self { self.showAlert(message: " Please enter correct info ")
               // return }
           // if let error = error, user == nil {
               // print(error.localizedDescription)
               // self.showAlert(message: " Please Insert a password ")
            if error == nil {
                //Print into the console if successfully logged in
                              print("You have successfully logged in")
                              
                              //Go to the HomeViewController if the login is sucessful
                              let VC = self.storyboard?.instantiateViewController(withIdentifier: "logged")
                              self.present(VC!, animated: true, completion: nil)
            }
            else{
                //Tells the user that there is an error and then gets firebase to tell them the error
                              let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                              
                              let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                              alertController.addAction(defaultAction)
                              
                              self.present(alertController, animated: true, completion: nil)
            }
            //self?.checkinfo()
        }
       
}
   */ /*
    func checkinfo(){
        if Auth.updateCurrentUser != nil {
            print(Auth.auth().currentUser?.uid)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "logged")
            vc.modalPresentationStyle = .overFullScreen
            present(vc,animated: true)
        }
    } */
    
  
}
}
