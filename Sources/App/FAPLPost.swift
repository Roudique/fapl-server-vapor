//
//  Post.swift
//  fapl-server
//
//  Created by Roudique on 11/12/16.
//
//

import Foundation
import Node
import Vapor

let kID         = "id"
let kTitle      = "title"
let kText       = "text"
let kImageShort = "img"


class FAPLPost : Model {
    var id : Node?
    var exists: Bool = false
    
    var imgPath : String?
    var title : String
    var text : String
    var timestamp : Int?
    
    init(ID: Int, imgPath: String?, title: String, text: String) {
        self.id = Node.init(ID);
        self.title = title
        self.text = text
        self.imgPath = imgPath
    }
    
    //MARK: - NodeInitializable
    required init(node: Node, in context: Context) throws {
        id = try node.extract(kID)
        title = try node.extract(kTitle)
        text = try node.extract(kText)
    }
    
    //MARK: - Preparation
    static func prepare(_ database: Database) throws {
        
    }
    static func revert(_ database: Database) throws {
        
    }
    
    //MARK: - NodeRepresentable
    
    func makeNode() throws -> Node {
        return try Node(node: [
            kID: id,
            kTitle: title,
            kText: text
            ])
    }
    
    func makeNode(context: Context) throws -> Node {
        return try self.makeNode()
    }
    
    //MARK: - Public
    
    func makeNodesDict() -> [String : Node] {
        var nodesDict = [kID    : id!,
                         kTitle : Node.init(title),
                         kText  : Node.init(text)]
        
        if let imgPath = self.imgPath {
            nodesDict[kImageShort] = Node.init(imgPath)
        }
        
        return nodesDict
    }
}
