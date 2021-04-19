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
}

class AddLinkViewModel {

    weak var delegate: AddLinkViewModelProtocol?

    func getUserById(id: String) {
        let request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/users/\(id)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
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
                print("Error Parse")
            }

            print(String(data: newData!, encoding: .utf8)!)
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

//        request.httpBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.386052, \"longitude\": -122.083851}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            DispatchQueue.main.async {
                self.delegate?.didStudentPosted()
            }
            print(String(data: data!, encoding: .utf8)!)
        }
        task.resume()
    }
}

