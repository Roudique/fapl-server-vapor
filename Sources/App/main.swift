import Vapor
import Foundation


let drop = Droplet()
let parser = FAPLParser()
var data = NSData()

let url = URL.init(string: "https://www.example.com")
let configuration = URLSessionConfiguration.default

var session = URLSession.init(configuration: configuration)

let task = session.downloadTask(with: url!, completionHandler: { urlR, responseR, errorR in
    print("url: \(urlR), \nresponse: \(responseR), \nerror: \(errorR)")
    
    try? data = NSData.init(contentsOf: urlR!)

})
task.resume()


drop.get("zalupa") { request in
    return String.init(data: data as Data, encoding: .utf8)!
}

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

