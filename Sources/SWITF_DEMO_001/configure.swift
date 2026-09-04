import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // Configure CORS
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .custom("https://apereznwo.github.io"),
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
    )
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    
    // Register CORS middleware at the very beginning of the middleware stack
    app.middleware.use(corsMiddleware, at: .beginning)

    // register routes
    try routes(app)
}