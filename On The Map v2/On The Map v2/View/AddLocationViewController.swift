//
//  AddLocationViewController.swift
//  On The Map v2
//
//  Created by César Ferreira on 19/04/21.
//

import UIKit

class AddLocationViewController: UIViewController {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var addLocationButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        setupButtonUI()
        setupTextFieldUI()

    }

    private func setupButtonUI() {
        addLocationButton.layer.cornerRadius = 5
    }
    private func setupTextFieldUI() {
        locationTextField.textColor = .white
        locationTextField.attributedPlaceholder = NSAttributedString(string: "Enter your location here",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }

    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func findButtonTapped(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "AddLinkViewController") as! AddLinkViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.location = locationTextField.text ?? ""
        self.present(newViewController, animated: true, completion: nil)
    }
}

