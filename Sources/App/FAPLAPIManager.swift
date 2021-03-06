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
                                break
                            }
                            
                            var tags = [String]()
                            let tagsXPath = doc.search(byXPath: "//p[@class='tags']")
                            switch tagsXPath {
                            case .nodeSet(let tagsSet):
                                for tag in tagsSet {
                                    if let tagString = tag.content {
                                        var tagsArray = tagString.split(delimiter: CharacterSet.init(charactersIn: ",")).filter({ string in
                                            !string.isEmpty
                                        })
                                        tagsArray = tagsArray.map({ str in
                                            return str.trim()
                                        })
                                        
                                        tags.append(contentsOf: tagsArray)
                                    }
                                }
                            default:
                                break
                            }
                            
                            let dateXPath = doc.search(byXPath: "//p[@class='date f-r']")
                            var timestamp : Int?
                            switch dateXPath {
                            case .nodeSet(let dateNodeSet):
                                if let dateTimeString = dateNodeSet.first?.content {
                                    if let date = parse(date: dateTimeString) {
                                        timestamp = Int(date.timeIntervalSince1970)
                                    }
                                }
                            default:
                                break
                            }
                            
                            print(postName ?? "Post name doesn't exist for post #\(id)")
                            
                            if let name = postName {
                                let post = FAPLPost.init(ID: id, imgPath: logoImage, title: name, paragraphs: items)
                                post.tags = tags
                                post.timestamp = timestamp
                                completion(post)
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

func parse(date: String) -> Date? {
    let components = date.split(delimiter: .init(charactersIn: " "), needEmpty: false)
    let comp = (components.first, components.last)
    if let dateString = comp.0, let timeString = comp.1 {
        let fullDateString = "\(dateString) \(timeString)"
        
        let moscowGMTTimeDifference = 60 * 60 * 3
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.init(secondsFromGMT: moscowGMTTimeDifference)
        dateFormatter.dateFormat = "dd.MM.yyyy hh:mm"
        return dateFormatter.date(from: fullDateString)
    }
    
    return nil
}
