//
//  ViewController.swift
//  Login
//
//  Created by Arturo Iván Chávez Gómez on 09/06/21.
//

import UIKit
import CLTypingLabel
import GoogleSignIn
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var welcomeMessageLabel: CLTypingLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        welcomeMessageLabel.charInterval = 0.07
        
        welcomeMessageLabel.text = "Hello and welcome to MessageApp, hope you have fun and be respectful. 😄"
        
        let defaults = UserDefaults.standard
        if let email = defaults.value(forKey: "email") as? String {
            performSegue(withIdentifier: "userLog", sender: self)
        }
        
    }
    
    @IBAction func googleButton(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.signIn()
    }

}

extension ViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil && user.authentication != nil {
            let credential = GoogleAuthProvider.credential(withIDToken: user.authentication.idToken, accessToken: user.authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { (result, error) in
                if let result = result, error == nil {
                    self.performSegue(withIdentifier: "userLog", sender: self)
                }
            }
        }
    }
}

