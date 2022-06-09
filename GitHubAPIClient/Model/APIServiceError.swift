//
//  APIServiceError.swift
//  GitHubAPIClient
//
//  Created by npc on 2022/05/31.
//

import Foundation

enum APIServiceError: Error {
    // URLが不正
    case invalidURL
    // githubAPIのレスポンスにエラーがある
    case responseError
    // JSONをパースした時に発生したエラー
    case parseError(Error)
}
