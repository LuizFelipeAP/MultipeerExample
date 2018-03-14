//
//  SlaveViewController.swift
//  Multipeer
//
//  Created by Luiz Felipe Albernaz Pio on 13/03/18.
//  Copyright © 2018 Luiz Felipe Albernaz Pio. All rights reserved.
//

import UIKit

class SlaveViewController: UIViewController {

    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ConnectionManager.shared.lostMaster = { 
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressConnect(button: UIButton) {
        self.connectButton.isEnabled = false
        self.disconnectButton.isEnabled = true
        
        ConnectionManager.shared.startSearchingForMaster()
        
    }
    
    @IBAction func didPressDisconnect(button: UIButton) {
        ConnectionManager.shared.slaveOut()
        self.dismiss(animated: true, completion: nil)
        
    }
}
