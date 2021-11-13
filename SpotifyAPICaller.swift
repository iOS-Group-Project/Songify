//
//  SpotifyAPICaller.swift
//  Songify
//
//  Created by Matthew Piedra on 11/13/21.
//

import Foundation
import SpotifyWebAPI
import Combine

class SpotifyAPICaller {
    private static let clientId: String = {
        if let clientId = ProcessInfo.processInfo
                .environment["client_id"] {
            return clientId
        }
        fatalError("Could not find 'CLIENT_ID' in environment variables")
    }()
        
    private static let clientSecret: String = {
        if let clientSecret = ProcessInfo.processInfo
                .environment["client_secret"] {
            return clientSecret
        }
        fatalError("Could not find 'CLIENT_SECRET' in environment variables")
    }()

    
    static let client = SpotifyAPICaller()
    
    let api = SpotifyAPI(
        authorizationManager: ClientCredentialsFlowManager(
            clientId: clientId, clientSecret: clientSecret
        )
    )
    var cancellables: Set<AnyCancellable> = []
    
    // authorization
    func authorize() {
        api.authorizationManager.authorize()
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        print("Successfully Songify application")
                    case .failure(let error):
                        print("could not authorize application: \(error)")
                }
            })
            .store(in: &cancellables)
    }
}
