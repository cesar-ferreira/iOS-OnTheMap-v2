//
//  LoginViewModel.swift
//  onTheMap
//
//  Created by César Ferreira on 10/04/21.
//

import Foundation
import UIKit

protocol LoginViewModelProtocol: class {
    func didLogin()
    func didError(message: String)
}

class LoginViewModel {

    weak var delegate: LoginViewModelProtocol?

    func login(username: String, password: String) {

        let authentication = Authentication(username: username, password: password)
        let udacity = Udacity(udacity: authentication)

        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(udacity)
            request.httpBody = jsonData
        } catch {
            print("Error Parse")
        }

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in

            if error != nil {
                return
            }

            let range: Range = 5..<data!.count
            let newData = data?.subdata(in: range)
            do {
                let results = try JSONDecoder().decode(UserUdacity.self, from: newData!)
                UserDefaults.standard.set(results.account.key, forKey: "userLogged")
                DispatchQueue.main.async {
                    self.delegate?.didLogin()
                }

            } catch {
                do {
                    let results = try JSONDecoder().decode(ErrorResponse.self, from: newData!)
                    DispatchQueue.main.async {
                        self.delegate?.didError(message: results.error)
                    }
                } catch {
                    print("Error Parse")

                }
            }
        }
        task.resume()

    }
}
