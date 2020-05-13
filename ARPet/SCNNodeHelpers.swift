//
//  SCNNodeHelpers.swift
//  ARPet
//
//  Created by Ricardo Rodriguez on 5/6/20.
//  Copyright © 2020 Ricardo Rodriguez. All rights reserved.
//

import SceneKit



func createPlaneNode(center: vector_float3, extent: vector_float3) -> SCNNode {
	let plane = SCNPlane(width: CGFloat(extent.x), height: CGFloat(extent.z))
	let planeMaterial = SCNMaterial()
	planeMaterial.diffuse.contents = UIColor.yellow.withAlphaComponent(0.6)
	plane.materials = [planeMaterial]
	let planeNode = SCNNode(geometry: plane)
	planeNode.position = SCNVector3Make(center.x, 0, center.z)
	planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
	return planeNode
}

func updatePlaneNode(_ node: SCNNode, center: vector_float3, extent: vector_float3) {
	let geometry = node.geometry as? SCNPlane
	geometry?.width = CGFloat(extent.x)
	geometry?.height = CGFloat(extent.z)
	node.position = SCNVector3Make(center.x, 0, center.z)
	
}
