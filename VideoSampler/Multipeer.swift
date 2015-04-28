//
//  Multipeer.swift
//  VideoSampler
//
//  Created by Ilya Nikokoshev on 28/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import MultipeerConnectivity;

private let ServiceType = "video-sampler"

class MultipeerService: NSObject {

    private let multiSession: MCSession    
    private var peerIDs: [MCPeerID] = []
    private var advertiserAss: MCAdvertiserAssistant 
            
    override init() {
        multiSession = MCSession(peer: MCPeerID(displayName: UIDevice.currentDevice().name))
        advertiserAss = MCAdvertiserAssistant(serviceType: ServiceType, discoveryInfo: nil, session: multiSession)
        
        super.init()
        
        multiSession.delegate = self        
        advertiserAss.delegate = self                
        advertiserAss.start()
    }
    
    func browserViewController() -> MCBrowserViewController {
        return MCBrowserViewController(serviceType: ServiceType, session: multiSession)
    }
}


extension MultipeerService: MCSessionDelegate {
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        println("peer \(peerID) state = \(state)")
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
}

extension MultipeerService: MCAdvertiserAssistantDelegate {
    // all methods in the protocol are optional
}
