//
//  AddLocationViewController.swift
//  On The Map v2
//
//  Created by César Ferreira on 19/04/21.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.dismissView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }

    private func setupUI() {
        self.setupButtonUI()
        self.setupTextFieldUI()
    }

    private func setupButtonUI() {
        self.addLocationButton.layer.cornerRadius = 5
    }
    private func setupTextFieldUI() {
        self.locationTextField.textColor = .white
        self.locationTextField.attributedPlaceholder = NSAttributedString(string: "Enter your location here",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }

    private func searchLocation() {
        self.loading(isLoading: true)
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = self.locationTextField.text ?? ""
        let search = MKLocalSearch(request: request)
        search.start { [self] response, _ in
            self.loading(isLoading: false)

            guard let response = response else {
                alertError(message: "Location not found")
                return
            }

            let selectedItem = response.mapItems.first?.placemark

            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "AddLinkViewController") as! AddLinkViewController
            newViewController.modalPresentationStyle = .fullScreen
            newViewController.selectedPin = selectedItem
            newViewController.location = locationTextField.text ?? ""
            self.present(newViewController, animated: true, completion: nil)
        }
    }

    private func loading(isLoading: Bool) {
        self.loadingView.isHidden = !isLoading
        self.loadingIndicator.isHidden = !isLoading
        isLoading ? self.loadingIndicator.startAnimating() : self.loadingIndicator.stopAnimating()
    }

    private func alertError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func findButtonTapped(_ sender: Any) {
        searchLocation()
    }
}

extension AddLocationViewController {

    private func dismissView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification:Notification) {
        if view.frame.origin.y == 0 {
            view.frame.origin.y -= self.getKeyboardHeight(notification)
        }
    }

    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }

    private func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
