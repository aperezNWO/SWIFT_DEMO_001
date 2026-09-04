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
        let vertexX = fisherYates(count: sampleSize, seed: &seedX)
        let vertexY = fisherYates(count: sampleSize, seed: &seedY)
        
        return vertexX + vertexY
    }

    public static func generateFormattedPoints(vertexSize: Int, sampleSizeRaw: Int, sourcePoint: Int) -> String {
        let currentTimeMillis = Int64(Date().timeIntervalSince1970 * 1000)
        var seedX = currentTimeMillis
        var seedY = currentTimeMillis &* 2
        
        let sampleSize = max(sampleSizeRaw, 1)
        let vertexX = fisherYates(count: sampleSize, seed: &seedX)
        let vertexY = fisherYates(count: sampleSize, seed: &seedY)
        
        let pairs = zip(vertexX, vertexY).map { "[\($0),\($1)]" }.joined(separator: "|")
        
        // Use vertexSize dynamically instead of hardcoded 9x9 bounds
        let gridLimit = max(vertexSize, 1)
        let gridRows = (0..<gridLimit).map { row in
            let rowVals = (0..<gridLimit).map { col in 
                let index = row * gridLimit + col
                let val = index % 5 == 0 ? vertexX[safe: index] ?? 0 : 0
                return String(val)
            }
            return "{\(rowVals.joined(separator: ","))}"
        }.joined(separator: "|")
        
        let logLines = zip(vertexX, vertexY).enumerated().map { index, point -> String in
            let paddedIdx = String(format: "%02d", index)
            let modVal = max(1, sampleSize - 1)
            if index == 0 {
                return "\(paddedIdx)<[\(point.0);$point.1)]>-00-" // wait, ensure syntax is correct:
            } else {
                let weight = (point.0 + point.1) * 3 % 25
                return "\(paddedIdx)<[\(point.0);\(point.1)]>-\(weight)-[0;\(index % modVal)]≡[\(index % modVal);\(index % 5)]≡"
            }
        }
        
        // Correcting index == 0 string interpolation safely:
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
}import Foundation

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
        let vertexX = fisherYates(count: sampleSize, seed: &seedX)
        let vertexY = fisherYates(count: sampleSize, seed: &seedY)
        
        return vertexX + vertexY
    }

    public static func generateFormattedPoints(vertexSize: Int, sampleSizeRaw: Int, sourcePoint: Int) -> String {
        let currentTimeMillis = Int64(Date().timeIntervalSince1970 * 1000)
        var seedX = currentTimeMillis
        var seedY = currentTimeMillis &* 2
        
        let sampleSize = max(sampleSizeRaw, 1)
        let vertexX = fisherYates(count: sampleSize, seed: &seedX)
        let vertexY = fisherYates(count: sampleSize, seed: &seedY)
        
        let pairs = zip(vertexX, vertexY).map { "[\($0),\($1)]" }.joined(separator: "|")
        
        // Use vertexSize dynamically instead of hardcoded 9x9 bounds
        let gridLimit = max(vertexSize, 1)
        let gridRows = (0..<gridLimit).map { row in
            let rowVals = (0..<gridLimit).map { col in 
                let index = row * gridLimit + col
                let val = index % 5 == 0 ? vertexX[safe: index] ?? 0 : 0
                return String(val)
            }
            return "{\(rowVals.joined(separator: ","))}"
        }.joined(separator: "|")
        
        let logLines = zip(vertexX, vertexY).enumerated().map { index, point -> String in
            let paddedIdx = String(format: "%02d", index)
            let modVal = max(1, sampleSize - 1)
            if index == 0 {
                return "\(paddedIdx)<[\(point.0);$point.1)]>-00-" // wait, ensure syntax is correct:
            } else {
                let weight = (point.0 + point.1) * 3 % 25
                return "\(paddedIdx)<[\(point.0);\(point.1)]>-\(weight)-[0;\(index % modVal)]≡[\(index % modVal);\(index % 5)]≡"
            }
        }
        
        // Correcting index == 0 string interpolation safely:
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