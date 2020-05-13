//
//  ViewController.swift
//  ARPet
//
//  Created by Ricardo Rodriguez on 5/6/20.
//  Copyright © 2020 Ricardo Rodriguez. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit
import ARKit

class ViewController: UIViewController {

    
	var sceneView: ARSCNView {
        return self.view as! ARSCNView
    }
	var messageLabel: UILabel {
		return (self.view as! ARView).label
	}
	var crosshair: UIView {
		return (self.view as! ARView).crosshair
	}
	var debugPlanes: [SCNNode] = []
	var viewCenter: CGPoint {
		let viewBounds = view.bounds
		return CGPoint(x: viewBounds.width / 2.0, y: viewBounds.height / 2.0)
	}
	var isDogPlaced = false
	var dogNode: SCNNode? = nil
	var hearts: SCNNode? = nil
	var petScore: Int = 0
	
	override func loadView() {
        self.view = ARView(frame: .zero, options: nil)
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
		
		let scene = SCNScene()

        // Set the scene to the view
        sceneView.scene = scene
		sceneView.autoenablesDefaultLighting = true
		runSession()
		resetLabels()
		setupGestureRecognizers()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	func runSession() {
		let configuration = ARWorldTrackingConfiguration.init()
		configuration.planeDetection = .horizontal
		configuration.isLightEstimationEnabled = true
		sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

		#if DEBUG
		sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
		#endif
		sceneView.delegate = self
	}
	
	func resetLabels() {
		messageLabel.text = "Move the phone around and allow the app to find a plane." +
		"You will see a yellow horizontal plane."
	}
	
	func showMessage(_ message: String, label: UILabel, seconds: Double) {
		label.text = message
		
		DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
			if label.text == message {
				label.text = ""
				label.alpha = 0
			}
		}
	}
	
	func removeAllNodes() {
	  removeDebugPlanes()
	  self.dogNode?.removeFromParentNode()
	  self.isDogPlaced = false
	}
	
	func removeDebugPlanes() {
		for debugPlaneNode in self.debugPlanes {
			debugPlaneNode.removeFromParentNode()
		}
		
		self.debugPlanes = []
	}
	
	func makeDog() -> SCNNode {
		let dogScene = SCNScene(named: "art.scnassets/Dog.scn")
		let dog = dogScene?.rootNode.childNode(withName: "Dog", recursively: true)
		let hearts = dogScene?.rootNode.childNode(withName: "Hearts", recursively: true)
		self.hearts = hearts!
		self.hearts?.isHidden = true
		
		return dog!
	}

	func setupGestureRecognizers() {
		let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
		let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
		let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
		let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
		
		swipeLeft.direction = .left
		swipeUp.direction = .up
		swipeDown.direction	= .down

		//Add recognizer to sceneview
		sceneView.addGestureRecognizer(swipe)
		sceneView.addGestureRecognizer(swipeLeft)
		sceneView.addGestureRecognizer(swipeUp)
		sceneView.addGestureRecognizer(swipeDown)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let hit = sceneView.hitTest(viewCenter, types: [.existingPlaneUsingExtent]).first {
			sceneView.session.add(anchor: ARAnchor.init(transform: hit.worldTransform))
		}
	}
	
	

	//Method called when swipe gesture is recognized
	@objc func handleTap(rec: UISwipeGestureRecognizer){
		
		   if rec.state == .ended {
				let location: CGPoint = rec.location(in: sceneView)
				let hits = self.sceneView.hitTest(location, options: nil)
				if !hits.isEmpty{
					let tappedNode = hits.first?.node
					if tappedNode == self.dogNode {
						print("You pet the dog")
						let hearts = self.hearts?.copy() as! SCNNode
						self.dogNode?.addChildNode(hearts)
						hearts.isHidden = false
						petScore += 1
						DispatchQueue.main.async {
							self.messageLabel.text = "Pets given: \(self.petScore)"
						}
						DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
						   hearts.removeFromParentNode()
						}
					}
				}
		   }
	}


}

extension ViewController: ARSCNViewDelegate {
	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
		DispatchQueue.main.async {
			if let planeAnchor = anchor as? ARPlaneAnchor,
				!self.isDogPlaced {
				#if DEBUG
				let debugPlaneNode = createPlaneNode(
					center: planeAnchor.center,
					extent: planeAnchor.extent)
				node.addChildNode(debugPlaneNode)
				self.debugPlanes.append(debugPlaneNode)
				#endif
				self.messageLabel.text = """
				Tap on the detected \
				horizontal plane to place your dog
				"""
			}
			else if !self.isDogPlaced {
				self.dogNode = self.makeDog()
				if let dog = self.dogNode {
					node.addChildNode(dog)
					node.addChildNode(self.hearts!)
					node.eulerAngles.y = (self.sceneView.pointOfView?.eulerAngles.y)!
					
					self.isDogPlaced = true
					
					self.removeDebugPlanes()
					self.sceneView.debugOptions = []
					
					DispatchQueue.main.async {
						self.messageLabel.text = "Now pet your dog!"
						self.crosshair.isHidden = true
					}
				}
				
			}
		}
	}
	
	func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
		DispatchQueue.main.async {
			if let planeAnchor = anchor as? ARPlaneAnchor, node.childNodes.count > 0, !self.isDogPlaced {
				updatePlaneNode(node.childNodes[0], center: planeAnchor.center, extent: planeAnchor.extent)
			}
		}
	}
	
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
		
		DispatchQueue.main.async {
			if let _ = self.sceneView.hitTest(self.viewCenter,
											   types: [.existingPlaneUsingExtent]).first {
				self.crosshair.backgroundColor = UIColor.green
			} else {
				self.crosshair.backgroundColor = UIColor.lightGray
			}
		}
	}
	
	func session(_ session: ARSession, didFailWithError error: Error) {
		let label = self.messageLabel
		showMessage(error.localizedDescription, label: label, seconds: 3)
	}
	
	func sessionWasInterrupted(_ session: ARSession) {
		let label = self.messageLabel
		showMessage("Session interrupted", label: label, seconds: 3)
	}
	
	func sessionInterruptionEnded(_ session: ARSession) {
		let label = self.messageLabel
		showMessage("Session resumed", label: label, seconds: 3)
		
		DispatchQueue.main.async {
			self.removeAllNodes()
			self.resetLabels()
			self.crosshair.isHidden = false
			self.petScore = 0
		}
		runSession()
	}

}
