//
//  LoginViewController.swift
//  On The Map
//
//  Created by Stefan Weiss on 29.03.22.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
   
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var udacityClient: UdacityAPIClientProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
   
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMapView" {
            if let navigationController = segue.destination as? UINavigationController,
                let tabController = navigationController.visibleViewController as? TabBarController {
                tabController.udacityClient = udacityClient
                tabController.parseClient = ParseAPIClient()
                tabController.loggedUser = udacityClient.user
            }
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton?) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            return
        }
        
        udacityClient.logIn(withUsername: email, password: password) { account, session, error in
            guard error == nil else {
               
                self.displayError(error!, withMessage: "The username or password provided isn't correct.")
                return
            }

            self.udacityClient.getUserInfo(usingUserIdentifier: account!.userKey) { user, error in
                

                guard error == nil else {
                    self.displayError(error!, withMessage: "Couldn't get the user details. Plase, try again later.")
                    return
                }

                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    // Re-enable views when request finishes.
                    self.performSegue(withIdentifier: "ShowMapView", sender: self)
                }
            }
        }
    
        
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        let signUp = "https://auth.udacity.com/sign-up"
        let signupURL = URL(string: signUp)!
        openLink(signupURL)
    }

}

extension UIViewController {
    
    
func displayError(_ error: APIClient.RequestError, withMessage message: String) {
    DispatchQueue.main.async {
        let alert = UIAlertController(title: "Error", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))

        var alertMessage: String?

        switch error {
        case .connection:
            alertMessage = "There's a problem with your internet connection, please, fix it and try again."
        case .response(_):
            alertMessage = message
        default:
            break
        }

        alert.message = alertMessage
        self.present(alert, animated: true)
    }
}
}
