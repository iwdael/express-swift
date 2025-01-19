//
//  Reponse+String.swift
//  Express-Swift
//
//  Created by Iwdael on 2025/1/19.
//

import Foundation
import NIOHTTP1
extension Response {
    func send(_ data: Data) {
        self["Content-Length"] = "\(data.count)"
        
        sendHead()
        guard !didEnd else { return }
        
        var buffer = channel.allocator.buffer(capacity: data.count)
        buffer.writeBytes(data)
        let part = HTTPServerResponsePart.body(.byteBuffer(buffer))
        
        _ = channel.writeAndFlush(part)
            .recover(handleError)
            .map { self.end() }
    }
}
