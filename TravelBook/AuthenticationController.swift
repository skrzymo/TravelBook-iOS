//
//  AuthenticationController.swift
//  TravelBook
//
//  Created by skrzymo on 23/01/2019.
//  Copyright © 2019 skrzymo. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

struct UserDetails {
    static var name: String!
}

class AuthenticationController: UIViewController ,FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        facebookLoginButton.delegate = self
        facebookLoginButton.readPermissions = ["public_profile", "email"]
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print("Error took place \(error.localizedDescription)")
            return
        }
        let main = UIStoryboard(name: "Main", bundle: Bundle.main)
        let authenticate = main.instantiateViewController(withIdentifier: "NavigateToList")
        
        self.present(authenticate, animated: true, completion: nil)
        print("Success")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        loadView()
        print("User signed out")
    }    
}

