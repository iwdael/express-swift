import Foundation
import NIO
import NIOHTTP1

public class Response {
    public var status = HTTPResponseStatus.ok
    internal var headers = HTTPHeaders()

    internal let channel: Channel
    private var isHeadSent = false
    internal var didEnd = false

    internal init(channel: Channel) {
        self.channel = channel
    }

    static func makeForUnitTests() -> Response {
        return Response(channel: EmbeddedChannel())
    }

    func sendHead() {
        guard !isHeadSent else { return }
        isHeadSent = true

        let head = HTTPResponseHead(version: .init(major: 1, minor: 1), status: status, headers: headers)
        let part = HTTPServerResponsePart.head(head)
        _ = channel.writeAndFlush(part).recover(handleError)
    }

    func handleError(_: Error) {
        end()
    }

    func end() {
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
}
