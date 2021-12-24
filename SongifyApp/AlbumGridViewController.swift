//
//  AlbumGridViewController.swift
//  Songify
//
//  Created by Matthew Piedra on 11/19/21.
//

import UIKit
import AlamofireImage
import MBProgressHUD

class AlbumGridViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var albumView: UICollectionView!
    @IBOutlet var emptyAlbums: UIView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var artistID = String()
    var albums: [[String:Any]] = {
        let albums_data = SpotifyAPIData.shared.albums
        return albums_data
    }()
    var filteredAlbums = [[String:Any]]()
    var offset = Int()
    var favorites = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        albumView.delegate = self
        albumView.dataSource = self

        // Do any additional setup after loading the view.
        
        let layout = albumView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4

        let width = (view.frame.size.width - layout.minimumInteritemSpacing * 2) / 2
        let height = width * 2 / 2
        layout.itemSize = CGSize(width: width, height: height)
        
        // get albums from spotify api based on artist's uri
        
        if albums.isEmpty {
            loadAlbums()
        }
        initSearchController()
    }

    // MARK: - Custom Methods
    func loadAlbums() {
        self.offset = 0
        
        let albums = AlbumGroups.album.rawValue
        let appearsOn = AlbumGroups.appearsOn.rawValue
        let singles = AlbumGroups.single.rawValue
        let compilation = AlbumGroups.compilation.rawValue
        
        let groups = [
            "Albums": albums,
            "Appears": appearsOn,
            "Singles": singles,
            "Comps": compilation
        ] as [String : Any]
        
        let selectedGroup = UserDefaults.standard.string(forKey: "albumGroup")!
        
        var wantsAll = false
        var group: String!
        
        if selectedGroup == "All" {
            wantsAll = true
        }
        else {
            group = groups[selectedGroup] as? String
        }
        
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        SpotifyAPICaller.client.artistAlbums(artist: self.artistID, groups: wantsAll == false ? [group] : [albums, singles, appearsOn, compilation], limit: 50, offset: self.offset) { (res) in
            let finalResult: [[String:Any]]
            let sortByAlphabet = UserDefaults.standard.bool(forKey: "sortByAlphabet")
            
            if sortByAlphabet {
                finalResult = (res["items"] as! [[String:Any]]).sorted(by: { (first, second) in
                    let curr_name = first["name"] as! String
                    let next_name = second["name"] as! String
                    return curr_name < next_name
                })
            }
            else {
                finalResult = res["items"] as! [[String:Any]]
            }
            
            self.albums = finalResult
            self.filteredAlbums = finalResult
            SpotifyAPIData.shared.albums = finalResult
            
            if self.albums.count == 0 {
                self.albumView.backgroundView = self.emptyAlbums
            }
            else {
                self.albumView.reloadData()
            }
            
            print("albums fetched successfully")
            MBProgressHUD.hide(for: self.view, animated: true)
        } failure: { (error) in
            print(error)
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func loadMoreAlbums() {
        self.offset = self.offset + 50
        
        let albums = AlbumGroups.album.rawValue
        let appearsOn = AlbumGroups.appearsOn.rawValue
        let singles = AlbumGroups.single.rawValue
        let compilation = AlbumGroups.compilation.rawValue
        
        let groups = [
            "Albums": albums,
            "Appears": appearsOn,
            "Singles": singles,
            "Comps": compilation
        ] as [String : Any]
        
        let selectedGroup = UserDefaults.standard.string(forKey: "albumGroup")!
        
        var wantsAll = false
        var group: String!
        
        if selectedGroup == "All" {
            wantsAll = true
        }
        else {
            group = groups[selectedGroup] as? String
        }
        
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        SpotifyAPICaller.client.artistAlbums(artist: self.artistID, groups: wantsAll == false ? [group] : [albums, singles, appearsOn, compilation], limit: 50, offset: self.offset) { (res) in
            let finalResult: [[String:Any]]
            let sortByAlphabet = UserDefaults.standard.bool(forKey: "sortByAlphabet")
            
            if sortByAlphabet {
                finalResult = (res["items"] as! [[String:Any]]).sorted(by: { (first, second) in
                    let curr_name = first["name"] as! String
                    let next_name = second["name"] as! String
                    return curr_name < next_name
                })
            }
            else {
                finalResult = res["items"] as! [[String:Any]]
            }
            
            if finalResult.count != 0 {
                for album in finalResult {
                    self.albums.append(album)
                    self.filteredAlbums.append(album)
                    SpotifyAPIData.shared.albums.append(album)
                }
                
                self.albumView.reloadData()
            }
            
            print("albums fetched successfully")
            MBProgressHUD.hide(for: self.view, animated: true)
        } failure: { (error) in
            print(error)
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func initSearchController() {
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.searchTextField.backgroundColor = .white
        searchController.searchBar.sizeToFit()
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchBar.delegate = self
        
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let searchText = searchBar.text
        
        filterForSearchTextAndScopeButton(analyze: searchText)
    }
    
    func filterForSearchTextAndScopeButton(analyze searchText: String!) {
        filteredAlbums = albums.filter({ (album) in
            if searchText != "" {
                let album_name = album["name"] as! String
                let searchTextMatch = album_name.lowercased().contains(searchText.lowercased())
                return searchTextMatch
            }
            return true
        })

        if filteredAlbums.count == 0 {
            albumView.backgroundView = emptyAlbums
        }
        else {
            albumView.backgroundView = nil
        }

        albumView.reloadData()
    }
    
    // MARK: - Grid Collection Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredAlbums.count
        }
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row + 1 == albums.count {
            loadMoreAlbums()
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumViewCell", for: indexPath) as! AlbumViewCell

        let album: [String:Any]!
        
        if searchController.isActive {
            album = filteredAlbums[indexPath.item]
        }
        else {
            album = albums[indexPath.item]
        }
        
        let album_images = album["images"] as! [[String:Any]]
        let album_url_path = album_images[1]["url"] as! String
        let album_url = URL(string: album_url_path)

        cell.albumPoster.af.setImage(withURL: album_url!)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) {[weak self] _ in
            
            let open = UIAction(title: "Open", image: UIImage(systemName: "link"), identifier: nil, discoverabilityTitle: nil, state: .off) {[weak self] _ in
                // open detail view of outlet
                let cell = self?.albumView.cellForItem(at: indexPath)
                self?.performSegue(withIdentifier: "toTrackView", sender: cell)
            }
            
            let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up"), identifier: nil, discoverabilityTitle: nil, state: .off) { _ in
                // share to social outlets
                print("shared")
            }
            
            let favorite = UIAction(title: self?.favorites.contains(indexPath.row) == true ? "Remove Favorite" : "Favorite", image: self?.favorites.contains(indexPath.row) == true ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart"), identifier: nil, discoverabilityTitle: nil, state: .off) {[weak self] _ in
                if self?.favorites.contains(indexPath.row) == true {
                    self?.favorites.removeAll(where: { $0 == indexPath.row })
                }
                else {
                    self?.favorites.append(indexPath.row)
                }
            }
            
            let copy = UIAction(title: "Copy", image: UIImage(systemName: "paperclip"), identifier: nil, discoverabilityTitle: nil, state: .off) {[weak self] _ in
                // copy album name to clipboard
                let pasteBoard = UIPasteboard.general
                let album: [String:Any]!

                if self?.searchController.isActive == true {
                    album = self?.filteredAlbums[indexPath.row]
                }
                else {
                    album = self?.albums[indexPath.row]
                }
                let externalURL = album["external_urls"] as! [String:Any]
                let spotify_url = externalURL["spotify"] as! String
                pasteBoard.string = spotify_url
            }
            
            return UIMenu(
                title: "",
                image: nil,
                identifier: nil,
                options: .displayInline,
                children: [open, favorite, copy, share]
            )
        }
        
        return config
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let trackListViewController = segue.destination as! TrackListViewController

        let cell = sender as! UICollectionViewCell
        let indexPath = albumView.indexPath(for: cell)

        let album: [String:Any]!

        if searchController.isActive {
            album = filteredAlbums[indexPath!.row]
        }
        else {
            album = albums[indexPath!.row]
        }

        trackListViewController.album = album

        albumView.deselectItem(at: indexPath!, animated: true)
    }

}

