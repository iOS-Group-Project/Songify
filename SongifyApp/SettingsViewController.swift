//
//  SettingsViewController.swift
//  Songify
//
//  Created by Matthew Piedra on 12/2/21.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var groupSegment: UISegmentedControl!
    @IBOutlet weak var alphabetToggle: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additiona!l setup after loading the view.
        let selectedSegIdx = UserDefaults.standard.integer(forKey: "selectedSegIdx")
        let sortByAlphabet = UserDefaults.standard.bool(forKey: "sortByAlphabet")
        
        groupSegment.selectedSegmentIndex = selectedSegIdx
        alphabetToggle.isOn = sortByAlphabet
    }
    
    @IBAction func selectedGroup(_ sender: UISegmentedControl) {
        let idx = sender.selectedSegmentIndex
        let title = sender.titleForSegment(at: idx)
        UserDefaults.standard.set(idx, forKey: "selectedSegIdx")
        UserDefaults.standard.set(title, forKey: "albumGroup")
    }
    
    @IBAction func toggleAlphabet(_ sender: UISwitch) {
        // sender.isOn
        let isOn = sender.isOn
        UserDefaults.standard.set(isOn, forKey: "sortByAlphabet")
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
