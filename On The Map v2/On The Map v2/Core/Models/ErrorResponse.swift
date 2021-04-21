//
//  ErrorResponse.swift
//  On The Map v2
//
//  Created by César Ferreira on 21/04/21.
//

import Foundation

struct ErrorResponse: Codable {

    let status: Int
    let error: String
}
