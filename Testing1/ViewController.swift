//
//  ViewController.swift
//  Testing1
//
//  Created by Log G Cheng on 14/11/2018.
//  Copyright © 2018 Log G Cheng. All rights reserved.
//


import UIKit
import Beethoven
import Pitchy

class ViewController: UIViewController, PitchEngineDelegate {
    
    func hexStringToUIColor (_ hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    @IBOutlet weak var recordBtPic: UIButton!
    
    lazy var pitchEngine: PitchEngine = { [weak self] in
        let config = Config(estimationStrategy: .yin)
        let pitchEngine = PitchEngine(config: config, delegate: self)
        pitchEngine.levelThreshold = -30.0
        return pitchEngine
        }()
//        = PitchEngine(config: config, delegate: self)
    
    
    
    @IBOutlet weak var display: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = hexStringToUIColor("#363636")
//        let newTracker :InputSignalTracker?
        
        
        
    }
    
    func pitchEngine(_ pitchEngine: PitchEngine, didReceivePitch pitch: Pitch) {
        print(pitch)
        
        
    }
    
    func pitchEngine(_ pitchEngine: PitchEngine, didReceiveError error: Error) {
        print(error)
    }
    
    func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine) {
        print("Below threshold wor")
    }
    
    @IBAction func recordBt(_ sender: Any) {
        
        let text = pitchEngine.active
            ? NSLocalizedString("Start", comment: "").uppercased()
            : NSLocalizedString("Stop", comment: "").uppercased()
        
//        button.setTitle(text, for: .normal)
//        button.backgroundColor = pitchEngine.active
//            ? UIColor(hex: "3DAFAE")
//            : UIColor(hex: "E13C6C")
        
        display.text = "--"

//
//        pitchEngine.active ?: pitchEngine.start()
        
        if (recordBtPic.image(for: .normal)==UIImage(named: "RecordingBt")){
            
            recordBtPic.setImage(UIImage(named: "RecordPic"), for: .normal)
            pitchEngine.active ?  pitchEngine.stop() : ()
            
            
        }else{
            pitchEngine.active ? () : pitchEngine.start()
            recordBtPic.setImage(UIImage(named: "RecordingBt"), for: .normal)
        }
        
    }
    
    
}
