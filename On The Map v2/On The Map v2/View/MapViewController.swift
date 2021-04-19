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

        viewModel.delegate = self
        mapView.delegate = self

        setupNavigationBar()
        getUser()
    }

    override func viewWillAppear(_ animated: Bool) {
        getUser()
    }

    private func getLocations() {
        loading(isLoading: true)
        viewModel.getStudents(uniqueKey: userId)
    }

    private func getUser() {
        let defaults = UserDefaults.standard
        userId = defaults.string(forKey: "userLogged") ?? ""

        getLocations()
    }

    private func loading(isLoading: Bool) {
        loadingView.isHidden = !isLoading
        loadingIndicator.isHidden = !isLoading
        isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
    }

    @objc func addLocationTapped() {
        print("add location tapped")

        showAddLocation()
    }

    func showAddLocation() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "AddLocationViewController") as! AddLocationViewController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }

    @objc func refreshTapped() {
        getLocations()
    }

    @objc func logoutTapped() {
        viewModel.logout()
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
        mapView.removeAnnotations(mapView.annotations)
        for pin in result.results ?? [] {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude ?? 0, longitude: pin.longitude ?? 0)
            annotation.title = "\(String(describing: pin.firstName!)) \(String(describing: pin.lastName!))"
            annotation.subtitle = pin.mediaURL

            mapView.addAnnotation(annotation)
        }
    }
}

extension MapViewController: TabBarViewModelProtocol {
    func getStudents(result: StudentResponse) {
        loading(isLoading: false)
        self.setupMapWithResponse(result: result)
    }

    func didLogout() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let app = UIApplication.shared
        if let toOpen = view.annotation?.subtitle! {
            app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
        }
    }
}

