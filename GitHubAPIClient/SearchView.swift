//
//  SearchView.swift
//  GitHubAPIClient
//
//  Created by npc on 2022/05/27.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    
//    @State private var cardViewInputs: [CardView.Input] = [CardView.Input(
//        iconImage: UIImage(named: "Tarou2")!,
//        title: "タイトル",
//        language: "swift",
//        star: 2000, description: "説明文",
//        url: "https://www.jec.ac.jp"),
//    ]
    
    @State var text: String = ""
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    Text("読込中....")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .offset(x: 0, y: -200)
                } else {
                    ScrollView(showsIndicators: false) {
                        // カードを入れたい
                        // たくさんある
                        ForEach (viewModel.cardViewInputs) { input in
                            // ボタンにしてしまおう！！！！！
                            Button {
                                viewModel.apply(inputs: .tappedCardView(urlString: input.url))
                            } label: {
                                CardView(input: input)
                            }
                        }
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    TextField("検索キーワードを入力", text: $text) {
                        viewModel.apply(inputs: .onCommit(text: text))
                    }
                    // テキストフィールドのスタイルを角丸にする
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.asciiCapable)
                    .frame(width: UIScreen.main.bounds.width - 40)
                }
            }
            .sheet(isPresented: $viewModel.isShowSheet) {
                // View
                SafariView(url: URL(string: viewModel.repositoryURL)!)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(viewModel: HomeViewModel(apiService: APIService()))
    }
}
