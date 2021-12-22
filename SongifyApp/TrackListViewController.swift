//
//  TrackListViewController.swift
//  Songify
//
//  Created by Matthew Piedra on 11/27/21.
//

import UIKit
import AlamofireImage
import MBProgressHUD

class TrackListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var totalTracks: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var tracks = [[String:Any]]()
    var album = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        
        let album_name = album["name"] as! String
        let artists = album["artists"] as! [[String:Any]]
        let album_images = album["images"] as! [[String:Any]]
        let album_poster_url = album_images[1]["url"] as! String
        
        releaseDate.text = album["release_date"] as? String
        albumName.text = album_name
        artistName.text = artists[0]["name"] as? String
        for i in 1..<artists.count {
            let artist = artists[i]
            artistName.text! += ", \(artist["name"] as! String)"
        }
        albumImage.af.setImage(withURL: URL(string: album_poster_url)!)
        
        loadTracks()
    }
    
    // MARK: - Custom Methods
    func loadTracks() {
        let album_id = album["id"] as! String
        
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        SpotifyAPICaller.client.albumsTracks(album: album_id, limit: 50) { (res) in
            self.tracks = res["items"] as! [[String:Any]]
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
        } failure: { (error) in
            print(error)
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    // MARK: - Table View Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        let track = tracks[indexPath.row]

        let trackNumber = indexPath.row + 1
        let track_name = track["name"] as! String
        let track_artists = track["artists"] as! [[String:Any]]

        cell.trackNumber.text = String(trackNumber)
        cell.trackName.text = track_name
        cell.artistName.text = track_artists[0]["name"] as? String
        for i in 1..<track_artists.count {
            let track_artist = track_artists[i]
            cell.artistName.text! += ", \(track_artist["name"] as! String)"
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
