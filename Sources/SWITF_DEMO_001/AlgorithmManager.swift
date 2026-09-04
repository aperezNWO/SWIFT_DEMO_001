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
        
        let sampleSize = max(sampleSizeRaw, 1)
        let gridLimit = max(vertexSize, 25) // Ensure a spacious grid so points span the full screen width/height
        
        var allCoords: [(Int, Int)] = []
        for x in 0..<gridLimit {
            for y in 0..<gridLimit {
                allCoords.append((x, y))
            }
        }
        
        // Shuffle coordinate pool using Fisher-Yates logic to guarantee unique, non-overlapping points
        var shuffledIndices = Array(0..<allCoords.count)
        for i in 0...(max(0, shuffledIndices.count - 2)) {
            let j = nextRandomInt(seed: &seedX, bound: shuffledIndices.count - i)
            let targetIndex = i + j
            if targetIndex < shuffledIndices.count {
                let tmp = shuffledIndices[i]
                shuffledIndices[i] = shuffledIndices[targetIndex]
                shuffledIndices[targetIndex] = tmp
            }
        }
        
        var vertexX: [Int] = []
        var vertexY: [Int] = []
        let actualCount = min(sampleSize, allCoords.count)
        for i in 0..<actualCount {
            let coord = allCoords[shuffledIndices[i]]
            vertexX.append(coord.0)
            vertexY.append(coord.1)
        }
        
        return vertexX + vertexY
    }

    public static func generateFormattedPoints(vertexSize: Int, sampleSizeRaw: Int, sourcePoint: Int) -> String {
        let currentTimeMillis = Int64(Date().timeIntervalSince1970 * 1000)
        var seedX = currentTimeMillis
        
        let sampleSize = max(sampleSizeRaw, 1)
        let gridLimit = max(vertexSize, 25) // Expand grid bounds to prevent clustering in a third of the screen
        
        var allCoords: [(Int, Int)] = []
        for x in 0..<gridLimit {
            for y in 0..<gridLimit {
                allCoords.append((x, y))
            }
        }
        
        var shuffledIndices = Array(0..<allCoords.count)
        for i in 0...(max(0, shuffledIndices.count - 2)) {
            let j = nextRandomInt(seed: &seedX, bound: shuffledIndices.count - i)
            let targetIndex = i + j
            if targetIndex < shuffledIndices.count {
                let tmp = shuffledIndices[i]
                shuffledIndices[i] = shuffledIndices[targetIndex]
                shuffledIndices[targetIndex] = tmp
            }
        }
        
        var vertexX: [Int] = []
        var vertexY: [Int] = []
        let actualCount = min(sampleSize, allCoords.count)
        for i in 0..<actualCount {
            let coord = allCoords[shuffledIndices[i]]
            vertexX.append(coord.0)
            vertexY.append(coord.1)
        }
        
        let pairs = zip(vertexX, vertexY).map { "[\($0),\($1)]" }.joined(separator: "|")
        
        // Populate full 2D grid without collisions or overwritten cell entries
        var grid = Array(repeating: Array(repeating: 0, count: gridLimit), count: gridLimit)
        for (index, (x, y)) in zip(vertexX, vertexY).enumerated() {
            if x >= 0 && x < gridLimit && y >= 0 && y < gridLimit {
                grid[y][x] = index + 1
            }
        }
        
        let gridRows = grid.map { rowVals in
            "{\(rowVals.map(String.init).joined(separator: ","))}"
        }.joined(separator: "|")
        
        // Guarantee fully connected link sequences across every generated point node
        let correctedLogLines = zip(vertexX, vertexY).enumerated().map { index, point -> String in
            let paddedIdx = String(format: "%02d", index)
            let weight = (point.0 + point.1) * 3 % 25
            let modVal = max(1, actualCount - 1)
            let prevIndex = index == 0 ? modVal : (index - 1) % modVal
            let nextIndex = (index + 1) % modVal
            
            return "\(paddedIdx)<[\(point.0);\(point.1)]>-\(weight)-[\(prevIndex);\(nextIndex)]≡[\(nextIndex);\(index % 5)]≡"
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