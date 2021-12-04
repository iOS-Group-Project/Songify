//
//  ArtistImageViewController.swift
//  Songify
//
//  Created by Matthew Piedra on 11/13/21.
//

import UIKit
import AlamofireImage
import Alamofire
import SpotifyWebAPI
import Combine

class ArtistImageViewController: UIViewController {
    
    @IBOutlet var collection: [UIImageView]!
    
    var artists: [[String]] = [
        ["Kanye West", "https://upload.wikimedia.org/wikipedia/commons/thumb/1/10/Kanye_West_at_the_2009_Tribeca_Film_Festival_%28cropped%29.jpg/1200px-Kanye_West_at_the_2009_Tribeca_Film_Festival_%28cropped%29.jpg"],
        ["Hailee Steinfeild", "https://www.biography.com/.image/t_share/MTU0NDU2MTI2ODc4OTE3Njgy/hailee-steinfeld-visits-build-london-on-december-7-2017-in-london-england-photo-by-mike-marsland_mike-marsland_wireimage-square.jpg"],
        ["Eminem",
            "https://www.biography.com/.image/t_share/MTQ3NjM5MTEzMTc5MjEwODI2/eminem_photo_by_dave_j_hogan_getty_images_entertainment_getty_187596325.jpg"],
        ["Ariana Grande",
            "https://www.biography.com/.image/t_share/MTQ3MzM3MTcxNjA5NTkzNjQ3/ariana_grande_photo_jon_kopaloff_getty_images_465687098.jpg"],
        ["Rihanna",
            "https://yt3.ggpht.com/ytc/AKedOLRkpn9XqlqjnHeh8h1gFKF26Tix8H2eNm583jinMg=s900-c-k-c0x00ffffff-no-rj"],
        ["Drake",
            "https://www.biography.com/.image/ar_1:1%2Cc_fill%2Ccs_srgb%2Cfl_progressive%2Cq_auto:good%2Cw_1200/MTQ3NTI2OTA4NzY5MjE2MTI4/drake_photo_by_prince_williams_wireimage_getty_479503454.jpg"],
        ["The Weeknd",
            "https://image-cdn.hypb.st/https%3A%2F%2Fhypebeast.com%2Fimage%2F2021%2F09%2Fthe-weeknd-cant-feel-my-face-alternate-music-video-beauty-behind-the-madness-sixth-anniversary-tw.jpg?w=960&cbr=1&q=90&fit=max"],
        ["Justin Bieber",
            "https://www.biography.com/.image/t_share/MTM2OTI2NTY2Mjg5NTE2MTI5/justin_bieber_2015_photo_courtesy_dfree_shutterstock_348418241_croppedjpg.jpg"],
        ["Katy Perry",
            "https://i.guim.co.uk/img/media/f5c1ab9ea0a0e3cccaa708558918cdb300c126d2/0_635_4480_2687/master/4480.jpg?width=1200&height=1200&quality=85&auto=format&fit=crop&s=20b014e018d52163ec0156c852aa66eb"],
    ]
    
    var artistURI: String? = nil
    var identifiedArtist: String? = nil
    var baseURL = "https://api.clarifai.com"
    var modelID = "e466caa0619f444ab97497640cefc4dc"
    var version = "2ba4d0b0e53043f38dbbed49e03917b6"
    
    var searchCancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        SpotifyAPICaller.client.authorize()
        
        var iter = 0
        // Configuring images
        for image in collection {
            
            // Setting the ability of each image to be tapped on
            image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onImageTap)))
            image.isUserInteractionEnabled = true
            
            // Setting the artist image for each image
            let artist_url = artists[iter][1]
            let url = URL(string: artist_url)
            image.roundedImage()
            image.af.setImage(withURL: url!)
            
            // increment iterator for array of image URLs
            iter = iter + 1
        }
    }
    
    func identifyArtist(for stringUrl: String!, group: DispatchGroup) {
        let parameters: Parameters = [
            "inputs": [
                [
                    "data": [
                        "image": [
                            "url": "\(stringUrl!)"
                        ]
                    ]
                ]
            ]
        ]
        let url = URL(string: "\(baseURL)/v2/models/\(modelID)/versions/\(version)/outputs")
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Key \(ProcessInfo.processInfo.environment["clarifai_api_key"]!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        AF.request(request)
            .responseJSON { response in
                let dataDictionary = try! JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : Any]
                let outputs = dataDictionary["outputs"] as! [[String : Any]]
                let outputData = outputs[0]["data"] as! [String : Any]
                let regions = outputData["regions"] as! [[String : Any]]
                let regionsData = regions[0]["data"] as! [String : Any]
                let dataConcepts = regionsData["concepts"] as! [[String : Any]]
                self.identifiedArtist = dataConcepts[0]["name"]! as? String
                
                group.leave()
            }
    }
    
    @IBAction func unwindToArtists(_ unwindSegue: UIStoryboardSegue) {}
    
    @objc func onImageTap(_ sender: UITapGestureRecognizer) {
        // Perform on tap functionality here
        let artistImage = sender.view as! UIImageView
        let artist_idx = artistImage.tag - 1
        let artist_url = artists[artist_idx][1]
        
        let group = DispatchGroup()
        group.enter()
        
        // facial recognition
        identifyArtist(for: artist_url, group: group)
        
        // Get artist info after identifying picture
        group.notify(queue: .main) {
            SpotifyAPICaller.client.api.search(query: self.identifiedArtist!, categories: [.artist])
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    print(completion)
                }, receiveValue: {[weak self] (results) in
                    let artist = results.artists!.items.first!
                    self?.artistURI = artist.uri!
                    self?.performSegue(withIdentifier: "toAlbumView", sender: self)
                    print("artist search successful")
                })
                .store(in: &self.searchCancellables)
        }
    }
    
    // MARK - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let albumGridViewController = segue.destination as? AlbumGridViewController {
            albumGridViewController.artistURI = artistURI ?? "no URI"
        }
    }

}
