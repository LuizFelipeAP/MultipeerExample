//
//  MasterViewController.swift
//  Multipeer
//
//  Created by Luiz Felipe Albernaz Pio on 13/03/18.
//  Copyright © 2018 Luiz Felipe Albernaz Pio. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {

    @IBOutlet weak var numOfDevicesConnectedLabel: UILabel!
    @IBOutlet weak var connectedDevicesLabel: UILabel!
    
    var peers: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ConnectionManager.shared.startBeingMaster()
        
        ConnectionManager.shared.peerDidConnect = { peerUUID, peerName in
            guard let peerKey = peerUUID else { return }
            self.peers[peerKey] = peerName
            
            self.updatePeersLabel()
        }
        
        ConnectionManager.shared.peerDidDisconnect = { peerUUID in
            
            guard let peerKey = peerUUID else { return }
            
            self.peers.removeValue(forKey: peerKey)
            
            self.updatePeersLabel()
        }
    }
    
    func updatePeersLabel() {
        DispatchQueue.main.async {
            self.numOfDevicesConnectedLabel.text = "Devices connected: \(self.peers.count)"
            self.connectedDevicesLabel.text = self.peers.values.reduce("") { $0 + " - \($1)" }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func stopConnection(_ button: UIButton) {
        ConnectionManager.shared.masterOut()
        self.dismiss(animated: true, completion: nil)
    }

}
