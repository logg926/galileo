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
import AudioKit

class ViewController: UIViewController, PitchEngineDelegate , UIDocumentInteractionControllerDelegate {
    
    
    var sequencerManager: SequencerManager?
    var track : AKMusicTrack?
    var sequencer : AKSequencer?
//    var midiFilter = MIDIFilter()
    
    let documentInteractionController = UIDocumentInteractionController()
    
    var oscillator = AKOscillator()
    var oscillator2 = AKOscillator()
    
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
        
        
        
        sequencerManager = SequencerManager()
        
        documentInteractionController.delegate = self
        AudioKit.output = AKMixer(oscillator, oscillator2)
        do{
            
            try AudioKit.start()
        }catch{
            
        }
        
        
    }
    
    func pitchEngine(_ pitchEngine: PitchEngine, didReceivePitch pitch: Pitch) {
        
        display.text = pitch.note.string
        print(pitch)
        
        let offsetPercentage = pitch.closestOffset.percentage
        let absOffsetPercentage = abs(offsetPercentage)
        
    }
    
    func pitchEngine(_ pitchEngine: PitchEngine, didReceiveError error: Error) {
        print(error)
    }
    
    func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine) {
        print("Below threshold wor")
    }
    
    @IBAction func recordBt(_ sender: Any) {
        
//        let text = pitchEngine.active
//            ? NSLocalizedString("Start", comment: "").uppercased()
//            : NSLocalizedString("Stop", comment: "").uppercased()
//
//        button.setTitle(text, for: .normal)
//        button.backgroundColor = pitchEngine.active
//            ? UIColor(hex: "3DAFAE")
//            : UIColor(hex: "E13C6C")
        
//        display.text = "--"

//
//        pitchEngine.active ?: pitchEngine.start()
        
        sequencer = AKSequencer()
        track = sequencer?.newTrack()
        sequencer?.setLength(AKDuration(seconds: 2.0))
        
        track?.add(noteNumber: MIDINoteNumber(60),
                   velocity: MIDIVelocity(100),
                   position: AKDuration(seconds: 1, tempo: 120),
                   duration: AKDuration(seconds: 0.5, tempo: 120))
        
        
        
        if (recordBtPic.image(for: .normal)==UIImage(named: "RecordingBt")){
            
            recordBtPic.setImage(UIImage(named: "RecordPic"), for: .normal)
            pitchEngine.active ?  pitchEngine.stop() : ()
            
            
        }else{
            pitchEngine.active ? () : pitchEngine.start()
            recordBtPic.setImage(UIImage(named: "RecordingBt"), for: .normal)
        }
        
    }
    
    
    @IBAction func testingbutton(_ sender: Any) {
        
        if oscillator.isPlaying {
            oscillator.stop()
        } else {
            oscillator.amplitude = random(0.5, 1)
            oscillator.frequency = random(220, 880)
            oscillator.start()
        }
    }
    
    
    @IBAction func exportButton(_ sender: Any) {
        
            guard let seq = sequencer,
                let data = seq.genData() else { return  }
            let fileName = "ExportedMIDI.mid"
            do {
                let tempPath = URL(fileURLWithPath: NSTemporaryDirectory().appending(fileName))
                try data.write(to: tempPath as URL)
                
                share(url: tempPath)
            } catch {
                AKLog("couldn't write to URL")
            }
            return
        
        
    }
    
    fileprivate func share(url: URL) {
        documentInteractionController.url = url
        documentInteractionController.presentOptionsMenu(from: recordBtPic.frame, in: view, animated: true)
    }
    
    
}
