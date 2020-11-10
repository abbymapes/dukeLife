//
//  navigationViewController.swift
//  dukeLife
//
//  Created by Isabella Geraci on 11/9/20.
//

import UIKit

class navigationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let myViewController = self.storyboard?.instantiateViewController(withIdentifier: "studentImageCollectionViewController") as? studentImageCollectionViewController{
            self.navigationController?.pushViewController(myViewController, animated: true)
            }
        

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
