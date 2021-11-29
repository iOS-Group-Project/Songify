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
        loadAlbums()
    }
    
    // MARK: - Custom Methods
//    @IBAction func unwindToAlbums(sender: UIStoryboardSegue) {
//    }
//    
//    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
//        let segue = UnwindSlideIn(identifier: unwindSegue.identifier, source: unwindSegue.source, destination: unwindSegue.destination)
//        
//        segue.perform()
//    }
    
    func loadAlbums() {
        SpotifyAPICaller.client.api.artistAlbums(artistURI, limit: 10)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { results in
                self.albums = results.items
                self.albumView.reloadData()
                print("albums fetched successfully")
            })
            .store(in: &albumCancellables)
    }
    
    // MARK: - Grid Collection Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumViewCell", for: indexPath) as! AlbumViewCell

        let album = albums[indexPath.item]
        let album_url = album.images?[1].url
        let album_name = album.name

        cell.albumPoster.af.setImage(withURL: album_url!)
        cell.albumName.text = album_name

        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let trackListViewController = segue.destination as? TrackListViewController {
            let cell = sender as! UICollectionViewCell
            let indexPath = albumView.indexPath(for: cell)
            let album = albums[indexPath!.row]

            trackListViewController.album = album

            albumView.deselectItem(at: indexPath!, animated: true)
        }
        else {
            print("dismissing view")
        }
    }

}
