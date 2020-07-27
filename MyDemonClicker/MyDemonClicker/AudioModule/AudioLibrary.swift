import AVFoundation

enum SongLibrary : String, CaseIterable {
    case background = ""
}

enum IntroWithLoopLibrary: CaseIterable {
    case first
    
    var info : (intro: String, loop: String) {
        switch self {
        case .first:
            return ("", "")
        }
    }
}

enum SoundEffectLibrary : String, CaseIterable {
    case tap = "Click.wav"
    case buy = "Coin-Buy.wav"
}
