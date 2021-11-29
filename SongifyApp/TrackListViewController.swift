//
//  TrackListViewController.swift
//  Songify
//
//  Created by Matthew Piedra on 11/27/21.
//

import UIKit
import SpotifyWebAPI
import AlamofireImage
import Combine

class TrackListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var tracks = [Track]()
    var album: Album? = nil
    
    var trackCancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        let album_name = album?.name
        let artist = album?.artists![0].name
        let album_poster_url = album?.images?[1].url

        albumName.text = album_name
        artistName.text = artist
        albumImage.af.setImage(withURL: album_poster_url!)
        
        loadTracks()
    }
    
    // MARK: - Custom Methods
    func loadTracks() {
        let album_uri = album?.uri
        
        SpotifyAPICaller.client.api.albumTracks(album_uri!, limit: 50)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { results in
                self.tracks = results.items
                self.tableView.reloadData()
                print("tracks fetched successfully")
            })
            .store(in: &trackCancellables)
    }
    
    // MARK: - Table View Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        let track = tracks[indexPath.row]

        let trackNumber = indexPath.row + 1
        let track_name = track.name
        let tracK_artist = track.artists?[0].name

        cell.trackNumber.text = String(trackNumber)
        cell.trackName.text = track_name
        cell.artistName.text = tracK_artist
        
        return cell
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
