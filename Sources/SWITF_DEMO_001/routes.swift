import Vapor

// Structure matching the C++ EndpointInfo representation[cite: 3]
struct EndpointInfo {
    let endpointName: String
    let endpointDescription: String
}

// Dictionary mapping endpoint identifiers to their paths and descriptions[cite: 3]
let endpointDictionary: [String: EndpointInfo] = [
    "HEALTH_ENDPOINT": EndpointInfo(endpointName: "/health", endpointDescription: "Print all endpoints"),
    "PING_ENDPOINT": EndpointInfo(endpointName: "/ping", endpointDescription: "Render workaround"),
    "APP_VERSION_ENDPOINT": EndpointInfo(endpointName: "/appVersion", endpointDescription: "Get Application Version"),
    "STD_VERSION_ENDPOINT": EndpointInfo(endpointName: "/langVersion", endpointDescription: "Get Swift Language Version"),
    "SERVER_VERSION_ENDPOINT": EndpointInfo(endpointName: "/serverVersion", endpointDescription: "Get Http Server Version"),
    "FRACTAL_ENDPOINT": EndpointInfo(endpointName: "/api/fractals/generate", endpointDescription: "Fractal Generation Endpoint"),
    "DIJKSTRA_ENDPOINT": EndpointInfo(endpointName: "/GenerateRandomVertex_Swift", endpointDescription: "Generate Random Vertex via Dijkstra")
]

// Codable structs for JSON serialization in Vapor matching the C++ health response output[cite: 3]
struct EndpointDetail: Content {
    let key: String
    let path: String
    let description: String
}

struct HealthResponse: Content {
    let server: String
    let endpoints: [EndpointDetail]
}

/// Helper to convert a dictionary path string (e.g. "/api/fractals/generate") into Vapor PathComponents
private func pathComponents(for key: String) -> [PathComponent] {
    guard let info = endpointDictionary[key] else { return [] }
    return info.endpointName
        .split(separator: "/")
        .map { PathComponent(stringLiteral: String($0)) }
}

func routes(_ app: Application) throws {
    let fractalEngine = FractalEngine()

    // Ping / Zero Endpoint (Render workaround)[cite: 3, 4]
    app.get(pathComponents(for: "PING_ENDPOINT")) { req async -> Response in
        return Response(status: .noContent)
    }

    // Health Endpoint: Automatically serialized to JSON by Vapor
    app.get(pathComponents(for: "HEALTH_ENDPOINT")) { req async -> HealthResponse in
        let endpointDetails = endpointDictionary.map { key, info in
            EndpointDetail(key: key, path: info.endpointName, description: info.endpointDescription)
        }
        return HealthResponse(server: "Server Working!", endpoints: endpointDetails)
    }

    // Application version[cite: 4]
    app.get(pathComponents(for: "APP_VERSION_ENDPOINT")) { req async -> String in
        "1.0.0"
    }

    // Swift lang version[cite: 4]
    app.get(pathComponents(for: "STD_VERSION_ENDPOINT")) { req async -> String in
        #if swift(>=6.0)
        return "Swift 6.0+"
        #elseif swift(>=5.9)
        return "Swift 5.9"
        #else
        return "Swift 5.x"
        #endif
    }

    // Server version[cite: 4]
    app.get(pathComponents(for: "SERVER_VERSION_ENDPOINT")) { req async -> String in
        let version = Environment.get("SERVER_VERSION") ?? "4.x (Production)"
        return "Vapor Server v\(version)"
    }

    // Fractal Generation Endpoint[cite: 3, 4]
    app.get(pathComponents(for: "FRACTAL_ENDPOINT")) { req async throws -> [FractalPoint] in
        let kindParam = try req.query.get(Int.self, at: "kind")
        guard let fractalKind = FractalKind(fromValue: kindParam) else {
            throw Abort(.badRequest, reason: "Invalid or missing 'kind' parameter.")
        }
        
        let xMin = try req.query.get(Double.self, at: "xMin")
        let xMax = try req.query.get(Double.self, at: "xMax")
        let yMin = try req.query.get(Double.self, at: "yMin")
        let yMax = try req.query.get(Double.self, at: "yMax")
        let maxIterations = try req.query.get(Int?.self, at: "maxIterations")

        let bounds = Bounds(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax)
        let iterations = maxIterations ?? 500
        return fractalEngine.getFractal(kind: fractalKind, bounds: bounds, maxIterations: iterations)
    }

    // Dijkstra Random Vertex Endpoint[cite: 3, 4]
    app.get(pathComponents(for: "DIJKSTRA_ENDPOINT")) { req async throws -> String in
        let vertexSize = 10
        let sampleSize = 23
        let sourcePoint = 0
        return AlgorithmManager.generateFormattedPoints(vertexSize: vertexSize, sampleSizeRaw: sampleSize, sourcePoint: sourcePoint)
    }
}