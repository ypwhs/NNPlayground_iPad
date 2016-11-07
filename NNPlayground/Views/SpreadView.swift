//
//  SpreadView.swift
//  UIPlayground
//
//  Created by 陈禹志 on 16/4/26.
//  Copyright © 2016年 com.insta. All rights reserved.
//

import UIKit

class SpreadView: UIView {
    
    var layers = 3
    var buttonWidth:CGFloat = 30
    
    
    // MARK: - SetData
    var setCircleData: (() -> Void)?
    var setExclusiveOrData: (() -> Void)?
    var setGaussianData: (() -> Void)?
    var setSpiralData: (() -> Void)?
    
    @IBOutlet weak var setCircleButton: SelectDataButton!
    @IBOutlet weak var setExclusiveOrButton: SelectDataButton!
    @IBOutlet weak var setGaussianButton: SelectDataButton!
    @IBOutlet weak var setSpiralButton: SelectDataButton!
    func resetAlpha(_ sender: SelectDataButton) {
        let setDataButtons = [setCircleButton,setExclusiveOrButton,setGaussianButton,setSpiralButton]
        for i in setDataButtons {
            if i == sender {
                i?.isChosen = true
            }
            else {
                i?.isChosen = false
            }
        }
    }
    
    @IBAction func setCircle(_ sender: SelectDataButton) {
        setCircleData?()
        resetAlpha(sender)
    }
    @IBAction func setExclusiveOr(_ sender: SelectDataButton) {
        setExclusiveOrData?()
        resetAlpha(sender)
    }
    @IBAction func setGaussian(_ sender: SelectDataButton) {
        setGaussianData?()
        resetAlpha(sender)
    }
    @IBAction func setSpiral(_ sender: SelectDataButton) {
        setSpiralData?()
        resetAlpha(sender)
    }
    
    // MARK: - UISlider
    var setRatio: ((_ current: Int) -> Void)?
    var setNoise: ((_ current: Int) -> Void)?
    var setBatchSize: ((_ current: Int) -> Void)?
    func setSpacing(_ sender: EasySlider, total: Float) -> Int {
        let spacing = (sender.maximumValue - sender.minimumValue)/total
        let num = Int(sender.value/spacing)
        sender.setValue(Float(num)*spacing, animated: true)
        return num
    }
    
    @IBAction func setRatioAction(_ sender: EasySlider) {
        setRatio?(setSpacing(sender, total: 10))
    }
    @IBAction func setNoiseAction(_ sender: EasySlider) {
        setNoise?(setSpacing(sender, total: 10))
    }
    @IBAction func setBatchSizeAction(_ sender: EasySlider) {
        setBatchSize?(setSpacing(sender, total: 30))
    }
    
    // MARK: - AddLayer
    var addLayer: (() -> Void)?
    
    func addLayerButtons(_ sender:AddButton) {
        if sender.isAddButton && layers < 8 {
            layers += 1
            addNodeButton[layers - 3].isHidden = false
            subNodeButton[layers - 3].isHidden = false
        }
        if !sender.isAddButton && layers > 2 {
            layers -= 1
            addNodeButton[layers - 2].isHidden = true
            subNodeButton[layers - 2].isHidden = true
        }
        print("\(layers)")
        addLayer?()
    }
    
    @IBOutlet weak var addLayerButtons: AddButton!
    @IBAction func addLayerButton(_ sender: AddButton) {
        addLayerButtons(sender)
    }
    @IBAction func subLayerButton(_ sender: AddButton) {
        addLayerButtons(sender)
    }
    
