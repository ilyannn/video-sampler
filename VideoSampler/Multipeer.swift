//
//  Multipeer.swift
//  VideoSampler
//
//  Created by Ilya Nikokoshev on 28/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import MultipeerConnectivity

protocol MultipeerServiceDelegate: NSObjectProtocol {
    func collectionCompleted(collection: ImageCollection, by: MultipeerService)
}

private let ServiceType = "video-sampler"

private func MyDisplayName() -> String {
    #if os(iOS)        
        return UIDevice.currentDevice().name
    #else
        return "Mac"
    #endif
}

class MultipeerService: NSObject {

    weak var delegate: MultipeerServiceDelegate?
    
    private let multiSession: MCSession    
    private var peerIDs: [MCPeerID] = []
    private var advertiserAss: MCAdvertiserAssistant 
            
    private var collectedData: [MCPeerID: ImageCollection] = [:]
    
    override init() {
        multiSession = MCSession(peer: MCPeerID(displayName: MyDisplayName()))
        advertiserAss = MCAdvertiserAssistant(serviceType: ServiceType, discoveryInfo: nil, session: multiSession)
        
        super.init()
        
        multiSession.delegate = self        
        advertiserAss.start()
    }
    
    func browserViewController() -> MCBrowserViewController {
        return MCBrowserViewController(serviceType: ServiceType, session: multiSession)
    }
    
    // Use @autoclosure to avoid costly data creation is not necessary
    func send(@autoclosure data factory: ()-> NSData) {
        let peers = multiSession.connectedPeers
        if peers.count == 0 {
            return
        }
        
        let data = factory()
        var error: NSError?
        multiSession.sendData(data, toPeers: peers, withMode: .Reliable, error: &error)
        if let problem = error {
            println("Problem sending data: \(problem)")
        }
    }
    
}

extension MultipeerService: MCSessionDelegate {
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        println("peer \(peerID) state = \(state.rawValue)")
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        println("Received \(data.length) bytes of data from \(peerID.displayName)")
        
        var collection = collectedData[peerID]  // existing or new
            ?? (ImageCollection() ⨁ { collectedData[peerID] = $0 })
        
        collection.collect(data: data)
        
        if collection.completed {
            collectedData[peerID] = nil
            delegate?.collectionCompleted(collection, by: self)
        }
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
}
