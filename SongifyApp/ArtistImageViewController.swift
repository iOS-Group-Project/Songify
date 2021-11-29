//
//  ArtistImageViewController.swift
//  Songify
//
//  Created by Matthew Piedra on 11/13/21.
//

import UIKit
import AlamofireImage
import SpotifyWebAPI
import Combine

class ArtistImageViewController: UIViewController {
    
    @IBOutlet var collection: [UIImageView]!
    
    var artists: [[String]] = [
        ["Kanye West", "https://upload.wikimedia.org/wikipedia/commons/thumb/1/10/Kanye_West_at_the_2009_Tribeca_Film_Festival_%28cropped%29.jpg/1200px-Kanye_West_at_the_2009_Tribeca_Film_Festival_%28cropped%29.jpg"],
        ["Dua Lipa", "https://m.media-amazon.com/images/M/MV5BOWRiMzRlZGUtNjA1Zi00OGJlLTg3Y2QtYjQ3MDNhOTQ1OWVjXkEyXkFqcGdeQXVyODY0NzcxNw@@._V1_UY1200_CR85,0,630,1200_AL_.jpg"],
        ["Eminem",
            "https://www.biography.com/.image/t_share/MTQ3NjM5MTEzMTc5MjEwODI2/eminem_photo_by_dave_j_hogan_getty_images_entertainment_getty_187596325.jpg"],
        ["Ariana Grande",
            "https://www.biography.com/.image/t_share/MTQ3MzM3MTcxNjA5NTkzNjQ3/ariana_grande_photo_jon_kopaloff_getty_images_465687098.jpg"],
        ["Ed Sheeran",
            "https://static01.nyt.com/images/2021/10/29/arts/29sheeran-review/29sheeran-review-mediumSquareAt3X.jpg"],
        ["Drake",
            "https://www.biography.com/.image/ar_1:1%2Cc_fill%2Ccs_srgb%2Cfl_progressive%2Cq_auto:good%2Cw_1200/MTQ3NTI2OTA4NzY5MjE2MTI4/drake_photo_by_prince_williams_wireimage_getty_479503454.jpg"],
        ["The Weeknd",
            "https://image-cdn.hypb.st/https%3A%2F%2Fhypebeast.com%2Fimage%2F2021%2F09%2Fthe-weeknd-cant-feel-my-face-alternate-music-video-beauty-behind-the-madness-sixth-anniversary-tw.jpg?w=960&cbr=1&q=90&fit=max"],
        ["Justin Bieber",
            "https://www.biography.com/.image/t_share/MTM2OTI2NTY2Mjg5NTE2MTI5/justin_bieber_2015_photo_courtesy_dfree_shutterstock_348418241_croppedjpg.jpg"],
        ["Billie Ellish",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Billie_Eilish_2019_by_Glenn_Francis_%28cropped%29_2.jpg/1200px-Billie_Eilish_2019_by_Glenn_Francis_%28cropped%29_2.jpg"],
    ]
    
    var artistURI: String? = nil
    
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
    
    @IBAction func unwindToArtists(_ unwindSegue: UIStoryboardSegue) {}
    
    @objc func onImageTap(_ sender: UITapGestureRecognizer) {
        // Perform on tap functionality here
        let artistImage = sender.view as! UIImageView
        let artist_idx = artistImage.tag - 1
        let artist_name = artists[artist_idx][0]
        
        SpotifyAPICaller.client.api.search(query: artist_name, categories: [.artist])
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: {[weak self] (results) in
                let artist = results.artists!.items.first!
                self?.artistURI = artist.uri!
                self?.performSegue(withIdentifier: "toAlbumView", sender: self)
                print("artist search successful")
            })
            .store(in: &searchCancellables)
    }
    
    // MARK - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let albumGridViewController = segue.destination as! AlbumGridViewController
        
        albumGridViewController.artistURI = artistURI ?? "no URI"
    }

}