    // MARK: - AddNode
    var addNode: ((_ layer: Int, _ isAdd: Bool) -> Void)?
    func addNodeAction(_ sender:AddButton) {
        var num = 1
        for i in addNodeButton {
            if i == sender {
                addNode?(num, true)
            }
            num += 1
        }
    }
    func subNodeAction(_ sender:AddButton) {
        var num = 1
        for i in subNodeButton {
            if i == sender {
                addNode?(num, false)
            }
            num += 1
        }
    }
    lazy var addNodeButton: [AddButton] = {
        let view = AddButton()
        view.frame = CGRect(x: 50, y: 100, width: 30, height: 30)
        view.addTarget(self, action: #selector(addNodeAction), for: .touchUpInside)
        var views = [view]
        for i in 2...6 {
            let view = AddButton()
            view.frame = CGRect(x: i*50, y: 100, width: 30, height: 30)
            view.addTarget(self, action: #selector(addNodeAction), for: .touchUpInside)
            views.append(view)
        }
        return views
    }()
    
    lazy var subNodeButton: [AddButton] = {
        let view = AddButton()
        view.frame = CGRect(x: 50, y: 150, width: 30, height: 30)
        view.isAddButton = false
        view.addTarget(self, action: #selector(subNodeAction), for: .touchUpInside)
        var views = [view]
        for i in 2...6 {
            let view = AddButton()
            view.isAddButton = false
            view.frame = CGRect(x: i*50, y: 150, width: 30, height: 30)
            view.addTarget(self, action: #selector(subNodeAction), for: .touchUpInside)
            views.append(view)
        }
        return views
    }()

    // MARK: - DropDown
    @IBOutlet weak var learningRateButton: DropDownButton!
    var setLearningRate: ((_ num: Int) -> Void)?
    fileprivate lazy var learningRateDropView: DropDownView = {
        let view = DropDownView()
        view.labelName = ["0.00001","0.0001","0.001","0.003","0.01","0.03","0.1","0.3","1","3","10"]
        view.showSelectedLabel = {(name: String, num: Int) in
            self.learningRateButton.setTitle(name, for: UIControlState())
            view.hide()
            self.setLearningRate?(num)
        }
        view.labelIsSelected = 5
        return view
    }()
    
    @IBAction func learningRateDrop(_ sender: DropDownButton) {
        if let window = self.window {
            learningRateDropView.showInView(window,button: sender)
        }
    }
    
    
    @IBOutlet weak var activationButton: DropDownButton!
    var setActivation: ((_ num: Int) -> Void)?
    fileprivate lazy var activationDropView: DropDownView = {
        let view = DropDownView()
        view.labelName = ["ReLU","Tanh","Sigmoid","Linear"]
        view.showSelectedLabel = {(name: String, num: Int) in
            self.activationButton.setTitle(name, for: UIControlState())
            view.hide()
            self.setActivation?(num)
        }
        view.labelIsSelected = 1
        return view
    }()
    
    @IBAction func activationDrop(_ sender: DropDownButton) {
        if let window = self.window {
            activationDropView.showInView(window,button: sender)
        }
    }
    
    
    @IBOutlet weak var regularizationButton: DropDownButton!
    var setRegularization: ((_ num: Int) -> Void)?
    fileprivate lazy var regularizationDropView: DropDownView = {
        let view = DropDownView()
        view.labelName = ["None","L1","L2"]
        view.showSelectedLabel = {(name: String, num: Int) in
            self.regularizationButton.setTitle(name, for: UIControlState())
            view.hide()
            self.setRegularization?(num)
        }
        view.labelIsSelected = 0
        return view
    }()
    
    @IBAction func regularizationDrop(_ sender: DropDownButton) {
        if let window = self.window {
            regularizationDropView.showInView(window,button: sender)
        }
    }
    
    
    @IBOutlet weak var regularizationRateButton: DropDownButton!
    var setRegularizationRate: ((_ num: Int) -> Void)?
    fileprivate lazy var regularizationRateDropView: DropDownView = {
        let view = DropDownView()
        view.labelName = ["0","0.001","0.003","0.01","0.03","0.1","0.3","1","3","10"]
        view.showSelectedLabel = {(name: String, num: Int) in
            self.regularizationRateButton.setTitle(name, for: UIControlState())
            view.hide()
            self.setRegularizationRate?(num)
        }
        view.labelIsSelected = 0
        return view
    }()
    
    @IBAction func regularizationRateDrop(_ sender: DropDownButton) {
        if let window = self.window {
            regularizationRateDropView.showInView(window,button: sender)
        }
    }
    
    
    @IBOutlet weak var problemTypeButton: DropDownButton!
    var setProblemType: ((_ num: Int) -> Void)?
    fileprivate lazy var problemTypeDropView: DropDownView = {
        let view = DropDownView()
        view.labelName = ["Classification","Regression"]
        view.showSelectedLabel = {(name: String, num: Int) in
            self.problemTypeButton.setTitle(name, for: UIControlState())
            view.hide()
            self.setProblemType?(num)
        }
        view.labelIsSelected = 0
        return view
    }()
    
    @IBAction func problemTypeDrop(_ sender: DropDownButton) {
        if let window = self.window {
            problemTypeDropView.showInView(window,button: sender)
        }
    }
    
    //MARK: - View
    func showInView(_ view:UIView) {
        frame = view.bounds
        view.addSubview(self)
        
        layoutIfNeeded()
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {[weak self]  _ in
            self?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            }, completion: { _ in
        })
        
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseOut, animations: {[weak self]  _ in
            self?.backgroundColor = UIColor.clear
            }, completion: {[weak self]  _ in
                self?.removeFromSuperview()
            })
    }
    
    var isFirstTimeBeenAddAsSubview = true
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if isFirstTimeBeenAddAsSubview {
            isFirstTimeBeenAddAsSubview = false
            
            makeUI()
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(SpreadView.hide))
            self.addGestureRecognizer(tap)
            
            tap.cancelsTouchesInView = true
            tap.delegate = self
        }
    }
    
    func makeUI() {
        setCircleButton.isChosen = true
        for i in 0...5 {
            self.addSubview(addNodeButton[i])
            self.addSubview(subNodeButton[i])
            if i != 0 {
                addNodeButton[i].isHidden = true
                subNodeButton[i].isHidden = true
            }
        }
        
    }
    
}

extension SpreadView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if touch.view != self {
            return false
        }
        return true
    }
    
}
