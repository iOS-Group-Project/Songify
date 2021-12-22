//
//  Constants.swift
//  Songify
//
//  Created by Matthew Piedra on 12/20/21.
//

import Foundation

// enum: Common type over constant subtypes in a safe environment

enum SpotifyBaseUrls: String {
    case accounts = "https://accounts.spotify.com/"
    case api = "https://api.spotify.com/"
}

enum SpotifyEndpoints: String {
    case authorize = "api/token"
    case search = "v1/search"
    case artists = "v1/artists"
    case albums = "v1/albums"
}

enum IDCategories: String {
    case track = "track"
    case artist = "artist"
    case album = "album"
    case playlist = "playlist"
    case show = "show"
    case episode = "episode"
}

enum AlbumGroups: String {
    case album = "album"
    case single = "single"
    case appearsOn = "appears_on"
    case compilation = "compilation"
}

let clarifaiBaseURL = "https://api.clarifai.com"
let modelID = "e466caa0619f444ab97497640cefc4dc"
let model_version = "2ba4d0b0e53043f38dbbed49e03917b6"
