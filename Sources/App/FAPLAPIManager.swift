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
import Scrape

let kFaplAPIString = "http://fapl.ru/posts/"

class FAPLAPIManager {
    var droplet : Droplet
    
    init(droplet: Droplet) {
        self.droplet = droplet
    }
    
    func getPost(id: Int, completion: (FAPLPost?) -> Void) {
        var postName : String?
        var postText : String?
        
        if let response = try? drop.client.get("\(kFaplAPIString)/\(id)") {
            switch response.body {
            case Body.data :
                if let body = response.body.bytes {
                    if let parsed = String.init(bytes: body, encoding: .windowsCP1251) {
                        
                        if let doc = HTMLDocument(html: parsed, encoding: .windowsCP1251) {
                            
                            //parse name of post
                            let header = doc.search(byCSSSelector: "h2")
                            switch header {
                            case .nodeSet(let headers):
                                for headerXML in headers {
                                    if headerXML.parent?.className == "block" {
                                        postName = headerXML.text
                                    }
                                }
                            default:
                                break;
                            }
//                            
                            var images = [String]()
                            
                            let content = doc.search(byCSSSelector: "div[class^='content']")
                            
                            //[arse text of post
                            switch content {
                            case .nodeSet(let contentSet):
                                for content in contentSet {
                                    if content.parent?.className == "block" {
                                        if let text = content.text {
                                            postText = text
                                            
                                            
                                            
                                            break
                                        }
                                    }
                                }
                            default:
                                break;
                            }
//                            
//                            // parse text of post
//                            for content in doc.css("div[class^='content']") {
//                                if content.parent?.className == "block" {
//                                    if let text = content.text {
//                                        postText = text
//                                        
//                                        //parse image of post
//                                        let paragraphsSet = content.css("p")
//                                        for paragraph in paragraphsSet.array {
//                                            let imagesSet = paragraph.css("img")
//                                            
//                                            for image in imagesSet.array {
//                                                if let imagePath = image["src"] {
//                                                    images.append(imagePath)
//                                                }
//                                            }
//                                        }
//                                        
//                                        break
//                                    }
//                                }
//                            }
                            print(postName ?? "Post name doesn't exist for post #\(id)")
                            
                            
                            var textString = ""
                            if let paragraphs = postText?.components(separatedBy: "\n") {
                                for textItem in paragraphs {
                                    if textItem.count > 0 {
                                        textString.append(textItem)
                                    }
                                }
                            }
                                                        
                            if let name = postName, let text = postText {
                                completion( FAPLPost.init(ID: id, imgPath: images.first, title: name, text: text) )
                                return;
                            } else {
                                print("Error parsing HTML:\n")
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
