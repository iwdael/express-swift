//
//  Reponse+String.swift
//  Express-Swift
//
//  Created by Iwdael on 2025/1/19.
//

extension Response {
    public func send(_ string:String) {
        self["Content-Type"] = "text/plain;charset=utf-8"
        send(string.data(using: .utf8)!)
    }
}
