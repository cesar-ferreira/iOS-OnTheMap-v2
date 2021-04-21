//
//  MapViewController.swift
//  On The Map v2
//
//  Created by César Ferreira on 19/04/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    private let viewModel = TabBarViewModel()
    private var userId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel.delegate = self
        self.mapView.delegate = self

        self.setupNavigationBar()
        self.getUser()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getUser()
    }

    private func getLocations() {
        self.loading(isLoading: true)
        self.viewModel.getStudents(uniqueKey: self.userId)
    }

    private func getUser() {
        let defaults = UserDefaults.standard
        self.userId = defaults.string(forKey: "userLogged") ?? ""

        self.getLocations()
    }

    private func loading(isLoading: Bool) {
        self.loadingView.isHidden = !isLoading
        self.loadingIndicator.isHidden = !isLoading
        isLoading ? self.loadingIndicator.startAnimating() : self.loadingIndicator.stopAnimating()
    }

    @objc func addLocationTapped() {
        print("add location tapped")

        self.showAddLocation()
    }

    func showAddLocation() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "AddLocationViewController") as! AddLocationViewController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }

    @objc func refreshTapped() {
        self.getLocations()
    }

    @objc func logoutTapped() {
        self.viewModel.logout()
    }

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutTapped))
        let logout = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(logoutTapped))
        navigationItem.rightBarButtonItems = [logout]

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "add", style: .plain, target: self, action: #selector(addLocationTapped))
        let addLocation = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addLocationTapped))

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "reload", style: .plain, target: self, action: #selector(refreshTapped))
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTapped))

        navigationItem.rightBarButtonItems = [addLocation, refresh]
    }

    private func setupMapWithResponse(result: StudentResponse) {
        self.mapView.removeAnnotations(self.mapView.annotations)
        for pin in result.results ?? [] {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude ?? 0, longitude: pin.longitude ?? 0)
            annotation.title = "\(String(describing: pin.firstName!)) \(String(describing: pin.lastName!))"
            annotation.subtitle = pin.mediaURL

            self.mapView.addAnnotation(annotation)
        }
    }
}

extension MapViewController: TabBarViewModelProtocol {
    func getStudents(result: StudentResponse) {
        self.loading(isLoading: false)
        self.setupMapWithResponse(result: result)
    }

    func didLogout() {
        self.dismiss(animated: true, completion: nil)
    }

    func didError(message: String) {
        self.loading(isLoading: false)
        self.alertError(message: message)
    }

    private func alertError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        let app = UIApplication.shared
        if let toOpen = view.annotation?.subtitle! {
            app.canOpenURL(URL(string: toOpen)!)
                ? app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
                : self.alertError(message: "User has no associated link")
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let identifier = "Placemark"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
}

