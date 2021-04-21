//
//  TabBarViewModel.swift
//  onTheMap
//
//  Created by César Ferreira on 18/04/21.
//

import Foundation
import UIKit

protocol TabBarViewModelProtocol: class {
    func didLogout()
    func getStudents(result: StudentResponse)
    func didError(message: String)
}

class TabBarViewModel {

    weak var delegate: TabBarViewModelProtocol?

    func logout() {
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
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
            print(String(data: newData!, encoding: .utf8)!)
            DispatchQueue.main.async {
                self.delegate?.didLogout()
            }
        }
        task.resume()
    }

    func getStudents(uniqueKey: String?) {
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation?order=-updatedAt?limit=100")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    self.delegate?.didError(message: error?.localizedDescription ?? "Error")
                }
                return
            }
            print(String(data: data!, encoding: .utf8)!)

            do {
                let results = try JSONDecoder().decode(StudentResponse.self, from: data!)
                DispatchQueue.main.async {
                    self.delegate?.getStudents(result: results)
                }

            } catch {
                do {
                    let results = try JSONDecoder().decode(ErrorResponse.self, from: data!)
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
