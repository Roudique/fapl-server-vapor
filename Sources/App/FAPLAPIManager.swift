//
//  FAPLAPIManager.swift
//  fapl-server
//
//  Created by Roudique on 11/21/16.
//
//

import Vapor
import Foundation
import SMTP
import Transport
import HTTP
import Kanna

let faplAPIString = "http://fapl.ru/posts/"

class FAPLAPIManager {
    var droplet : Droplet
    
    init(droplet: Droplet) {
        self.droplet = droplet
    }
    
    func getPost(id: Int, completion: (FAPLPost?) -> Void) {
        var postName : String?
        var postText : String?
        
        if let response = try? drop.client.get("\(faplAPIString)/\(id)") {
            switch response.body {
            case Body.data :
                if let body = response.body.bytes {
                    if let parsed = String.init(bytes: body, encoding: .windowsCP1251) {
                        
                        if let doc = HTML(html: parsed, encoding: .windowsCP1251) {
                            
                            //parse name of post
                            for link in doc.css("h2") {
                                if link.parent?.className == "block" {
                                    if let name = link.text {
                                        postName = name
                                        break
                                    }
                                }
                            }
                            
                            // parse text of post
                            for link in doc.css("div[class^='content']") {
                                if link.parent?.className == "block" {
                                    if let text = link.text {
                                        postText = text
                                        break
                                    }
                                }
                            }
                            print(postName ?? "Post name doesn't exist for post #\(id)")
                            
                            var textString = ""
                            if let paragraphs = postText?.components(separatedBy: "\n") {
                                for textItem in paragraphs {
                                    if textItem.count > 0 {
                                        print(textItem)
                                        textString.append(textItem)
                                    }
                                }
                            }
                            
                            print(textString)
                            
                            if let name = postName, let text = postText {
                                completion( FAPLPost.init(ID: id, imgPath: nil, title: name, text: text) )
                                return;
                            } else {
                                print("Error parsin HTML:\n")
                                if postName == nil {
                                    print("-- no post name found;")
                                }
                                if postText == nil {
                                    print("-- no post text found;")
                                }
                            }
                            
                        }
                    } else {
                        print("Error parsing HTML")
                    }
                }
            case Body.chunked : print("chunked")
            }
            
        } else {
            print("Request failed")
        }
        completion(nil)
    }
}
