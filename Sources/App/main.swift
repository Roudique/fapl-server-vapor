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
    
    let client = try! SMTPClient<TCPClientStream>.makeSendGridClient()
    let (code, reply) = try! client.send(email, using: credentials)
    print("Successfully sent email: \(code) \(reply)")
    
}

//MARK: GET methods

drop.get("post", ":number") { request in
    if let ID = request.parameters["number"]?.int {
        if let post = parser.post(ID: ID) {
            let json = try? JSON(node: [
                "status": "ok",
                "data" : Node.init(post.makeNodesDict())
                ])
            
            if let jsonResponse = json {
                return jsonResponse
            }
            return try JSON(node: [
                "status" : "error",
                "error" : "Error parsing post content"])
        }
    }
    let responseDict = ["status" : Node.init("error"),
                        "error" : Node.init("Post not found")]
    
    sendEmail(to:      "roudique@gmail.com",
              subject: "FAPL server error",
              body:    "Holy crap, someone requested post that was not found!")
    
    return try! JSON(node: Node.init(responseDict))
}




drop.run()


