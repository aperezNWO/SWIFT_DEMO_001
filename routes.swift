import Vapor

func routes(_ app: Application) throws {
    let fractalEngine = FractalEngine()

    // ─────────────────────────────────────────────────────────────────────────
    // PING
    // ─────────────────────────────────────────────────────────────────────────
    app.get("ping") { req async -> HTTPStatus in
        return .noContent
    }

   // ─────────────────────────────────────────────────────────────────────────
    // FRACTALS
    // ─────────────────────────────────────────────────────────────────────────
    app.get("api", "fractals", "generate") { req async throws -> [FractalPoint] in
        let kindParam = try req.query.get(Int.self, at: "kind")
        let xMin = req.query[Double.self, at: "xMin"]
        let xMax = req.query[Double.self, at: "xMax"]
        let yMin = req.query[Double.self, at: "yMin"]
        let yMax = req.query[Double.self, at: "yMax"]
        let maxIterations = req.query[Int.self, at: "maxIterations"]

        guard let fractalKind = FractalKind(fromValue: kindParam) else {
            throw Abort(.badRequest, reason: "Tipo de fractal inválido: \(kindParam)")
        }

        let defaultBounds = fractalKind == .mandelbrot
            ? Bounds(xMin: -2.0, xMax: 1.0, yMin: -1.2, yMax: 1.2)
            : Bounds(xMin: -1.5, xMax: 1.5, yMin: -1.5, yMax: 1.5)

        let bounds: Bounds
        if let xMin = xMin, let xMax = xMax, let yMin = yMin, let yMax = yMax {
            bounds = Bounds(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax)
        } else {
            bounds = defaultBounds
        }

        let iterations = maxIterations ?? 500
        return fractalEngine.getFractal(kind: fractalKind, bounds: bounds, maxIterations: iterations)
    }
    
    // ─────────────────────────────────────────────────────────────────────────
    // DIJKSTRA
    // ─────────────────────────────────────────────────────────────────────────
    app.get("GenerateRandomVertex_SpringBoot") { req async -> String in
        let vertexSize = 9
        let sampleSize = 23
        let sourcePoint = 0
        return AlgorithmManager.generateRandomPoints(vertexSize: vertexSize, sampleSizeRaw: sampleSize, sourcePoint: sourcePoint)
    }
}