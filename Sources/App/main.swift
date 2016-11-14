import Vapor
import Foundation
import SMTP
import Transport

let drop = Droplet()
let parser = FAPLParser()

//MARK: Email

func sendEmail() -> () {
    let credentials = SMTPCredentials(user: "roudique", pass: "Jqegervsrw18")
    let from = "roudique@gmail.com"
    let to = "panzerfauster.wot@gmail.com"
    
    
    
    let email = Email(
        from: from,
        to: to,
        subject: "Vapor SMTP - Simple",
        body: "Hello from Vapor SMTP 👋"
    )
    
    // MARK: Send
    
    let client = try! SMTPClient<TCPClientStream>.makeSendGridClient()
    let (code, reply) = try! client.send(email, using: credentials)
    print("Successfully sent email: \(code) \(reply)")
    
}

//Mark: GET methods

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
    
    sendEmail()
    
    return try! JSON(node: Node.init(responseDict))
}






drop.run()


