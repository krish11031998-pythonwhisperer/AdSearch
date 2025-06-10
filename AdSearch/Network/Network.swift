//
//  Network.swift
//  AdSearch
//
//  Created by Krishna Venkatramani on 04/06/2025.
//

import Foundation
import Combine

class NetworkManager {
    
    public static func fetchData<T: Decodable>(urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
        urlRequest.timeoutInterval = 30
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse ,200..<300 ~= httpResponse.statusCode else  {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let decodedData = try decoder.decode(T.self, from: data)
        
        return decodedData
    }
}
