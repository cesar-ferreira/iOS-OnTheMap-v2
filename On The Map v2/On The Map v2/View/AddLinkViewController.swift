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

    private let viewModel = AddLinkViewModel()

    private var currentUser: UserInformation?
    private var userId: String = ""

    var location = String()
    let locationManager = CLLocationManager()
    var selectedPin: MKPlacemark? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self

        setupUI()
        setupLocationManager()
        searchLocation()

        getUser()
    }

    private func getUser() {
        let defaults = UserDefaults.standard
        userId = defaults.string(forKey: "userLogged") ?? ""
        viewModel.getUserById(id: userId)
    }

    private func setupUI() {
        setupButtonUI()
        setupTextFieldUI()
    }

    private func setupTextFieldUI() {
        linkTextField.textColor = .white
        linkTextField.attributedPlaceholder = NSAttributedString(string: "Enter a link to shared here",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }


    @IBAction func submitButtonTapped(_ sender: Any) {

        let submitStudent = Student(
            firstName: currentUser?.firstName,
            lastName: currentUser?.lastName,
            latitude: selectedPin?.coordinate.latitude,
            longitude: selectedPin?.coordinate.longitude,
            mapString: location, mediaURL: linkTextField.text,
            uniqueKey: userId, objectId: nil, createdAt: nil, updatedAt: nil)

        viewModel.postStudentLocation(student: submitStudent)
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    private func setupButtonUI() {
        submitButton.layer.cornerRadius = 5

    }

    private func markAnnotation(placemark: MKPlacemark) {
        selectedPin = placemark

        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }

    private func searchLocation() {

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = location
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { [self] response, _ in
            guard let response = response else {
                return
            }

            let selectedItem = response.mapItems.first?.placemark
            self.markAnnotation(placemark: selectedItem!)
        }
    }
}

extension AddLinkViewController : CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("error:: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
}

extension AddLinkViewController: AddLinkViewModelProtocol {
    func didStudentPosted() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }

    func didUser(user: UserInformation) {
        currentUser = user
    }
}
