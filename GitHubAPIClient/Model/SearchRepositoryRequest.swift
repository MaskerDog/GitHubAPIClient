//
//  SearchRepositoryRequest.swift
//  GitHubAPIClient
//
//  Created by npc on 2022/05/31.
//

import Foundation

protocol APIRequestType {
    // <ジェネリクス>の書き方の代わり
    associatedtype Response: Decodable
    
    // プロパティ
    var path: String { get } // 計算型プロパティという意味ではない
    var queryItems: [URLQueryItem]? { get }
}


struct SearchRepositoryRequest: APIRequestType {
    typealias Response = SearchRepositoryResponse
    
    private let query: String
    
    let path = "/search/repositories"
    
    private(set) var queryItems: [URLQueryItem]?
    
    init(query: String) {
        self.query = query
        self.queryItems = [.init(name: "q", value: query),
                           .init(name: "order", value: "desc")]
    }
}

