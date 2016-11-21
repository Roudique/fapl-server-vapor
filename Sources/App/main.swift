import Vapor
import Foundation
import SMTP
import Transport
import HTTP
import Kanna

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

if let response = try? drop.client.get("http://fapl.ru/posts/99/") {
    switch response.body {
    case Body.data :
        if let body = response.body.bytes {
            if let parsed = String.init(bytes: body, encoding: .windowsCP1251) {
                
                if let doc = HTML(html: parsed, encoding: .windowsCP1251) {
                    print(doc.title ?? "")
                    
                    // Search for nodes by CSS
                    for link in doc.css("div[class^='block']") {
                        
                            print("Parent of class: \(link.parent?.className)")
                            print("Class of element: \(link.className)")
                            print("Text of element : \(link.text)")
                            print("----------------------")
                        
                    }
                }
                
            }
        }
    case Body.chunked : print("chunked")
    }

} else {
    print("request failed")
}

drop.run()


