//
//  Post.swift
//  fapl-server
//
//  Created by Roudique on 11/12/16.
//
//

import Foundation
import Node

let kID         = "ID"
let kTitle      = "title"
let kText       = "text"
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
    
    func makeNodesDict() -> [String : Node] {
        return [kID    : Node.init("\(ID)"),
                kTitle : Node.init(title),
                kText  : Node.init(text)]
    }
}
