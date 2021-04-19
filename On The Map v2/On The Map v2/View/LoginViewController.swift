//
//  LoginViewController.swift
//  On The Map v2
//
//  Created by César Ferreira on 19/04/21.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    private let viewModel = LoginViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
    }

    private func loading(isLoading: Bool) {
        loadingView.isHidden = !isLoading
        loadingIndicator.isHidden = !isLoading
        isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
    }

    @IBAction func loginTapped(_ sender: Any) {
        loading(isLoading: true)
        viewModel.login(username: emailTextField.text ?? "", password: passwordTextField.text ?? "")
    }

    @IBAction func singUpButtonTapped(_ sender: Any) {
        if let url = URL(string: "https://auth.udacity.com/sign-up?next=https://classroom.udacity.com") {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

extension LoginViewController: LoginViewModelProtocol {
    func didLogin() {
        loading(isLoading: false)

        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }
}

