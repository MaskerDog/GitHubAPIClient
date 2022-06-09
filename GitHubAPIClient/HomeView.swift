//
//  HomeView.swift
//  GitHubAPIClient
//
//  Created by npc on 2022/05/27.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel(apiService: APIService())
    
    var body: some View {
        SearchView(viewModel: viewModel)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
