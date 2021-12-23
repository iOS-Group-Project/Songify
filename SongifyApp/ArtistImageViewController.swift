//
//  ArtistImageViewController.swift
//  Songify
//
//  Created by Matthew Piedra on 11/13/21.
//

import UIKit
import AlamofireImage
import Alamofire
import MBProgressHUD

class ArtistImageViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var collection: [UIImageView]!
    @IBOutlet weak var urlTextView: UITextField!
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    
    var artistID: String? = nil
    var identifiedArtist: String? = nil
    var searchedUrl: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        SpotifyAPICaller.client.authorize()
        
        urlTextView.delegate = self
        
        if let url = UserDefaults.standard.string(forKey: "searchedUrl") {
            urlTextView.text = url
            
            artistImage.af.setImage(withURL: URL(string: url)!)

            self.artistImage.roundedImage()
            self.submitButton.layer.cornerRadius = 5
            self.searchedUrl = url
        }
        else {
            self.artistImage.isHidden = true
            self.submitButton.isHidden = true
        }
        
        urlTextView.clipsToBounds = true
        if #available(iOS 13.0, *) {
            urlTextView.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
            urlTextView.layer.borderWidth = 1
            urlTextView.layer.cornerRadius = 8
        }
    }
    
    func validateUrl(url: String) -> Bool {
        let regex = "http[s]?://(([^/:.[:space:]]+(.[^/:.[:space:]]+)*)|([0-9](.[0-9]{3})))(:[0-9]+)?((/[^?#[:space:]]+)([^#[:space:]]+)?(#.+)?)?"
        let test = NSPredicate(format:"SELF MATCHES %@", regex)
        let result = test.evaluate(with: url)
        return result
    }
    
    // Implement the delay method
    func run(after wait: TimeInterval, closure: @escaping () -> Void) {
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // populate ui image based on passed in url
        if textField.text?.isEmpty == false {
            let url = urlTextView.text
            
            if validateUrl(url: url!) {
                artistImage.af.setImage(withURL: URL(string: url!)!)
                
                MBProgressHUD.showAdded(to: self.view, animated: true)
                
                run(after: 1) {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    if self.artistImage.image != nil {
                        self.artistImage.isHidden = false
                        self.artistImage.roundedImage()
                        self.submitButton.isHidden = false
                        self.submitButton.layer.cornerRadius = 5
                        self.searchedUrl = url!
                        
                        UserDefaults.standard.set(url!, forKey: "searchedUrl")
                    }
                    else {
                        let alertController = UIAlertController.init(title: "No Image Found", message: "Couldn't process image from URL", preferredStyle: .alert)
                        
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            else {
                let alertController = UIAlertController.init(title: "Invalid URL", message: "Typed in text is not a valid URL", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
            
            return true
        }
        else {
            let alertController = UIAlertController.init(title: "Empty URL", message: "Please enter a URL to proceed", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
            return false
        }
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        // identify artist from image ...
        let group = DispatchGroup()
        group.enter()

        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        // facial recognition
        identifyArtistByUrl(for: self.searchedUrl, group: group)

        // Get artist info after identifying picture
        
        group.notify(queue: .main) {
            let artist_name = self.identifiedArtist!
            let artist_category = IDCategories.artist.rawValue
            
            SpotifyAPICaller.client.search(query: artist_name, type: [artist_category]) { (res) in
                    let artists = res["artists"] as! [String: Any]
                    
                    let items = artists["items"] as! [[String:Any]]
                    
                    let artistID = items.first!["id"]
                
                    self.artistID = artistID as? String
                    
                    self.performSegue(withIdentifier: "toAlbumView", sender: self)
                    
                    print("artist search successful")
                    
                    MBProgressHUD.hide(for: self.view, animated: true)
                } failure: { (error) in
                    print(error)
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
        }
    }
    
    func identifyArtistByUrl(for stringUrl: String!, group: DispatchGroup) {
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
        let url = URL(string: "\(clarifaiBaseURL)/v2/models/\(modelID)/versions/\(model_version)/outputs")
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Key \(ClarifaiKeys.clarifai_api_key)", forHTTPHeaderField: "Authorization")
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
    
    // MARK - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let albumGridViewController = segue.destination as? AlbumGridViewController {
            albumGridViewController.artistID = artistID ?? "no URI"
        }
    }
}
