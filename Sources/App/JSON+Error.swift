//
//  JSON+Error.swift
//  fapl-server
//
//  Created by Roudique on 11/27/16.
//
//

import JSON

extension JSON {
    static func error(withMessage message: String, code: Int = -1) -> JSON {
        return try! JSON(node: [
            "status" : "error",
            "error" : message,
            "code" : code])
    }
}
