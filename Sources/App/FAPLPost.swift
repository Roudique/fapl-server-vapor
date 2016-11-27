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
let kParagraphs = "paragraphs"
let kImageShort = "img"


class FAPLPost : Model {
    var id : Node?
    var exists: Bool = false
    
    var imgPath : String?
    var title : String
    var timestamp : Int?
    var paragraphs = [String]()
    
    init(ID: Int, imgPath: String?, title: String, paragraphs: [String]) {
        self.id = Node.init(ID);
        self.title = title
        self.imgPath = imgPath
        self.paragraphs = paragraphs
    }
    
    //MARK: - NodeInitializable
    required init(node: Node, in context: Context) throws {
        id = try node.extract(kID)
        title = try node.extract(kTitle)
    }
    
    //MARK: - Preparation
    static func prepare(_ database: Database) throws {
        assertionFailure("prepare(_ database: Database) not implemented!")
    }
    static func revert(_ database: Database) throws {
        assertionFailure("revert(_ database: Database) not implemented!")
    }
    
    //MARK: - NodeRepresentable
    
    func makeNode() throws -> Node {
        return try Node(node: [
            kID: id,
            kTitle: title
            ])
    }
    
    func makeNode(context: Context) throws -> Node {
        return try self.makeNode()
    }
    
    //MARK: - Public
    
    func makeNodesDict() -> [String : Node] {
        var paragraphNodes = [Node]()
        for paragraph in self.paragraphs {
            paragraphNodes.append(Node.init(stringLiteral: paragraph))
        }
        
        
        var nodesDict = [kID    : id!,
                         kTitle : Node.init(title),
                         kParagraphs : Node.init(paragraphNodes)]
        
        if let imgPath = self.imgPath {
            nodesDict[kImageShort] = Node.init(imgPath)
        }
        
        return nodesDict
    }
}
