//
//  Reponse+String.swift
//  Express-Swift
//
//  Created by Iwdael on 2025/1/19.
//

import Foundation

extension Response {
    func send<T : Encodable>(_ model: T) {
        if let data = try? JSONEncoder().encode(model) {
            self["Content-Type"] = "application/json;charset=utf-8"
            send(data)
        } else {
            serverError()
        }
    }
}
