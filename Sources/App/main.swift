import Vapor
import Foundation
import SMTP
import Transport
import HTTP
import Scrape

let drop = Droplet()
let configDirectory = drop.workDir.finished(with: "/") + "Config/secrets/"
let credentialsJSON = FAPLCredentials.init(credentialPath: configDirectory)
let apiManager = FAPLAPIManager.init(droplet: drop)

//MARK: Email

func sendEmail(to: String, subject: String, body: String) {
    guard let adminEmail = credentialsJSON.adminEmail else { return }
    guard let smtpUsername = credentialsJSON.smtp.username,
        let smtpPassword = credentialsJSON.smtp.password else {
        return
    }
    
    let credentials = SMTPCredentials(user: smtpUsername,
                                      pass: smtpPassword)
    let from = "fapl server"

    let email = Email(
        from: from,
        to: adminEmail,
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
        var faplPost : FAPLPost?
        apiManager.getPost(id: ID, completion: { foundPost in
            if let post = foundPost.extract() {
                faplPost = post
            }
            
        })
        
        if let post = faplPost {
            let json = try? JSON(node: [
                "status": "ok",
                "data" : Node.init(post.makeNodesDict())
                ])
            
            if let jsonResponse = json {
                return jsonResponse
            }
            return JSON.error(withMessage: "Error parsing post content.")
        }
        
        sendEmail(to:      "roudique@gmail.com",
                  subject: "FAPL server error",
                  body:    "Holy crap, server failed to request post #\(ID)!")
        
        return JSON.error(withMessage: "Post not found.")
    }
    
    return JSON.error(withMessage: "Error parsing post number from request.")
}

drop.run()




