//
//  UserInformation.swift
//  onTheMap
//
//  Created by César Ferreira on 18/04/21.
//

import Foundation

struct UserInformation: Codable {

    var firstName: String?
    var lastName: String?
    var nickname: String?

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case nickname
    }
}
