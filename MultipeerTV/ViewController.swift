//
//  ViewController.swift
//  MultipeerTV
//
//  Created by Luiz Felipe Albernaz Pio on 14/03/18.
//  Copyright © 2018 Luiz Felipe Albernaz Pio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var deviceConnectedLabel: UILabel!
    
    var peers: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ConnectionManager.shared.peerDidConnect = { peerUUID, peerName in
            
            guard let peerKey = peerUUID else { return }
            
            self.peers[peerKey] = peerName
            
            self.updateLabel()
        }
        
        ConnectionManager.shared.peerDidDisconnect = { peerUUID in
            guard let peerKey = peerUUID else { return }
            self.peers.removeValue(forKey: peerKey)
            
            self.updateLabel()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateLabel() {
        DispatchQueue.main.async {
            
            self.deviceConnectedLabel.text = self.peers.values.reduce("") { $0 + "- \($1)" }
            
        }
    }

    @IBAction func didPressAdvertiser(_ button: UIButton) {
        
        ConnectionManager.shared.startBeingMaster()
        button.isEnabled = false
    }
    
    
}

