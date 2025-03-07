@testable import Express
import Testing
import Foundation

@Test func example() async throws {
    var cities: [String] = ["Belarus,Minsk"]
    let citiesLock = NSLock()
    
    let express = Express(config: .default)
    express.all { _, _ in
        print("Will be called for every request")
        // Means that other route will be able to handle request.
        return true
    }
    
    // Will be called for all requests with uri: server/city and GET.
    express.use("/city", .GET) { request, response in
        response.send("Minsk")
        return false
    }
    
    // :name is a parameter which can be accessed later from request.getParameter
    express.use("/city/:name", .POST) { request, response in
        guard let cityName: String = request.getParameter("name") else { return true }
        print("Creating city with name: \(cityName)")
        citiesLock.lock(); defer { citiesLock.unlock() }
        cities.append(cityName)
        response.send("\(cities)")
        return false
    }
    
    struct Todo: Codable {
        let title: String
        let notes: String
    }
    
    var todos: [Todo] = [Todo(title: "Release ExpressSwift", notes: "git push")]
    var todosLock = NSLock()
    
    let todoRouter = Router()
    todoRouter.all { (request, response) -> Bool in
        print("Todo router")
        return true
    }
    
    todoRouter.method(.GET) { (request, response) -> Bool in
        response.send(todos)
        return false
    }
    
    todoRouter.method(.POST) { (request, response) -> Bool in
        do {
            let todo = try request.json(Todo.self)
            todosLock.lock(); defer { todosLock.unlock() }
            todos.append(todo)
            response.status = .created
            response.send("")
        }
        catch {
            response.status = .badRequest
            response.send("Can't decode with error: \(error)")
        }
        
        return false
    }
    
    // When /todo route is found, the handling will proceed to todoRouter with /todo part substituted from route
    express.use("/todo", todoRouter)
    
    try express.listen(8080)

}
