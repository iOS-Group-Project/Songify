//
//  AlbumGridViewController.swift
//  Songify
//
//  Created by Matthew Piedra on 11/19/21.
//

import UIKit
import AlamofireImage
import SpotifyWebAPI
import Combine
import SpotifyExampleContent

class AlbumGridViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var albumView: UICollectionView!
    
    var artistURI = String()
    var albums = [Album]()
    
    var albumCancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        albumView.delegate = self
        albumView.dataSource = self

        // Do any additional setup after loading the view.
        
        let layout = albumView.collectionViewLayout as! UICollectionViewFlowLayout

        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4

        let width = (view.frame.size.width - layout.minimumInteritemSpacing * 2) / 2
        let height = width * 3 / 2
        layout.itemSize = CGSize(width: width, height: height)
        
        // get albums from spotify api based on artist's uri
        SpotifyAPICaller.client.api.artistAlbums(artistURI, limit: 20)
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { results in
                //let artist = results.artists!.items.first!
               // self.artistURI = artist.uri

                //print(results.items.first?.images?.first?.url)
                self.albums = results.items
            })
            .store(in: &albumCancellables)
        
    }
    
    // MARK: - Custom Methods
    @IBAction func backToHome(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Grid Collection Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieGridCell", for: indexPath) as! MovieGridCell
//
//        let album = albums[indexPath.item]
//        //Set up to get the movie poster to display
//        let baseUrl = "https://image.tmdb.org/t/p/w185"
//        let posterPath = movie["poster_path"] as! String
//        let posterUrl = URL(string: baseUrl + posterPath)
//
//        cell.posterView.af.setImage(withURL: posterUrl!)
//
//
//        return cell
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // configure cell
        print(albums.count)
        
    if albums.count == 0 {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumViewCell", for: indexPath) as! AlbumViewCell
        
        //print(albums)
        
        // Dummy image data; replace this with actual album image fetched from API
        let album_url = "https://api.spotify.com/v1/artists/"
        let url = URL(string: album_url)
        cell.albumPoster.af.setImage(withURL: url!)
        
        return cell
        }
        else {
            
            let album = albums[indexPath.item]
            print(album)
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumViewCell", for: indexPath) as! AlbumViewCell
            
            //print(albums)
            
            // Dummy image data; replace this with actual album image fetched from API
            let album_url = album.images?[1].url
            //let url = URL(string: album_url)
            cell.albumPoster.af.setImage(withURL: album_url!)
            cell.albumName.text = album.name
            
            return cell
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
