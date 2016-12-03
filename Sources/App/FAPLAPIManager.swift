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
        
        if let response = try? drop.client.get("\(kFaplAPIString)/\(id)") {
            switch response.body {
            case Body.data :
                if let body = response.body.bytes {
                    if let parsed = String.init(bytes: body, encoding: .windowsCP1251) {
                        
                        if let doc = HTMLDocument(html: parsed, encoding: .windowsCP1251) {
                            
                            //parse name of post
                            let header = doc.search(byXPath: "//h2")
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

                            var items = [String]()
                            var logoImage : String?
                            
                            let content = doc.search(byXPath: "//div[@class='content']")
                            
                            //parse text of post
                            switch content {
                            case .nodeSet(let contentSet):
                                for content in contentSet {
                                    if content.parent?.className == "block" {
                                        for element in content.search(byXPath: "p").array {
                                            let images = element.search(byXPath: "img")
                                            logoImage = images.first?["src"]
                                            if logoImage != nil {
                                                print("Logo image: \(logoImage)\n")
                                            }
                                            
                                            if images.count > 1 {
                                                for i in 1...images.count-1 {
                                                    print("Image: \(images.array[i]["src"])")
                                                }
                                            }
                                            
                                            
                                            if let paragraphItem = element.content {
                                                
                                                let separatedParagraphs = paragraphItem.split(delimiter: .controlCharacters).filter({ string in
                                                    !string.isEmpty
                                                })
                                                var paragraphs = [String]()
                                                for paragraph in separatedParagraphs {
                                                        paragraphs.append(paragraph)
                                                }
                                                
                                                
                                                
                                                items.append(contentsOf: paragraphs)
                                            }
                                        }
                                        
                                    }
                                }
                            default:
                                break;
                            }
                            
                            print(postName ?? "Post name doesn't exist for post #\(id)")
                            
                            if let name = postName {
                                completion( FAPLPost.init(ID: id, imgPath: logoImage, title: name, paragraphs: items) )
                                return;
                            } else {
                                print("Error parsing HTML:\n")
                                if postName == nil {
                                    print("-- no post name found;")
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
