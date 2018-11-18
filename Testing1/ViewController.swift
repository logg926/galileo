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
//
//
//    var sequencerManager: SequencerManager?
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = hexStringToUIColor("#363636")
//        let newTracker :InputSignalTracker?
        
//
//
//        sequencerManager = SequencerManager()
        
        documentInteractionController.delegate = self
        AudioKit.output = AKMixer(oscillator, oscillator2)
        do{
            
            try AudioKit.start()
        }catch{
            
        }
        
        
        
    }
    
    var notes : [Int] = []
    var octaves : [Int] = []
    var durations : [CFTimeInterval] = []
    var starttime : CFTimeInterval = 0
    
    var melody : [(note: Int,time: CFTimeInterval,octive: Int)] = [(0,0,0)]
    
    func pitchEngine(_ pitchEngine: PitchEngine, didReceivePitch pitch: Pitch) {
        
        let thenote = pitch.offsets.closest.note.index+69
        if (thenote==melody.last?.0){
        }else{
            melody.append((thenote,CACurrentMediaTime()-starttime,pitch.offsets.closest.note.octave))
            notes.append(pitch.offsets.closest.note.index+69)
            octaves.append(pitch.offsets.closest.note.octave)
            durations.append(CACurrentMediaTime()-starttime)
        }
        print(pitch)
        
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
        
        
        
        if (recordBtPic.image(for: .normal)==UIImage(named: "RecordingBt")){
            
            recordBtPic.setImage(UIImage(named: "RecordPic"), for: .normal)
            
            
            pitchEngine.active ?  pitchEngine.stop() : ()
            
            endrecord()
            melody = []
            
        }else{
            starttime = CACurrentMediaTime()
            pitchEngine.active ? () : pitchEngine.start()
            recordBtPic.setImage(UIImage(named: "RecordingBt"), for: .normal)
            startrecord()
        }
        
    }
    
    fileprivate func endrecord(){
        
        
        sequencer = AKSequencer()
        track = sequencer?.newTrack()
        do{
            let duration = try (melody.last?.time)!
            
            sequencer?.setLength(AKDuration(seconds: duration))
            for i in melody {
                if (i.octive > 1)&&(i.octive<6){
                    
                    track?.add(noteNumber: MIDINoteNumber(i.note),
                               velocity: MIDIVelocity(100),
                               position: AKDuration(seconds: i.time, tempo: 120),
                               duration: AKDuration(seconds: 0.7, tempo: 120))
                }
            }
            
        }catch{
            return
        }
        
        
        
        
        
//        notes
//        durations = []
//        octaves
//
//        track?.add(noteNumber: MIDINoteNumber(60),
//                   velocity: MIDIVelocity(100),
//                   position: AKDuration(seconds: durations[i], tempo: 120),
//                   duration: AKDuration(seconds: 0.5, tempo: 120))
//
//
//
//        print (notes)
//        print (durations)
//        print (octaves)
        
        
    }
    fileprivate func startrecord(){
        return
        
    }
    
    
//    @IBAction func testingbutton(_ sender: Any) {
//        
//        if oscillator.isPlaying {
//            oscillator.stop()
//        } else {
//            oscillator.amplitude = random(0.5, 1)
//            oscillator.frequency = random(220, 880)
//            oscillator.start()
//        }
//    }
    
    
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
    
    @IBAction func playButton(_ sender: Any) {
        sequencer?.rewind()
        sequencer?.play()
        
    }
    
}
