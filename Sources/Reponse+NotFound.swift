//
//  Reponse+String.swift
//  Express-Swift
//
//  Created by Iwdael on 2025/1/19.
//

import Foundation
import NIOHTTP1
extension Response {
    func notFound() {
        status = HTTPResponseStatus.notFound
        send(Data())
    }
}
