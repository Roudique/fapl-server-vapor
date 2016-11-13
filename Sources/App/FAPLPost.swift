//
//  Post.swift
//  fapl-server
//
//  Created by Roudique on 11/12/16.
//
//

import Foundation
import Node

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
        var jsonDict = ["ID" : "\(ID)",
                        "title" : title,
                        "text" : text]
        
        if let imgPath = self.imgPath {
            jsonDict["img"] = imgPath
        }
        
        let JSONdata = try! JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
        
        return String.init(data: JSONdata, encoding: .utf8)!
    }
    
    func makeNode() -> Node {
        var nodeDict = ["ID" : Node.init(self.ID),
            "title" : Node.init(title),
            "text" : Node.init(text)]
        
        if let imgPath = self.imgPath {
            nodeDict["img"] = Node.init(imgPath)
        }
        
        return Node.init(nodeDict)
    }
}
