//
//  ConnectionManager.swift
//  Multipeer
//
//  Created by Luiz Felipe Albernaz Pio on 13/03/18.
//  Copyright © 2018 Luiz Felipe Albernaz Pio. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ConnectionManager: NSObject {
    
    struct Defines {
        //Identifiers
        static let masterID = "MASTER_ID"
        static let slaveID = "SLAVE_ID"
        static let idKey = "ID"
        
        static let serviceType = "test-mpc"
    }
    
    static var shared: ConnectionManager = {
        return ConnectionManager()
    }()
    
    var serviceAdvertiser: MCNearbyServiceAdvertiser?
    var serviceBrowser: MCNearbyServiceBrowser?
    
    let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    lazy var session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: .required)
    
    var sessions: [MCSession] = []
    var peerUUIDs: [MCPeerID: String] = [:]
    
    var peerDidConnect: ((String?, String) -> ())?
    var peerDidDisconnect: ((String?) -> ())?
    var lostMaster: (() -> ())?

    var deviceName: String {
        return UIDevice.current.name
    }
    
    var isMaster: Bool {
        return self.serviceAdvertiser?.discoveryInfo?[Defines.idKey] == Defines.masterID
    }
    
    func newSession() -> MCSession {
        let session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }
}

//**************************************************************************************
//
// MARK: - Methods Extension
//
//**************************************************************************************
extension ConnectionManager {
    
    func startBeingMaster() {
        
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: self.myPeerID, discoveryInfo: [Defines.idKey: Defines.masterID], serviceType: Defines.serviceType)
        self.serviceAdvertiser?.delegate = self
        
        self.serviceAdvertiser?.startAdvertisingPeer()
        
    }
    
    func startSearchingForMaster() {

        self.serviceBrowser = MCNearbyServiceBrowser(peer: self.myPeerID, serviceType: Defines.serviceType)
        self.serviceBrowser?.delegate = self
        self.serviceBrowser?.startBrowsingForPeers()
        
    }
    
    func masterOut() {
        
        self.session.disconnect()
        self.sessions.forEach {
            $0.disconnect()
        }
        self.sessions = []
        self.peerUUIDs = [:]
    }
    
    func slaveOut() {
        self.session.disconnect()
        self.serviceBrowser?.stopBrowsingForPeers()
    }
}

extension ConnectionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Receiving Invite from:\(peerID.displayName)")
        
        if self.isMaster {
            
            let newSession = self.newSession()
                
            self.sessions.append(newSession)
            
            if let context = context {
                if let id = String(data: context, encoding: .utf8) {
                    self.peerUUIDs[peerID] = id
                }
            }
            
            invitationHandler(true, newSession)
        }
    }
    
}

extension ConnectionManager: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        print("Found \(peerID.displayName)")
        
        if info?[Defines.idKey] == Defines.masterID {
        
            self.session = newSession()
        
            browser.invitePeer(peerID, to: self.session, withContext: applicationUUID.data(using: .utf8), timeout: 10)
        
            self.serviceBrowser?.stopBrowsingForPeers()
        }
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost: \(peerID.displayName)")
    }
}

extension ConnectionManager: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        print("State changed to: \(state == .connected ? "Connected" : state == .connecting ? "Connecting" : "NotConnected")")
        
        switch state {
        case .connected:
            if self.isMaster {
                self.peerDidConnect?(self.peerUUIDs[peerID], peerID.displayName)
            }
        case .notConnected:
            
            if self.isMaster {
                if let index = self.sessions.index(of: session) {
                    self.sessions.remove(at: index)
                    session.disconnect()
                
                }
                
                self.peerDidDisconnect?(peerUUIDs[peerID])
                self.peerUUIDs.removeValue(forKey: peerID)
                
            } else {
                self.lostMaster?()
            }
            
        default: break
        }
    }
    
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
    }
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }

    
}
