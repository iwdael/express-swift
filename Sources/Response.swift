import Foundation
import NIO
import NIOHTTP1

public class Response {
    public var status = HTTPResponseStatus.ok
    private var headers = HTTPHeaders()

    private let channel: Channel
    private var isHeadSent = false
    private var didEnd = false

    init(channel: Channel) {
        self.channel = channel
    }

    private static func makeForUnitTests() -> Response {
        return Response(channel: EmbeddedChannel())
    }

    private func sendHead() {
        guard !isHeadSent else { return }
        isHeadSent = true

        let head = HTTPResponseHead(version: .init(major: 1, minor: 1), status: status, headers: headers)
        let part = HTTPServerResponsePart.head(head)
        _ = channel.writeAndFlush(part).recover(handleError)
    }

    fileprivate func handleError(_: Error) {
        end()
    }

    fileprivate func end() {
        guard !didEnd else { return }
        didEnd = true

        let endPart = HTTPServerResponsePart.end(nil)
        _ =
            channel
            .writeAndFlush(endPart)
            .map { self.channel.close() }
    }
}

extension Response {
    public subscript(name: String) -> String? {
        set {
            assert(!isHeadSent, "Header has been sent")
            if let v = newValue {
                headers.replaceOrAdd(name: name, value: v)
            } else {
                headers.remove(name: name)
            }
        }
        get {
            return headers[name].joined(separator: ", ")
        }
    }

    public func send(_ data: Data) {
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
