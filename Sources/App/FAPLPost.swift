//
//  Post.swift
//  fapl-server
//
//  Created by Roudique on 11/12/16.
//
//

import Foundation
import Node

let kID = "ID"
let kTitle = "title"
let kText = "text"
let kImageShort = "img"


class FAPLPost {
    let ID : Int
    var imgPath : String?
    var title : String
    var text : String
    
    init(ID: Int, imgPath: String?, title: String, text: String) {
        self.ID = ID;
        self.title = title
        self.text = text
        self.imgPath = imgPath
    }
    
    func makeJSONString() -> String {
        var jsonDict = [kID : "\(ID)",
                        kTitle : title,
                        kText : text]
        
        if let imgPath = self.imgPath {
            jsonDict[kImageShort] = imgPath
        }
        
        let JSONdata = try! JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
        
        return String.init(data: JSONdata, encoding: .utf8)!
    }
    
    func makeNode() -> Node {
        var nodeDict = [kID : Node.init(self.ID),
            kTitle : Node.init(title),
            kText : Node.init(text)]
        
        if let imgPath = self.imgPath {
            nodeDict[kImageShort] = Node.init(imgPath)
        }
        
        return Node.init(nodeDict)
    }
}
