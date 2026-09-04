import Foundation

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