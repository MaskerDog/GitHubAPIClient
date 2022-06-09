//
//  HomeViewModel.swift
//  GitHubAPIClient
//
//  Created by npc on 2022/05/31.
//

import SwiftUI
import Combine

final class HomeViewModel: ObservableObject {
    // MARK: - Inputs
    enum Inputs {
        // ユーザーの入力操作が終わった
        // テキストフィールドの中身をtextに入れておいてね
        case onCommit(text: String)
        
        // CardViewがタップされた
        // Safariで開くURLを入れておく
        case tappedCardView(urlString: String)
    }
    
    // MARK: - Outputs
    // 表示するリポジトリデータ
    @Published private(set) var cardViewInputs: [CardView.Input] = []
    
    // テキストフィールドで入力された値
    @Published var inputText: String = ""
    
    // エラーアラートを表示するかどうか
    @Published var isShowError = false
    
    // 読み込みテキストを表示するかどうか
    @Published var isLoading = false
    
    // SafariView表示するかどうか
    @Published var isShowSheet = false
    
    // 表示するリポジトリのURL
    @Published var repositoryURL = ""
    
    // MARK: - Private
    // 通信をする処理が入っているService
    private let apiService: APIServiceType
    
    // Publisherを動かしたい
    private let onCommitSubject = PassthroughSubject<String, Never>()
    
    // JSONを分解したものを受け取って何かしら処理をする
    private let responseSubject = PassthroughSubject<SearchRepositoryResponse, Never>()
    
    // エラーが起きたら動くSubject
    private let errorSubject = PassthroughSubject<APIServiceError, Never>()
    
    // Cancellableが入れられるようにする
    private var cancellable = Set<AnyCancellable>()
    
    init(apiService: APIServiceType) {
        self.apiService = apiService
        bind() // ない
    }

    func bind() {
        onCommitSubject
        // 検索文字(query = 検索文字)
            .flatMap { query in
                self.apiService.request(with: SearchRepositoryRequest(query: query))
            }
            .catch { error -> Empty<SearchRepositoryResponse, Never> in
                self.errorSubject.send(error)
                return Empty()
            }
            .map { $0.items }
        //Subscriber
            .sink { repositories in
                
                // CardViewが欲しい
                self.cardViewInputs = self.convertInput(repositories: repositories)
                self.isLoading = false
            }
            .store(in: &cancellable)
        
        onCommitSubject
            .map { _ in true }
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellable)
        
        errorSubject
            .sink { _ in
                
            }
            .store(in: &cancellable)
    }
    
    private func convertInput(repositories: [Repository]) -> [CardView.Input] {
        var inputs: [CardView.Input] = []
        for repository in repositories {
            guard let url = URL(string: repository.owner.avatarUrl) else  {
                continue
            }
            
            // 画像データをネットから取得
            let data = try? Data(contentsOf: url)
            // データを画像化
            let image = UIImage(data: data ?? Data()) ?? UIImage()
            
            inputs.append(CardView.Input(iconImage: image, title: repository.name, language: repository.language, star: repository.stargazersCount, description: repository.description, url: repository.htmlUrl))
            
        }
        return inputs
    }
    
    func apply(inputs: Inputs) {
        switch inputs {
            
        case .onCommit(text: let text):
            // 検索して欲しい
            onCommitSubject.send(text)
            
        case .tappedCardView(urlString: let urlString):
            // SafariViewを起動して欲しい
            repositoryURL = urlString
            isShowSheet = true
        }
    }
    
}

