//
//  APIService.swift
//  GitHubAPIClient
//
//  Created by npc on 2022/05/31.
//

import Foundation
import Combine

protocol APIServiceType {
    // Request.ResponseはDecodableの何かである
    func request<Request>(with request: Request) -> AnyPublisher<Request.Response, APIServiceError> where Request: APIRequestType
}

/// API通信をしてDecodeまでする
final class APIService: APIServiceType {
    
    private let baseURLString: String
    
    init(baseURLString: String = "https://api.github.com") {
        self.baseURLString = baseURLString
    }
    
    func request<Request>(with request: Request) -> AnyPublisher<Request.Response, APIServiceError> where Request : APIRequestType {
        guard let pathURL = URL(string: request.path, relativeTo: URL(string: baseURLString)) else {
            return Fail(error: APIServiceError.invalidURL).eraseToAnyPublisher()
        }
        
        var urlCompornents = URLComponents(url: pathURL, resolvingAgainstBaseURL: true)!
        // パラメータの設定
        urlCompornents.queryItems = request.queryItems
        
        var request = URLRequest(url: urlCompornents.url!)
        
        // 今回は無くとも良い（いつか使う時もあるかもしれないから、覚えておく）
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let decoder = JSONDecoder()
        // JSONのスネークケースをSwift側が自動でキャメルケースにしてparseしてくれる
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return URLSession.shared.dataTaskPublisher(for: request)
        // 取ってきたデータをどうするの？
        // mapでレスポンスデータだけをストリームにつかう(レスポンスデータは使わない）
            .map { data, urlResponse in
                return data
            }
        // エラーが起きるかもしれない
            .mapError { _ in
                APIServiceError.responseError
            }
        // ここから先は正常なデータを処理していく
        // dataはJSONなので、デコードする
            .decode(type: Request.Response.self, decoder: decoder)
        // エラー起こすかもよ？ try decoder.decode みたいに書いてきた
            .mapError { error in
                APIServiceError.parseError(error)
            }
        // メインスレッドで実行して欲しい
            .receive(on: RunLoop.main)
        // Publisherを平坦にならす
            .eraseToAnyPublisher()
    }
}
