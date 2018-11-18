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
    @IBOutlet weak var playbuttonpic: UIButton!
    @IBOutlet weak var bigphoto: UIImageView!
    //    var sequencerManager: SequencerManager?
    @IBOutlet weak var shareBt: UIButton!
    var track : AKMusicTrack?
    var sequencer : AKSequencer?
//    var midiFilter = MIDIFilter()
    
    let documentInteractionController = UIDocumentInteractionController()
    
    
    @IBOutlet weak var recordBtPic: UIButton!
    
    lazy var pitchEngine: PitchEngine = { [weak self] in
        let config = Config(estimationStrategy: .yin)
        let pitchEngine = PitchEngine(config: config, delegate: self)
        pitchEngine.levelThreshold = -30.0
        return pitchEngine
        }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        documentInteractionController.delegate = self
        
        
        do{
            
            try AudioKit.start()
        }catch{
            
        }
        
        
        
    }
    
    var starttime : CFTimeInterval = 0
    
    var melody : [(note: Int,time: CFTimeInterval,octive: Int)] = [(0,0,0)]
    
    func pitchEngine(_ pitchEngine: PitchEngine, didReceivePitch pitch: Pitch) {
        
        let thenote = pitch.offsets.closest.note.index+69
        if (thenote==melody.last?.0){
        }else{
            melody.append((thenote,CACurrentMediaTime()-starttime,pitch.offsets.closest.note.octave))
            
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
        
        
        if (recordBtPic.image(for: .normal)==UIImage(named: "RecordingBt")){
            
            recordBtPic.setImage(UIImage(named: "RecordPic"), for: .normal)
            
            
            pitchEngine.active ?  pitchEngine.stop() : ()
            
            endrecord()
            melody = []
            
            
        }else if(recordBtPic.image(for: .normal)==UIImage(named: "Retry")){
            
            bigphoto.image = UIImage(named: "Mic")
            playbuttonpic.isHidden = true
            shareBt.isHidden = true
            recordBtPic.setImage(UIImage(named: "RecordPic"), for: .normal)
            
            
            
            
        }else{
            starttime = CACurrentMediaTime()
            pitchEngine.active ? () : pitchEngine.start()
            recordBtPic.setImage(UIImage(named: "RecordingBt"), for: .normal)
            startrecord()
        }
        
    }
    
    private func endrecord(){
        
        
        
        let duration = melody.last?.time
        if (duration != nil){
            sequencer = AKSequencer()
            track = sequencer?.newTrack()
            
            sequencer?.setLength(AKDuration(seconds: duration!))
            for i in melody {
                if (i.octive > 1)&&(i.octive<6){
                    
                    track?.add(noteNumber: MIDINoteNumber(i.note),
                               velocity: MIDIVelocity(100),
                               position: AKDuration(seconds: i.time, tempo: 120),
                               duration: AKDuration(seconds: 0.7, tempo: 120))
                }
            }
            bigphoto.image = UIImage(named: "done")
            playbuttonpic.isHidden = false
            shareBt.isHidden = false
            recordBtPic.setImage(UIImage(named: "Retry"), for: .normal)
            
        }else{
            
            
            recordBtPic.setImage(UIImage(named: "RecordPic"), for: .normal)
        }
        
            
            
        
        
        
    }
    private func startrecord(){
        return
        
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
    
    @IBAction func playButton(_ sender: Any) {
        sequencer?.rewind()
        sequencer?.play()
        
    }
    
}
