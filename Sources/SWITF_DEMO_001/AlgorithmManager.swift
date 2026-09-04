import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

public struct AlgorithmManager {
    public static func generateRandomPoints(vertexSize: Int, sampleSizeRaw: Int, sourcePoint: Int) -> [Int] {
        let currentTimeMillis = Int64(Date().timeIntervalSince1970 * 1000)
        var seedX = currentTimeMillis
        var seedY = currentTimeMillis &* 2
        
        let sampleSize = max(sampleSizeRaw, 1)
        let limit = max(vertexSize, 1)
        
        var vertexX: [Int] = []
        var vertexY: [Int] = []
        for _ in 0..<sampleSize {
            vertexX.append(nextRandomInt(seed: &seedX, bound: limit))
            vertexY.append(nextRandomInt(seed: &seedY, bound: limit))
        }
        
        return vertexX + vertexY
    }

    public static func generateFormattedPoints(vertexSize: Int, sampleSizeRaw: Int, sourcePoint: Int) -> String {
        let currentTimeMillis = Int64(Date().timeIntervalSince1970 * 1000)
        var seedX = currentTimeMillis
        var seedY = currentTimeMillis &* 2
        
        let sampleSize = max(sampleSizeRaw, 1)
        let gridLimit = max(vertexSize, 1)
        
        var vertexX: [Int] = []
        var vertexY: [Int] = []
        for _ in 0..<sampleSize {
            vertexX.append(nextRandomInt(seed: &seedX, bound: gridLimit))
            vertexY.append(nextRandomInt(seed: &seedY, bound: gridLimit))
        }
        
        let pairs = zip(vertexX, vertexY).map { "[\($0),\($1)]" }.joined(separator: "|")
        
        // Map all generated points directly onto the grid matrix by their coordinates
        var grid = Array(repeating: Array(repeating: 0, count: gridLimit), count: gridLimit)
        for (index, (x, y)) in zip(vertexX, vertexY).enumerated() {
            if x >= 0 && x < gridLimit && y >= 0 && y < gridLimit {
                grid[y][x] = index + 1
            }
        }
        
        let gridRows = grid.map { rowVals in
            "{\(rowVals.map(String.init).joined(separator: ","))}"
        }.joined(separator: "|")
        
        let correctedLogLines = zip(vertexX, vertexY).enumerated().map { index, point -> String in
            let paddedIdx = String(format: "%02d", index)
            if index == 0 {
                return "\(paddedIdx)<[\(point.0);\(point.1)]>-00-"
            } else {
                let weight = (point.0 + point.1) * 3 % 25
                let modVal = max(1, sampleSize - 1)
                return "\(paddedIdx)<[\(point.0);\(point.1)]>-\(weight)-[0;\(index % modVal)]≡[\(index % modVal);\(index % 5)]≡"
            }
        }
        
        let logs = correctedLogLines.joined(separator: "<br/>")
        
        return "\(pairs)■\(gridRows)■\(logs)"
    }

    private static func nextRandomInt(seed: inout Int64, bound: Int) -> Int {
        seed = (seed &* 1103515245 &+ 12345) & 0x7fffffff
        guard bound > 0 else { return 0 }
        return Int(seed % Int64(bound))
    }

    private static func fisherYates(count: Int, seed: inout Int64) -> [Int] {
        var deck = Array(0..<count)
        guard count > 1 else { return deck }
        
        for i in 0...(count - 2) {
            let j = nextRandomInt(seed: &seed, bound: count - i)
            if j > 0 {
                let targetIndex = i + j
                if targetIndex < count {
                    let tmp = deck[i]
                    deck[i] = deck[targetIndex]
                    deck[targetIndex] = tmp
                }
            }
        }
        return deck
    }
}
