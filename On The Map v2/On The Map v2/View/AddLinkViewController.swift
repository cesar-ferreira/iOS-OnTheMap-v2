//
//  AddLinkViewController.swift
//  On The Map v2
//
//  Created by César Ferreira on 19/04/21.
//

import UIKit
import MapKit

class AddLinkViewController: UIViewController {

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private let viewModel = AddLinkViewModel()

    private var currentUser: UserInformation?
    private var userId: String = ""

    var location = String()
    let locationManager = CLLocationManager()
    var selectedPin: MKPlacemark? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel.delegate = self

        self.setupUI()
        self.setupLocationManager()
        self.markAnnotation(placemark: self.selectedPin!)

        self.getUser()

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

    private func getUser() {
        let defaults = UserDefaults.standard
        self.userId = defaults.string(forKey: "userLogged") ?? ""
        self.viewModel.getUserById(id: self.userId)
    }

    private func setupUI() {
        self.setupButtonUI()
        self.setupTextFieldUI()
    }

    private func setupTextFieldUI() {
        self.linkTextField.textColor = .white
        self.linkTextField.attributedPlaceholder = NSAttributedString(string: "Enter a link to shared here",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }

    private func loading(isLoading: Bool) {
        self.loadingView.isHidden = !isLoading
        self.loadingIndicator.isHidden = !isLoading
        isLoading ? self.loadingIndicator.startAnimating() : self.loadingIndicator.stopAnimating()
    }

    @IBAction func submitButtonTapped(_ sender: Any) {
        self.loading(isLoading: true)

        let submitStudent = Student(
            firstName: self.currentUser?.firstName,
            lastName: self.currentUser?.lastName,
            latitude: self.selectedPin?.coordinate.latitude,
            longitude: self.selectedPin?.coordinate.longitude,
            mapString: self.location, mediaURL: self.linkTextField.text,
            uniqueKey: self.userId, objectId: nil, createdAt: nil, updatedAt: nil)

        self.viewModel.postStudentLocation(student: submitStudent)
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    private func setupButtonUI() {
        self.submitButton.layer.cornerRadius = 5

    }

    private func markAnnotation(placemark: MKPlacemark) {
        self.selectedPin = placemark

        self.mapView.removeAnnotations(self.mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        self.mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
    }
}

extension AddLinkViewController : CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("error:: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            self.locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
        }
    }

    private func setupLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()
    }
}

extension AddLinkViewController: AddLinkViewModelProtocol {
    func didError(message: String) {
        self.alertError(message: message)
    }

    func didStudentPosted() {
        self.loading(isLoading: false)

        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }

    func didUser(user: UserInformation) {
        self.currentUser = user
    }

    private func alertError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension AddLinkViewController {

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
            view.frame.origin.y -= (self.getKeyboardHeight(notification) / 3)
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
