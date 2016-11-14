import Vapor
import Foundation
import SMTP
import Transport

let drop = Droplet()
let parser = FAPLParser()
let configDirectory = drop.workDir.finished(with: "/") + "Config/secrets/"
let credentialsJSON = FAPLCredentials.init(credentialPath: configDirectory)

//MARK: Email

func sendEmail(to: String, subject: String, body: String) -> () {
    guard let smtpUsername = credentialsJSON.smtp.username,
        let smtpPassword = credentialsJSON.smtp.password else {
        return
    }
    
    let credentials = SMTPCredentials(user: smtpUsername,
                                      pass: smtpPassword)
    let from = "roudique@gmail.com"

    let email = Email(
        from: from,
        to: to,
        subject: subject,
        body: body
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
    
    sendEmail(to: "roudique@gmail.com", subject: "FAPL server", body: "Holy crap, someone requested post that was not found!")
    
    return try! JSON(node: Node.init(responseDict))
}


drop.run()


