//
//  Credentials.swift
//  fapl-server
//
//  Created by Roudique on 11/14/16.
//
//

import Foundation

class FAPLCredentials {
    struct FAPLSMTP {
        var username : String?
        var password : String?
    }
    
    var smtp = FAPLSMTP()
    
    init(credentialPath: String) {
        
//        if let credentialPath = Bundle.main.path(forResource: "credentials", ofType: "json") {
            let credentialURL = URL.init(fileURLWithPath: credentialPath + "credentials.json")
            do {
                let credentialData = try Data.init(contentsOf: credentialURL)
                let credentialDict = try JSONSerialization.jsonObject(with: credentialData,
                                                                  options: .mutableContainers) as? Dictionary<String, Any>
                
                if let smtpDict = credentialDict?["SMTP"] as? Dictionary<String, String> {
                    self.smtp.username = smtpDict["username"]
                    self.smtp.password = smtpDict["password"]
                }
            } catch {
                print("Error parsing credentials JSON!")
            }
            
//        } else {
//            print("Error with credentials JSON! Can't find credentials.json in bundle.")
//        }
    }
    
    
    
}
