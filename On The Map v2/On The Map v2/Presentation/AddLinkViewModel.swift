//
//  AddLinkViewModel.swift
//  onTheMap
//
//  Created by César Ferreira on 18/04/21.
//

import Foundation
import UIKit

protocol AddLinkViewModelProtocol: class {
    func didUser(user: UserInformation)
    func didStudentPosted()
    func didError(message: String)
}

class AddLinkViewModel {

    weak var delegate: AddLinkViewModelProtocol?

    func getUserById(id: String) {
        let request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/users/\(id)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    self.delegate?.didError(message: error?.localizedDescription ?? "Error")
                }
                return
            }
            let range: Range = 5..<data!.count
            let newData = data?.subdata(in: range)
            do {
                let results = try JSONDecoder().decode(UserInformation.self, from: newData!)
                DispatchQueue.main.async {
                    self.delegate?.didUser(user: results)
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

    func postStudentLocation(student: Student) {
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(student)
            request.httpBody = jsonData
        } catch {
            print("Error Parse")
        }

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    self.delegate?.didError(message: error?.localizedDescription ?? "Error")
                }
                return
            }
            DispatchQueue.main.async {
                self.delegate?.didStudentPosted()
            }
        }
        task.resume()
    }
}

