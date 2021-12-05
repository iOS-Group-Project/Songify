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
import MBProgressHUD

class TrackListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var totalTracks: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var tracks = [Track]()
    var album: Album? = nil
    
    var trackCancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        
        let album_name = album?.name
        let artists = album?.artists
        let album_poster_url = album?.images?[1].url
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let rd = df.string(from: (album?.releaseDate)!)
        releaseDate.text = rd
        albumName.text = album_name
        artistName.text = artists?[0].name
        for i in 1..<artists!.count {
            let artist = artists?[i]
            artistName.text! += ", \(artist?.name ?? "")"
        }
        albumImage.af.setImage(withURL: album_poster_url!)
        
        loadTracks()
    }
    
    // MARK: - Custom Methods
    func loadTracks() {
        let album_uri = album?.uri
        
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        SpotifyAPICaller.client.api.albumTracks(album_uri!, limit: 50)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { results in
                self.tracks = results.items
                var msg = ""
                if self.tracks.count == 1 {
                    msg = "\(self.tracks.count) song ·"
                }
                else {
                    msg = "\(self.tracks.count) songs ·"
                }
                self.totalTracks.text = msg
                self.tableView.reloadData()
                MBProgressHUD.hide(for: self.view, animated: true)
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
        let track_artists = track.artists

        cell.trackNumber.text = String(trackNumber)
        cell.trackName.text = track_name
        cell.artistName.text = track_artists?[0].name
        for i in 1..<track_artists!.count {
            let track_artist = track_artists?[i]
            cell.artistName.text! += ", \(track_artist!.name)"
        }
        
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
