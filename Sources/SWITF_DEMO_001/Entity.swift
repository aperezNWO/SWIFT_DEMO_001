import Foundation

public struct AccessLog: Codable {
    public let idColumn: Int64
    public let pageName: String?
    public let accessDate: String?
    public let ipValue: String?
    
    enum CodingKeys: String, CodingKey {
        case idColumn = "id_column"
        case pageName
        case accessDate
        case ipValue
    }
}

public struct PersonaTable: Codable {
    public let idColumn: Int64
    public let ciudad: String?
    public let nombreCompleto: String?
    
    enum CodingKeys: String, CodingKey {
        case idColumn = "id_column"
        case ciudad
        case nombreCompleto
    }
}