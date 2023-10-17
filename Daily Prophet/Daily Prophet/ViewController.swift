//
//  ViewController.swift
//  Daily Prophet
//
//  Created by Mufrat Karim Aritra on 10/11/23.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var activeVideoNodes: [SKVideoNode] = []
    var videoNodes: [UUID: SKVideoNode] = [:] // Added dictionary
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        if let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "news", bundle: Bundle.main) {
            configuration.trackingImages = trackedImages
            configuration.maximumNumberOfTrackedImages = 4
            
        }
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        DispatchQueue.main.async {
            if let imageAnchor = anchor as? ARImageAnchor {
                self.activeVideoNodes.forEach { $0.pause() }
                self.activeVideoNodes.removeAll()
                
                if let imageName =  imageAnchor.referenceImage.name?.capitalized {
                    let imageSize =  imageAnchor.referenceImage.physicalSize
                    print("\(imageName).mp4")
                    let videoNode = SKVideoNode(fileNamed: "\(imageName).mp4")
                    videoNode.play()
                    
                    self.activeVideoNodes.append(videoNode)
                    self.videoNodes[imageAnchor.identifier] = videoNode // Save the node for later
                    
                    let videoScene = SKScene(size: CGSize(width: 1920, height: 1080))
                    videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
                    videoNode.yScale = -1.0
                    videoScene.addChild(videoNode)
                    
                    let plane = SCNPlane(width: imageSize.width, height: imageSize.height)
                    plane.firstMaterial?.diffuse.contents = videoScene
                    
                    let planeNode = SCNNode(geometry: plane)
                    planeNode.eulerAngles.x = -.pi / 2
                    node.addChildNode(planeNode)
                }
            }
        }
        return node
    }
    
    // Added to handle video pausing when out of scope
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        DispatchQueue.main.async {
            if let videoNode = self.videoNodes[imageAnchor.identifier] {
                if imageAnchor.isTracked {
                    videoNode.play()
                } else {
                    videoNode.pause()
                }
            }
        }
    }
    
    
    
}
