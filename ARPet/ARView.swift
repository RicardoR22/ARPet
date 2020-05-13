//
//  ARView.swift
//  ARPet
//
//  Created by Ricardo Rodriguez on 5/6/20.
//  Copyright © 2020 Ricardo Rodriguez. All rights reserved.
//

import UIKit
import ARKit

class ARView: ARSCNView {
	
	
	override init(frame: CGRect, options: [String : Any]? = nil) {
		super.init(frame: frame, options: options)
		setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setupView() {
		setupSubViews()
		setViewConstraints()
	}
	
	func setupSubViews() {
		addSubview(blurEffect)
		blurEffect.contentView.addSubview(label)
		addSubview(crosshair)
	}
	
	func setViewConstraints() {
		blurEffect.translatesAutoresizingMaskIntoConstraints = false
		blurEffect.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
		blurEffect.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
		blurEffect.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
		blurEffect.heightAnchor.constraint(equalToConstant: 50).isActive = true
		
		label.translatesAutoresizingMaskIntoConstraints = false
		label.leftAnchor.constraint(equalTo: blurEffect.leftAnchor, constant: 8).isActive = true
		label.rightAnchor.constraint(equalTo: blurEffect.rightAnchor, constant: -8).isActive = true
		label.topAnchor.constraint(equalTo: blurEffect.topAnchor).isActive = true
		label.bottomAnchor.constraint(equalTo: blurEffect.bottomAnchor).isActive = true
		
		crosshair.translatesAutoresizingMaskIntoConstraints = false
		crosshair.widthAnchor.constraint(equalToConstant: 10).isActive = true
		crosshair.heightAnchor.constraint(equalToConstant: 10).isActive = true
		crosshair.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
		crosshair.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
		
		
		
	}

    let blurEffect: UIVisualEffectView = {
		let blurEffect = UIBlurEffect(style: .light)
		let blurredEffectView = UIVisualEffectView(effect: blurEffect)
		
		let view = UIVisualEffectView(effect: blurEffect)
		
		let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
		let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)

		blurredEffectView.contentView.addSubview(vibrancyEffectView)
		
		return view
	}()
	
	
	let label: UILabel = {
		let lbl = UILabel()
		lbl.text = "Hello!"
		lbl.textAlignment = .center
		lbl.numberOfLines = 0
		
		return lbl
	}()
	
	let crosshair: UIView = {
		let view = UIView()
		view.backgroundColor = .gray
		
		return view
	}()
//	
//	let startButton: UIButton = {
//		let btn = UIButton()
//		btn.setTitle("Start", for: .normal)
//		btn.setTitleColor(.white, for: .normal)
//		btn.backgroundColor = UIColor.init(white: 1, alpha: 0.25)
//		
//		return btn
//	}()
//
//	let resetButton: UIButton = {
//		let btn = UIButton()
//		btn.setTitle("Reset", for: .normal)
//		btn.setTitleColor(.white, for: .normal)
//		btn.backgroundColor = UIColor.init(white: 1, alpha: 0.25)
//		
//		return btn
//	}()
//	
//	let styleButton: UIButton = {
//		let btn = UIButton()
//		btn.setTitle("Style", for: .normal)
//		btn.setTitleColor(.white, for: .normal)
//		btn.backgroundColor = UIColor.init(white: 1, alpha: 0.25)
//		
//		return btn
//	}()

	
}
