//
//  SpotifyAPIData.swift
//  Songify
//
//  Created by Matthew Piedra on 12/23/21.
//

import Foundation

final class SpotifyAPIData {
    // MARK: Shared Instance
    static let shared = SpotifyAPIData()
    
    // MARK: Can't init; is a singleton class
    private init() { }
    
    // MARK: Local Data Members
    var albums: [[String:Any]] = []
}
