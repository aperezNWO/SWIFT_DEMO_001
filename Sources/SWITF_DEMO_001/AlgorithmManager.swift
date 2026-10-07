import Foundation

public struct AlgorithmManager {


    // ─────────────────────────────────────────────────────────────────────────
    // ENTRY POINT
    // ─────────────────────────────────────────────────────────────────────────
        public static func generateFormattedPoints(vertexSize: Int, sampleSizeRaw: Int, sourcePoint: Int) -> String {
            return generateRandomPoints(vertexSize: vertexSize, sampleSizeRaw: sampleSizeRaw, sourcePoint: sourcePoint)
        }

    public static func generateRandomPoints(vertexSize: Int, sampleSizeRaw: Int, sourcePoint: Int) -> String {
        let sampleSize = max(sampleSizeRaw - 2, 1)

        var graph = Array(repeating: Array(repeating: 0, count: vertexSize), count: vertexSize)

        let currentTimeMillis = Int64(Date().timeIntervalSince1970 * 1000)
        var seedX = currentTimeMillis / 2
        var seedY = currentTimeMillis * 2

        let vertexX = fisherYates(count: max(vertexSize, sampleSize), seed: &seedX)
        let vertexY = fisherYates(count: max(vertexSize, sampleSize), seed: &seedY)

        var vertexArray: [String] = []
        for index in 0..<vertexSize {
            let xVal = vertexX[safe: index] ?? (index + 1)
            let yVal = vertexY[safe: index] ?? (index + 1)
            let separator = (index < vertexSize - 1) ? "|" : ""
            vertexArray.append("[\(xVal),\(yVal)]\(separator)")
        }

        let vertexArrayString = vertexArray.joined()
        let separator2 = "■"
        let vertexMatrix = generateRandomMatrix(vertexString: vertexArray, graph: &graph, vertexSize: vertexSize)
        let vertexList = dijkstra(vertex: vertexArray, graph: graph, vertexSize: vertexSize, sampleSize: sampleSize, sourcePoint: sourcePoint)

        let sortedListEncoded = vertexList.replacingOccurrences(of: ",", with: "<br/>").replacingOccurrences(of: "\t", with: "&nbsp;")

        return "\(vertexArrayString)\(separator2)\(vertexMatrix)\(separator2)\(sortedListEncoded)"
    }

    // ─────────────────────────────────────────────────────────────────────────
    // RANDOM ADJACENCY MATRIX
    // ─────────────────────────────────────────────────────────────────────────

    public static func generateRandomMatrix(vertexString: [String], graph: inout [[Int]], vertexSize: Int) -> String {
        for index in 0..<vertexSize {
            graph[index][index] = 0
        }

        let currentTimeMillis = Int64(Date().timeIntervalSince1970 * 1000)
        var seedM = currentTimeMillis % 1000

        for indexX in 0..<vertexSize {
            for indexY in (indexX + 1)..<vertexSize {
                let randomVal = nextRandomInt(seed: &seedM, bound: 2)
                var edgeVal = 0.0
                if randomVal == 1 {
                    edgeVal = getHipotemuza(vertexString: vertexString, indexX: indexX, indexY: indexY)
                }
                let intEdge = Int(edgeVal)
                graph[indexX][indexY] = intEdge
                graph[indexY][indexX] = intEdge
            }
        }

        for indexX in 0..<vertexSize {
            var zeroCount = 0
            for indexY in 0..<vertexSize {
                if indexX != indexY && graph[indexX][indexY] == 0 {
                    zeroCount += 1
                    if zeroCount == vertexSize - 1 {
                        let hipotemuza = Int(getHipotemuza(vertexString: vertexString, indexX: indexX, indexY: indexY))
                        graph[indexX][indexY] = hipotemuza
                        graph[indexY][indexX] = hipotemuza
                    }
                }
            }
        }

        var sb = ""
        for indexX in 0..<vertexSize {
            let separator1 = (indexX < vertexSize - 1) ? "|" : ""
            let rowValues = (0..<vertexSize).map { indexY in
                "\(graph[indexX][indexY])"
            }.joined(separator: ",")
            sb.append("{\(rowValues)}\(separator1)")
        }
        return sb
    }

    // ─────────────────────────────────────────────────────────────────────────
    // EUCLIDEAN DISTANCE (hypotenuse)
    // ─────────────────────────────────────────────────────────────────────────

