//
//  TestView.swift
//  Final
//
//  Created by user12 on 2024/12/21.
//

import SwiftUI

struct TestView: View {
    @StateObject private var giphyAPI = GiphyAPI()
    @State private var searchQuery: String = ""
    var onImageSelected: (URL) -> Void

    var body: some View {
        VStack {
            HStack {
                TextField("Search Giphy", text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button(action: {
                    giphyAPI.fetchSearchResults(query: searchQuery)
                }) {
                    Image(systemName: "magnifyingglass")
                        .padding()
                        .background(Color(hue: 0.077, saturation: 0.356, brightness: 0.72))
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(Color.white)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                    ForEach(giphyAPI.gifs) { gif in
                        if let url = URL(string: gif.images.fixedHeightSmall.url) {
                            AsyncImage(url: url)
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .onTapGesture {
                                    onImageSelected(url) // 返回选中的 URL
                                }
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            giphyAPI.fetchTrendingGifs()
        }
    }
}

