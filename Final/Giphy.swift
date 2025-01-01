//
//  Giphy.swift
//  Final
//
//  Created by user12 on 2024/12/21.
//

import SwiftUI
import Combine

struct GiphyGif: Decodable, Identifiable {
    let id: String
    let title: String
    let images: GifImages
    
    struct GifImages: Decodable {
        let fixedHeightSmall: StaticImage
        
        enum CodingKeys: String, CodingKey {
            case fixedHeightSmall = "fixed_height_small"
        }
        
        struct StaticImage: Decodable {
            let url: String
        }
    }
}

struct GiphyResponse: Decodable {
    var data: [GiphyGif]
}

// 網路服務
class GiphyAPI: ObservableObject {
    @Published var gifs: [GiphyGif] = []
    private let apiKey = "9mLPR3EVi77uAuxKaFuBH7NVXJpismGh"
    
    func fetchTrendingGifs() {
        let urlString = "https://api.giphy.com/v1/gifs/trending?api_key=\(apiKey)&limit=20"
        fetchGifs(from: urlString)
    }
    
    func fetchSearchResults(query: String) {
        let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.giphy.com/v1/gifs/search?api_key=\(apiKey)&q=\(queryEncoded)&limit=20"
        fetchGifs(from: urlString)
    }
    
    private func fetchGifs(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching GIFs: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(GiphyResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.gifs = response.data
                }
            } catch {
                print("Error decoding GIFs: \(error.localizedDescription)")
            }
        }.resume()
    }
}
