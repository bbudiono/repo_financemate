import Foundation
import Network

/// Local HTTP server to handle OAuth callbacks for desktop apps
/// Runs temporarily on localhost:8080 to catch OAuth redirect
/// RESTORATION: This file was deleted but provides MUCH better UX than OOB flow
final class LocalOAuthServer {

    private var listener: NWListener?
    private var isRunning = false
    private var callbackHandler: ((String) -> Void)?

    /// Start the local server to listen for OAuth callbacks
    func startServer(port: UInt16 = 8080, onCallback: @escaping (String) -> Void) throws {
        guard !isRunning else { return }

        callbackHandler = onCallback

        let parameters = NWParameters.tcp
        parameters.allowLocalEndpointReuse = true

        listener = try NWListener(using: parameters, on: NWEndpoint.Port(rawValue: port)!)

        listener?.newConnectionHandler = { [weak self] connection in
            self?.handleConnection(connection)
        }

        listener?.start(queue: DispatchQueue.global())
        isRunning = true

        NSLog("🌐 Local OAuth server started on localhost:\(port)")
    }

    /// Stop the local server
    func stopServer() {
        listener?.cancel()
        listener = nil
        isRunning = false
        callbackHandler = nil
        NSLog("🛑 Local OAuth server stopped")
    }

    /// Handle incoming HTTP connections
    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: DispatchQueue.global())

        // Read the HTTP request
        connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { [weak self] data, _, isComplete, error in

            if let data = data, let request = String(data: data, encoding: .utf8) {
                self?.processHTTPRequest(request, connection: connection)
            }

            if isComplete || error != nil {
                connection.cancel()
            }
        }
    }

    /// Process the HTTP request and extract OAuth callback data
    private func processHTTPRequest(_ request: String, connection: NWConnection) {
        // Parse the HTTP request to extract the OAuth callback
        let lines = request.components(separatedBy: "\r\n")
        guard let requestLine = lines.first,
              requestLine.hasPrefix("GET") else {
            sendErrorResponse(connection)
            return
        }

        // Extract the path with query parameters
        let components = requestLine.components(separatedBy: " ")
        guard components.count >= 2 else {
            sendErrorResponse(connection)
            return
        }

        let path = components[1]

        // Check if this is an OAuth callback
        if path.hasPrefix("/callback") {
            handleOAuthCallback(path, connection: connection)
        } else {
            sendErrorResponse(connection)
        }
    }

    /// Handle the OAuth callback specifically
    private func handleOAuthCallback(_ path: String, connection: NWConnection) {
        // Extract authorization code from the path
        guard let url = URL(string: "http://localhost:8080\(path)"),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            sendErrorResponse(connection)
            return
        }

        // Send success response to the browser
        sendSuccessResponse(connection)

        // Call the callback handler with the authorization code
        DispatchQueue.main.async {
            self.callbackHandler?(code)
            self.stopServer() // Stop server after handling callback
        }
    }

    /// Send a success response to the browser
    private func sendSuccessResponse(_ connection: NWConnection) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>FinanceMate - Authentication Complete</title>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; text-align: center; margin-top: 100px; }
                .success { color: #28a745; font-size: 24px; margin-bottom: 20px; }
                .message { color: #6c757d; font-size: 16px; }
            </style>
        </head>
        <body>
            <div class="success">✅ Authentication Successful!</div>
            <div class="message">You can now close this tab and return to FinanceMate.</div>
            <div class="message">Gmail integration is now active.</div>
        </body>
        </html>
        """

        let response = """
        HTTP/1.1 200 OK\r
        Content-Type: text/html\r
        Content-Length: \(html.utf8.count)\r
        Connection: close\r
        \r
        \(html)
        """

        if let responseData = response.data(using: .utf8) {
            connection.send(content: responseData, completion: .contentProcessed { _ in
                connection.cancel()
            })
        }
    }

    /// Send an error response to the browser
    private func sendErrorResponse(_ connection: NWConnection) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>FinanceMate - Authentication Error</title>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; text-align: center; margin-top: 100px; }
                .error { color: #dc3545; font-size: 24px; margin-bottom: 20px; }
                .message { color: #6c757d; font-size: 16px; }
            </style>
        </head>
        <body>
            <div class="error">❌ Authentication Error</div>
            <div class="message">Please try again from FinanceMate.</div>
        </body>
        </html>
        """

        let response = """
        HTTP/1.1 400 Bad Request\r
        Content-Type: text/html\r
        Content-Length: \(html.utf8.count)\r
        Connection: close\r
        \r
        \(html)
        """

        if let responseData = response.data(using: .utf8) {
            connection.send(content: responseData, completion: .contentProcessed { _ in
                connection.cancel()
            })
        }
    }
}
