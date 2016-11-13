//
//  FAPLParser.swift
//  fapl-server
//
//  Created by Roudique on 11/12/16.
//
//

import Foundation

class FAPLParser {
    var posts : Array<FAPLPost>
    
    init() {
        let post1 = FAPLPost.init(ID: 0, imgPath: nil, title: "Игроки &quot;Юнайтед&quot; — самые высокооплачиваемые в мировом футболе", text: "Средняя зарплата игрока первой команды \"Манчестер Юнайтед\" в этом сезоне составляет 5.77 миллионов фунтов в год, и по этому показателю \"красным дьяволам\" нет равных в мировом футболе.</p><p>В своем ежегодном исследовании аналитики GSSS оценили базовые зарплаты почти 10 тысяч спортсменов из 333 клубов 17 богатейших мировых лиг в семи видах спорта.<br />")
        
        let post2 = FAPLPost.init(ID: 1, imgPath: nil, title: "Схема 3-4-3 была четвертым вариантом Конте на этот сезон", text: "Главный тренер \"Челси\" Антонио Конте признался, что схема 3-4-3 была его только четвертым вариантом игры на этот сезон")
        
        posts = [post1, post2]

    }
    
    func post(ID : Int) -> FAPLPost? {
        for post in posts {
            if post.ID == ID {
                return post
            }
        }
        return nil
    }
}