    private static func getHipotemuza(vertexString: [String], indexX: Int, indexY: Int) -> Double {
        guard indexY < vertexString.count, indexX < vertexString.count else { return 0.0 }
        
        let cleanedY = vertexString[indexY].replacingOccurrences(of: #"[|\[\]]"#, with: "", options: .regularExpression)
        let cleanedX = vertexString[indexX].replacingOccurrences(of: #"[|\[\]]"#, with: "", options: .regularExpression)

        let coordSource = cleanedY.components(separatedBy: ",")
        let coordDest = cleanedX.components(separatedBy: ",")

        guard coordSource.count >= 2, coordDest.count >= 2,
              let sourceX = Double(coordSource[0]),
              let sourceY = Double(coordSource[1]),
              let destX = Double(coordDest[0]),
              let destY = Double(coordDest[1]) else {
            return 0.0
        }

        return pythagorean(coordX: abs(destX - sourceX), coordY: abs(destY - sourceY))
    }

    private static func pythagorean(coordX: Double, coordY: Double) -> Double {
        return sqrt(pow(coordX, 2) + pow(coordY, 2))
    }

    // ─────────────────────────────────────────────────────────────────────────
    // FISHER-YATES SHUFFLE
    // ─────────────────────────────────────────────────────────────────────────

    public static func fisherYates(count: Int, seed: inout Int64) -> [Int] {
        var deck = Array(1...max(count, 1))
        guard count > 1 else { return deck }

        // First pass (forward)
        for i in 0...(count - 2) {
            let j = nextRandomInt(seed: &seed, bound: count - i)
            if j > 0 && (i + j) < count {
                let tmp = deck[i]
                deck[i] = deck[i + j]
                deck[i + j] = tmp
            }
        }

        // Second pass (backward)
        for i in (1..<count).reversed() {
            let j = nextRandomInt(seed: &seed, bound: i + 1)
            if j != i && j < count {
                let tmp = deck[i]
                deck[i] = deck[j]
                deck[j] = tmp
            }
        }

        return deck
    }

    // ─────────────────────────────────────────────────────────────────────────
    // DIJKSTRA RUNNER
    // ─────────────────────────────────────────────────────────────────────────

    public static func dijkstra(
        vertex: [String],
        graph: [[Int]],
        vertexSize: Int,
        sampleSize: Int,
        sourcePoint: Int
    ) -> String {
        
        let gfg = Gfg()
        gfg.dijkstra(graph: graph, src: sourcePoint, vertexSize: vertexSize)

        var sb = ""
        for index in 0..<vertexSize {
            if index < gfg.dist.count {
                if gfg.dist[index] >= Int.max {
                    gfg.dist[index] = 0
                }
            }
            
            let distVal = index < gfg.dist.count ? gfg.dist[index] : 0
            let separator = (index < vertexSize - 1) ? "," : ""
            let vertexClean = index < vertex.count ? vertex[index].replacingOccurrences(of: ",", with: ";").replacingOccurrences(of: "|", with: "") : "[0;0]"
            let pathVal = index < gfg.path.count ? gfg.path[index].replacingOccurrences(of: ",", with: ";") : ""

            let formattedString = String(format: "%02d<%@>-%02d-%@%@", index, vertexClean, distVal, pathVal, separator)
            sb.append(formattedString)
        }
        return sb
    }

    private static func nextRandomInt(seed: inout Int64, bound: Int) -> Int {
        seed = (seed &* 1103515245 &+ 12345) & 0x7fffffff
        guard bound > 0 else { return 0 }
        return Int(seed % Int64(bound))
    }

    // ─────────────────────────────────────────────────────────────────────────
    // GFG — Dijkstra core
    // ─────────────────────────────────────────────────────────────────────────

    private class Gfg {
        var dist: [Int] = []
        var path: [String] = []

        func dijkstra(graph: [[Int]], src: Int, vertexSize: Int) {
            dist = Array(repeating: Int.max, count: vertexSize)
            path = Array(repeating: "", count: vertexSize)

            var visited = Array(repeating: false, count: vertexSize)
            var previous = Array(repeating: -1, count: vertexSize)

            guard src < vertexSize else { return }
            dist[src] = 0

            for _ in 0..<vertexSize {
                var u: Int? = nil
                var minDist = Int.max

                for i in 0..<vertexSize {
                    if !visited[i] && dist[i] < minDist {
                        minDist = dist[i]
                        u = i
                    }
                }

                guard let unvisitedU = u else { break }
                visited[unvisitedU] = true

                for v in 0..<vertexSize {
                    let weight = graph[unvisitedU][v]
                    if !visited[v] && weight > 0 && dist[unvisitedU] != Int.max {
                        let newDist = dist[unvisitedU] + weight
                        if newDist < dist[v] {
                            dist[v] = newDist
                            previous[v] = unvisitedU
                        }
                    }
                }
            }

            for v in 0..<vertexSize {
                path[v] = buildPathString(previous: previous, src: src, dest: v)
            }
        }

        private func buildPathString(previous: [Int], src: Int, dest: Int) -> String {
            if dest == src { return "" }

            var steps: [Int] = []
            var cur = dest
            while cur != -1 {
                steps.append(cur)
                cur = previous[cur]
            }
            steps.reverse()

            guard let firstStep = steps.first, firstStep == src else { return "" }

            var sb = ""
            for i in 0...(steps.count - 2) {
                sb.append("[\(steps[i]);\(steps[i + 1])]≡")
            }
            return sb
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}