//
//  AlbumGridViewController.swift
//  Songify
//
//  Created by Matthew Piedra on 11/19/21.
//

import UIKit
import AlamofireImage
import SpotifyWebAPI

class AlbumGridViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var albumView: UICollectionView!
    
    var artistURI = String()
    var albums = [Album]()
    
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
        
    }
    
    // MARK: - Custom Methods
    @IBAction func backToHome(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Grid Collection Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // configure cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumViewCell", for: indexPath) as! AlbumViewCell
        
        // Dummy image data; replace this with actual album image fetched from API
        let album_url = "https://upload.wikimedia.org/wikipedia/en/7/70/Graduation_%28album%29.jpg"
        let url = URL(string: album_url)
        cell.albumPoster.af.setImage(withURL: url!)
        
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
