//
//  NewArtistViewController.swift
//  Songify
//
//  Created by Matthew Piedra on 12/5/21.
//

import UIKit

class NewArtistViewController: UIViewController {
    
    @IBOutlet weak var pastedUrl: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        if pastedUrl.text != "" {
            var arr = UserDefaults.standard.stringArray(forKey: "artistUrls")
            arr?.append(pastedUrl.text!)
            UserDefaults.standard.set(arr, forKey: "artistUrls")
            
            self.dismiss(animated: true, completion: nil)
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
