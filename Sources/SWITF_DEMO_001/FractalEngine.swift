import Foundation

public enum FractalKind: Int, Codable, CaseIterable {
    case mandelbrot = 1
    case julia = 2
    case leaf = 3
    
    public init?(fromValue value: Int) {
        self.init(rawValue: value)
    }
}

public struct FractalPoint: Codable {
    public let x: Double
    public let y: Double
    public let intensity: Int
}

public struct Bounds: Codable {
    public let xMin: Double
    public let xMax: Double
    public let yMin: Double
    public let yMax: Double
}

public class FractalEngine {
    public static let canvasWidth = 800
    public static let canvasHeight = 600

    public func getFractal(kind: FractalKind, bounds: Bounds, maxIterations: Int) -> [FractalPoint] {
        switch kind {
        case .mandelbrot:
            return generateMandelbrot(bounds: bounds, maxIterations: maxIterations)
        case .julia:
            return generateJulia(bounds: bounds, maxIterations: maxIterations)
        case .leaf:
            return generateLeaf()
        }
    }

    private func encodeIntensity(iter: Int, maxIterations: Int) -> Int {
        return iter == maxIterations ? 0 : (iter * 255 / maxIterations)
    }

    public func generateMandelbrot(bounds: Bounds, maxIterations: Int) -> [FractalPoint] {
        var points = [FractalPoint]()
        let xRange = bounds.xMax - bounds.xMin
        let yRange = bounds.yMax - bounds.yMin

        for screenY in 0..<FractalEngine.canvasHeight {
            for screenX in 0..<FractalEngine.canvasWidth {
                let cRe = bounds.xMin + (Double(screenX) * xRange / Double(FractalEngine.canvasWidth))
                let cIm = bounds.yMin + (Double(screenY) * yRange / Double(FractalEngine.canvasHeight))

                var zRe = 0.0
                var zIm = 0.0
                var iter = 0

                while zRe * zRe + zIm * zIm <= 4.0 && iter < maxIterations {
                    let nextRe = zRe * zRe - zIm * zIm + cRe
                    let nextIm = 2.0 * zRe * zIm + cIm
                    zRe = nextRe
                    zIm = nextIm
                    iter += 1
                }

                points.append(FractalPoint(x: Double(screenX), y: Double(screenY), intensity: encodeIntensity(iter: iter, maxIterations: maxIterations)))
            }
        }
        return points
    }

    public func generateJulia(bounds: Bounds, maxIterations: Int) -> [FractalPoint] {
        var points = [FractalPoint]()
        let xRange = bounds.xMax - bounds.xMin
        let yRange = bounds.yMax - bounds.yMin

        let cRe = -0.400
        let cIm = 0.600

        for screenY in 0..<FractalEngine.canvasHeight {
            for screenX in 0..<FractalEngine.canvasWidth {
                var zRe = bounds.xMin + (Double(screenX) * xRange / Double(FractalEngine.canvasWidth))
                var zIm = bounds.yMin + (Double(screenY) * yRange / Double(FractalEngine.canvasHeight))
                var iter = 0

                while zRe * zRe + zIm * zIm <= 4.0 && iter < maxIterations {
                    let nextRe = zRe * zRe - zIm * zIm + cRe
                    let nextIm = 2.0 * zRe * zIm + cIm
                    zRe = nextRe
                    zIm = nextIm
                    iter += 1
                }

                points.append(FractalPoint(x: Double(screenX), y: Double(screenY), intensity: encodeIntensity(iter: iter, maxIterations: maxIterations)))
            }
        }
        return points
    }

    public func generateLeaf() -> [FractalPoint] {
        var points = [FractalPoint]()
        var pixelGrid = Array(repeating: Array(repeating: 0, count: FractalEngine.canvasHeight), count: FractalEngine.canvasWidth)

        var x = 0.0
        var y = 0.0
        let totalPoints = 150_000

        for _ in 0..<totalPoints {
            let nextX: Double
            let nextY: Double
            let r = Int.random(in: 0..<100)

            if r < 1 {
                nextX = 0.0
                nextY = 0.16 * y
            } else if r < 86 {
                nextX = 0.85 * x + 0.04 * y
                nextY = -0.04 * x + 0.85 * y + 1.6
            } else if r < 93 {
                nextX = 0.20 * x - 0.26 * y
                nextY = 0.23 * x + 0.22 * y + 1.6
            } else {
                nextX = -0.15 * x + 0.28 * y
                nextY = 0.26 * x + 0.24 * y + 0.44
            }

            x = nextX
            y = nextY

            let screenX = Int(round((x + 2.182) * Double(FractalEngine.canvasWidth - 1) / (2.655 + 2.182)))
            let screenY = Int(round((9.96 - y) * Double(FractalEngine.canvasHeight - 1) / 9.96))

            if screenX >= 0 && screenX < FractalEngine.canvasWidth && screenY >= 0 && screenY < FractalEngine.canvasHeight {
                pixelGrid[screenX][screenY] = 200
            }
        }

        for px in 0..<FractalEngine.canvasWidth {
            for py in 0..<FractalEngine.canvasHeight {
                if pixelGrid[px][py] > 0 {
                    points.append(FractalPoint(x: Double(px), y: Double(py), intensity: pixelGrid[px][py]))
                }
            }
        }

        return points
    }
}