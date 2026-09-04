import Vapor

func routes(_ app: Application) throws {
    let fractalEngine = FractalEngine()

    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    app.get("api", "fractals", "generate") { req async throws -> [FractalPoint] in
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

    app.get("GenerateRandomVertex_SpringBoot") { req async throws -> String in
        let vertexSize = 10
        let sampleSize = 23
        let sourcePoint = 0
        return AlgorithmManager.generateFormattedPoints(vertexSize: vertexSize, sampleSizeRaw: sampleSize, sourcePoint: sourcePoint)
    }
}