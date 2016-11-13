import Vapor
import Foundation

let drop = Droplet()
let parser = FAPLParser()


drop.get("post", ":number") { request in
    if let ID = request.parameters["number"]?.int {
        if let post = parser.post(ID: ID) {
            let postNode = post.makeNode()
            let statusNode = Node.init(["status" : Node.init("ok")])
            
            let responseNode = Node.init(arrayLiteral: postNode, statusNode)
            
            return try! JSON(node: responseNode)
        }
    }
    let responseDict = ["status" : Node.init("error"),
                        "error" : Node.init("Post not found")]
    
    return try! JSON(node: Node.init(responseDict))
}

drop.run()

