//
//  TableViewController.swift
//  On The Map v2
//
//  Created by César Ferreira on 19/04/21.
//

import UIKit
import MapKit

class TableViewController: UIViewController {

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    private let viewModel = TabBarViewModel()

    var tableList: [Student] = []
    private var userId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        myTableView.register(MyTableViewCell.nib(), forCellReuseIdentifier: MyTableViewCell.reuseIdentifier)

        myTableView.delegate = self
        myTableView.dataSource = self
        viewModel.delegate = self

        setupNavigationBar()
        getUser()
    }

    override func viewWillAppear(_ animated: Bool) {
        getUser()
    }

    private func getUser() {
        let defaults = UserDefaults.standard
        userId = defaults.string(forKey: "userLogged") ?? ""

        getLocations()
    }

    private func getLocations() {
        loading(isLoading: true)
        viewModel.getStudents(uniqueKey: userId)
    }

    private func loading(isLoading: Bool) {
        loadingView.isHidden = !isLoading
        loadingIndicator.isHidden = !isLoading
        isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
    }

    @objc func addLocationTapped() {
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
        tableList = result.results ?? []
        myTableView.reloadData()
    }
}

extension TableViewController: UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension TableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableList.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let student = tableList[indexPath.row]

        let app = UIApplication.shared
        if let toOpen = student.mediaURL {
            app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyTableViewCell.reuseIdentifier, for: indexPath) as! MyTableViewCell
        cell.nameLabel.text = "\(String(describing: tableList[indexPath.row].firstName!)) \(String(describing: tableList[indexPath.row].lastName!))"
        return cell
    }
}

extension TableViewController: TabBarViewModelProtocol {
    func getStudents(result: StudentResponse) {
        loading(isLoading: false)
        self.setupMapWithResponse(result: result)
    }

    func didLogout() {
        self.dismiss(animated: true, completion: nil)
    }
}

