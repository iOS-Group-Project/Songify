//
//  SpotifyAPICaller.swift
//  Songify
//
//  Created by Matthew Piedra on 12/22/21.
//

import Foundation

class SpotifyAPICaller {
    static let client = SpotifyAPICaller()
    
    var accessToken: String = ""
    
    // authorization
    func authorize() {
        let path = SpotifyBaseUrls.accounts.rawValue + SpotifyEndpoints.authorize.rawValue
        
        if let url = URL(string: path) {
            var postRequest = URLRequest(url: url)
            postRequest.httpMethod = "POST"
            let bodyParams = "grant_type=client_credentials"
            postRequest.httpBody = bodyParams.data(using: String.Encoding.ascii, allowLossyConversion: true)
            
            let id = "\(SpotifyKeys.client_id)"
            let secret = "\(SpotifyKeys.client_secret)"
            let combined = "\(id):\(secret)"
            let combo = combined.toBase64()
            postRequest.addValue("Basic \(combo)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: postRequest) { (data, response, error) in
                guard let data = data else {
                    return
                }
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                
                self.accessToken = dataDictionary["access_token"] as! String
                
                print(dataDictionary)
            }
            task.resume()
        }
    }
    
    func search(query: String, type: [String], market: String? = "ES", limit: Int? = 20, offset: Int? = 0, includeExternal: String? = "", success: @escaping ([String:Any]) -> (), failure: @escaping (Error) -> ()) {
        
        let type_encoded = type.map({ (string) in
            return String(string)
        }).joined(separator: ",")
        let query_encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let params = "?query=\(query_encoded!)&type=\(type_encoded)&market=\(market!)&limit=\(limit!)&offset=\(offset!)&includeExternal=\(includeExternal!)"
        let full_path = SpotifyBaseUrls.api.rawValue + SpotifyEndpoints.search.rawValue + params

        if let url = URL(string: full_path) {
            var getRequest = URLRequest(url: url)
            getRequest.httpMethod = "GET"

            let accessToken = self.accessToken
            getRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

            let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
            let task = session.dataTask(with: getRequest) { (data, response, error) in
                if error == nil {
                    let dataDictionary = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]

                    success(dataDictionary)
                }
                else {
                    failure(error!)
                }
            }

            task.resume()
        }
    }
    
    func artistAlbums(artist: String, groups: [String]? = nil, country: String? = "US", limit: Int? = 20, offset: Int? = 0, success: @escaping ([String:Any]) -> (), failure: @escaping (Error) -> ()) {
        let groups_encoded = groups?.map({ (str) in
            return String(str)
        }).joined(separator: ",")
        
        let params = "?include_groups=\(groups_encoded!)&market=\(country!)&limit=\(limit!)&offset=\(offset!)"
        let full_path = SpotifyBaseUrls.api.rawValue + SpotifyEndpoints.artists.rawValue + "/\(artist)/albums" + params
        
        if let url = URL(string: full_path) {
            var getRequest = URLRequest(url: url)
            getRequest.httpMethod = "GET"

            let accessToken = self.accessToken
            getRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

            let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
            let task = session.dataTask(with: getRequest) { (data, response, error) in
                if error == nil {
                    let dataDictionary = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]

                    success(dataDictionary)
                }
                else {
                    failure(error!)
                }
            }

            task.resume()
        }
    }
    
    func albumsTracks(album: String, market: String? = "US", limit: Int? = 20, offset: Int? = 0, success: @escaping ([String:Any]) -> (), failure: @escaping (Error) -> ()) {
        let params = "?market=\(market!)&limit=\(limit!)&offset=\(offset!)"
        let full_path = SpotifyBaseUrls.api.rawValue + SpotifyEndpoints.albums.rawValue + "/\(album)/tracks" + params
        
        if let url = URL(string: full_path) {
            var getRequest = URLRequest(url: url)
            getRequest.httpMethod = "GET"

            let accessToken = self.accessToken
            getRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

            let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
            let task = session.dataTask(with: getRequest) { (data, response, error) in
                if error == nil {
                    let dataDictionary = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]

                    success(dataDictionary)
                }
                else {
                    failure(error!)
                }
            }

            task.resume()
        }
    }
}
