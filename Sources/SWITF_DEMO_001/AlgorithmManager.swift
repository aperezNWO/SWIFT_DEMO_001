import Foundation

public class AlgorithmManager {

    public static func generateRandomPoints(vertexSize: Int, sampleSizeRaw: Int, sourcePoint: Int) -> String {
        let sampleSize = sampleSizeRaw - 2
        var graph = Array(repeating: Array(repeating: 0, count: vertexSize), count: vertexSize)
        
        let currentTimeMillis = Int64(Date().timeIntervalSince1970 * 1000)
        var seedX = currentTimeMillis / 2
        var seedY = currentTimeMillis * 2
        
        let vertexX = fisherYates(count: sampleSize, seed: &seedX)
        let vertexY = fisherYates(count: sampleSize, seed: &seedY)
        
        var vertexArray = [String]()
        for index in 0..<vertexSize {
            let separator = index < vertexSize - 1 ? "|" : ""
            vertexArray.append("[\(vertexX[index]),\(vertexY[index])]\(separator)")
        }
        
        let vertexArrayString = vertexArray.joined(separator: "")
        let separator2 = "■"
        let vertexMatrix = generateRandomMatrix(vertexString: vertexArray, graph: &graph, vertexSize: vertexSize)
        let vertexList = dijkstra(vertex: vertexArray, graph: graph, vertexSize: vertexSize, sampleSize: sampleSize, sourcePoint: sourcePoint)
        
        let sortedListEncoded = vertexList.replacingOccurrences(of: ",", with: "<br/>").replacingOccurrences(of: "\t", with: "&nbsp;")
        
        return "\(vertexArrayString)\(separator2)\(vertexMatrix)\(separator2)\(sortedListEncoded)"
    }

    private static func nextRandomInt(seed: inout Int64, bound: Int) -> Int {
        seed = (seed * 1103515245 + 12345) & 0x7fffffff
        return Int(seed % Int64(bound))
    }

    public static func generateRandomMatrix(vertexString: [String], graph: inout [[Int]], vertexSize: Int) -> String {
        for index in 0..<vertexSize {
            graph[index][index] = 0
        }
        
        var seed = Int64(Date().timeIntervalSince1970 * 1000) % 1000
        
        for indexX in 0..<vertexSize {
            for indexY in (indexX + 1)..<vertexSize {
                var randomValue = Double(nextRandomInt(seed: &seed, bound: 2))
                if randomValue == 1.0 {
                    randomValue = getHipotemuza(vertexString: vertexString, indexX: indexX, indexY: indexY)
                }
                graph[indexX][indexY] = Int(randomValue)
                graph[indexY][indexX] = Int(randomValue)
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
            let separator1 = indexX < vertexSize - 1 ? "|" : ""
            let rowValues = (0..<vertexSize).map { "\(graph[indexX][$0])" }.joined(separator: ",")
            sb += "{\(rowValues)}\(separator1)"
        }
        return sb
    }

    private static func getHipotemuza(vertexString: [String], indexX: Int, indexY: Int) -> Double {
        let coordSource = vertexString[indexY].replacingOccurrences(of: "[|\\[\\]]", with: "", options: .regularExpression).split(separator: ",")
        let coordDest = vertexString[indexX].replacingOccurrences(of: "[|\\[\\]]", with: "", options: .regularExpression).split(separator: ",")
        
        let sourceX = Double(coordSource[0]) ?? 0.0
        let sourceY = Double(coordSource[1]) ?? 0.0
        let destX = Double(coordDest[0]) ?? 0.0
        let destY = Double(coordDest[1]) ?? 0.0
        
        return pythagorean(coordX: abs(destX - sourceX), coordY: abs(destY - sourceY))
    }

    private static func pythagorean(coordX: Double, coordY: Double) -> Double {
        return sqrt(pow(coordX, 2) + pow(coordY, 2))
    }

    public static func fisherYates(count: Int, seed: inout Int64) -> [Int] {
        var deck = Array(1...count)
        
        for i in 0...(count - 2) {
            let j = nextRandomInt(seed: &seed, bound: count - i)
            if j > 0 {
                let tmp = deck[i]
                deck[i] = deck[i + j]
                deck[i + j] = tmp
            }
        }
        
        for i in stride(from: count - 1, through: 1, by: -1) {
            let j = nextRandomInt(seed: &seed, bound: i + 1)
            if j != i {
                let tmp = deck[i]
                deck[i] = deck[j]
                deck[j] = tmp
            }
        }
        
        return deck
    }

    public static func dijkstra(vertex: [String], graph: [[Int]], vertexSize: Int, sampleSize: Int, sourcePoint: Int) -> String {
        let gfg = Gfg()
        gfg.dijkstra(graph: graph, src: sourcePoint, vertexSize: vertexSize)
        
        var sb = ""
        for index in 0..<gfg.dist.count {
            if gfg.dist[index] >= Int.max {
                gfg.dist[index] = 0
            }
            
            let separator = index < gfg.dist.count - 1 ? "," : ""
            let vertexClean = vertex[index].replacingOccurrences(of: ",", with: ";").replacingOccurrences(of: "|", with: "")
            let pathClean = gfg.path[index].replacingOccurrences(of: ",", with: ";")
            let distFormatted = String(format: "%02d", gfg.dist[index])
            let indexFormatted = String(format: "%02d", index)
            
            sb += "\(indexFormatted)<\(vertexClean)>-\(distFormatted)-\(pathClean)\(separator)"
        }
        return sb
    }

    private class Gfg {
        var dist = [Int]()
        var path = [String]()

        func dijkstra(graph: [[Int]], src: Int, vertexSize: Int) {
            dist = Array(repeating: Int.max, count: vertexSize)
            path = Array(repeating: "", count: vertexSize)
            
            var visited = Array(repeating: false, count: vertexSize)
            var previous = Array(repeating: -1, count: vertexSize)
            
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
                
                guard let unwrappedU = u else { break }
                visited[unwrappedU] = true
                
                for v in 0..<vertexSize {
                    let weight = graph[unwrappedU][v]
                    if !visited[v] && weight > 0 && dist[unwrappedU] != Int.max {
                        let newDist = dist[unwrappedU] + weight
                        if newDist < dist[v] {
                            dist[v] = newDist
                            previous[v] = unwrappedU
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
            
            var steps = [Int]()
            var cur = dest
            while cur != -1 {
                steps.append(cur)
                cur = previous[cur]
            }
            steps.reverse()
            
            if steps.first != src { return "" }
            
            var sb = ""
            for i in 0..<(steps.count - 1) {
                sb += "[\(steps[i]);\(steps[i+1])]≡"
            }
            return sb
        }
    }
}