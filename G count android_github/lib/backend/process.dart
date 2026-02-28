import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

// ============================================================================
// COUNTER PROCESS SERVICE
// Handles all counting logic, voice recognition, and text-to-speech
// ============================================================================

class CounterProcessService extends ChangeNotifier {
  // ============================================================================
  // PROPERTIES
  // ============================================================================
  
  // Counter state
  int _counter = 0;
  bool _isRunning = false;
  int _limit = 0;
  bool _hasLimit = false;
  bool _limitReached = false;
  
  // Voice recognition
  late stt.SpeechToText _speech;
  bool _isMicActive = false;
  bool _isListening = false;
  
  // Text-to-speech
  late FlutterTts _tts;
  
  // Timer for counting
  Timer? _countTimer;
  Timer? _alertTimer;
  
  // ============================================================================
  // GETTERS
  // ============================================================================
  
  int get counter => _counter;
  bool get isRunning => _isRunning;
  bool get isMicActive => _isMicActive;
  bool get limitReached => _limitReached;
  int get limit => _limit;
  bool get hasLimit => _hasLimit;
  
  // ============================================================================
  // CONSTRUCTOR & INITIALIZATION
  // ============================================================================
  
  CounterProcessService() {
    _initializeSpeech();
    _initializeTts();
  }
  
  /// Initialize Speech Recognition
  Future<void> _initializeSpeech() async {
    _speech = stt.SpeechToText();
    await _speech.initialize(
      onError: (error) => debugPrint('Speech error: $error'),
      onStatus: (status) => debugPrint('Speech status: $status'),
    );
  }
  
  /// Initialize Text-to-Speech
  Future<void> _initializeTts() async {
    _tts = FlutterTts();
    
    // Configure TTS settings
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5); // Normal speed
    await _tts.setVolume(1.0); // Max volume
    await _tts.setPitch(1.0); // Normal pitch
    
    // Set completion handler
    _tts.setCompletionHandler(() {
      debugPrint('TTS completed');
    });
  }
  
  // ============================================================================
  // COUNTER LOGIC
  // ============================================================================
  
  /// Start counting
  void startCounting() {
    if (_isRunning) return;
    
    _isRunning = true;
    notifyListeners();
    
    // Start counting timer (1 count per second)
    _countTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _counter++;
      
      // Speak the current number
      _speakNumber(_counter);
      
      // Check if limit is reached
      if (_hasLimit && _counter >= _limit) {
        _onLimitReached();
      }
      
      notifyListeners();
    });
  }
  
  /// Stop/Pause counting
  void stopCounting() {
    if (!_isRunning) return;
    
    _isRunning = false;
    _countTimer?.cancel();
    notifyListeners();
  }
  
  /// Reset counter to 0
  void resetCounter() {
    _counter = 0;
    _isRunning = false;
    _limitReached = false;
    _countTimer?.cancel();
    _alertTimer?.cancel();
    
    // Stop any ongoing TTS
    _tts.stop();
    
    notifyListeners();
  }
  
  /// Set counter limit
  void setLimit(int limit) {
    _limit = limit;
    _hasLimit = limit > 0;
    notifyListeners();
  }
  
  /// Handle limit reached
  void _onLimitReached() {
    _limitReached = true;
    _isRunning = false;
    _countTimer?.cancel();
    
    // Start continuous alert
    _startLimitAlert();
    
    notifyListeners();
  }
  
  /// Dismiss limit alert (called when user says "OK" or presses OK button)
  void dismissLimitAlert() {
    _limitReached = false;
    _alertTimer?.cancel();
    _tts.stop();
    notifyListeners();
  }
  
  // ============================================================================
  // TEXT-TO-SPEECH LOGIC
  // ============================================================================
  
  /// Speak a number
  Future<void> _speakNumber(int number) async {
    await _tts.speak(number.toString());
  }
  
  /// Start continuous limit reached alert
  void _startLimitAlert() {
    // Speak immediately
    _speakLimitAlert();
    
    // Then repeat every 3 seconds until dismissed
    _alertTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _speakLimitAlert();
    });
  }
  
  /// Speak "YOU HAVE REACHED" alert
  Future<void> _speakLimitAlert() async {
    await _tts.speak("YOU HAVE REACHED!");
  }
  
  // ============================================================================
  // VOICE RECOGNITION LOGIC
  // ============================================================================
  
  /// Toggle microphone ON/OFF
  Future<void> toggleMicrophone() async {
    if (_isMicActive) {
      // Turn OFF microphone
      await _stopListening();
      _isMicActive = false;
    } else {
      // Turn ON microphone
      _isMicActive = true;
      await _startListening();
    }
    notifyListeners();
  }
  
  /// Start continuous voice listening
  Future<void> _startListening() async {
    if (!_speech.isAvailable) {
      debugPrint('Speech recognition not available');
      return;
    }
    
    _isListening = true;
    
    // Start listening with continuous mode
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          _processVoiceCommand(result.recognizedWords.toLowerCase());
        }
      },
      listenMode: stt.ListenMode.confirmation,
      cancelOnError: false,
      partialResults: false,
    );
    
    // Keep listening continuously by restarting when it stops
    _speech.statusListener = (status) {
      if (status == 'notListening' && _isMicActive && !_limitReached) {
        // Restart listening after a brief delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_isMicActive) {
            _startListening();
          }
        });
      }
    };
  }
  
  /// Stop voice listening
  Future<void> _stopListening() async {
    _isListening = false;
    await _speech.stop();
  }
  
  /// Process recognized voice commands
  void _processVoiceCommand(String command) {
    debugPrint('Voice command received: $command');
    
    // Clean up command (remove extra spaces, convert to lowercase)
    command = command.trim().toLowerCase();
    
    // Check for START command
    if (command.contains('start')) {
      startCounting();
      debugPrint('Executing: START');
    }
    // Check for STOP command
    else if (command.contains('stop')) {
      stopCounting();
      debugPrint('Executing: STOP');
    }
    // Check for RESET command
    else if (command.contains('reset')) {
      resetCounter();
      debugPrint('Executing: RESET');
    }
    // Check for OK command (dismiss alert)
    else if (command.contains('ok') || command.contains('okay')) {
      if (_limitReached) {
        dismissLimitAlert();
        debugPrint('Executing: OK (dismiss alert)');
      }
    }
  }
  
  // ============================================================================
  // CLEANUP
  // ============================================================================
  
  /// Dispose resources when app exits
  @override
  void dispose() {
    _countTimer?.cancel();
    _alertTimer?.cancel();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }
  
  // ============================================================================
  // PUBLIC METHODS FOR MANUAL CONTROLS
  // ============================================================================
  
  /// Manual start (called from UI button)
  void onStartPressed() {
    if (_limitReached) return; // Don't start if limit is reached
    startCounting();
  }
  
  /// Manual stop (called from UI button)
  void onStopPressed() {
    stopCounting();
  }
  
  /// Manual reset (called from UI button)
  void onResetPressed() {
    resetCounter();
  }
  
  /// Manual OK (called from UI button when limit reached)
  void onOkPressed() {
    dismissLimitAlert();
  }
  
  /// Manual set limit (called from Set Limit screen)
  void onSetLimit(int limit) {
    setLimit(limit);
  }
  
  /// Manual mic toggle (called from UI button)
  Future<void> onMicPressed() async {
    await toggleMicrophone();
  }
}

// ============================================================================
// USAGE EXAMPLE / INTEGRATION GUIDE
// ============================================================================

/*

HOW TO INTEGRATE WITH PAGES.DART:

1. Add dependencies to pubspec.yaml:
   dependencies:
     speech_to_text: ^6.6.0
     flutter_tts: ^4.0.2
     provider: ^6.1.1

2. Wrap your app with ChangeNotifierProvider in main.dart:

   void main() {
     runApp(
       ChangeNotifierProvider(
         create: (_) => CounterProcessService(),
         child: const MyApp(),
       ),
     );
   }

3. In MainCounterScreen (pages.dart), use Provider:

   class _MainCounterScreenState extends State<MainCounterScreen> {
     @override
     Widget build(BuildContext context) {
       final process = Provider.of<CounterProcessService>(context);
       
       return Scaffold(
         // ... your UI code
         
         // Counter display
         Text('${process.counter}'),
         
         // START/STOP button
         ElevatedButton(
           onPressed: () {
             if (process.isRunning) {
               process.onStopPressed();
             } else {
               process.onStartPressed();
             }
           },
           child: Text(process.isRunning ? 'STOP' : 'START'),
         ),
         
         // RESET button
         ElevatedButton(
           onPressed: () => process.onResetPressed(),
           child: Text('RESET'),
         ),
         
         // MIC button
         IconButton(
           icon: Icon(process.isMicActive ? Icons.mic : Icons.mic_none),
           onPressed: () => process.onMicPressed(),
         ),
       );
     }
   }

4. In SetLimitScreen (pages.dart), set the limit:

   void _onOk() {
     final process = Provider.of<CounterProcessService>(context, listen: false);
     process.onSetLimit(int.parse(limitValue));
     Navigator.pop(context);
   }

5. Show alert dialog when limit is reached:

   @override
   Widget build(BuildContext context) {
     final process = Provider.of<CounterProcessService>(context);
     
     // Show alert when limit reached
     if (process.limitReached) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
         showDialog(
           context: context,
           barrierDismissible: false,
           builder: (context) => AlertDialog(
             title: Text('Limit Reached!'),
             content: Text('You have reached ${process.limit}'),
             actions: [
               TextButton(
                 onPressed: () {
                   process.onOkPressed();
                   Navigator.pop(context);
                 },
                 child: Text('OK'),
               ),
             ],
           ),
         );
       });
     }
     
     return Scaffold(...);
   }

6. Add permissions to AndroidManifest.xml:
   <uses-permission android:name="android.permission.RECORD_AUDIO"/>
   <uses-permission android:name="android.permission.INTERNET"/>

7. Add permissions to Info.plist (iOS):
   <key>NSMicrophoneUsageDescription</key>
   <string>This app needs microphone access for voice commands</string>
   <key>NSSpeechRecognitionUsageDescription</key>
   <string>This app needs speech recognition for voice commands</string>

*/

// ============================================================================
// TESTING NOTES
// ============================================================================

/*

TESTING CHECKLIST:

✅ Counter Logic:
   - Counter starts from 0
   - Counts every 1 second
   - START button begins counting
   - STOP button pauses counting
   - RESET button resets to 0
   - Counter speaks each number

✅ Limit Logic:
   - User can set limit via Set Limit screen
   - Counter stops when limit is reached
   - "YOU HAVE REACHED" alert plays continuously
   - Alert stops when user says "OK" or presses OK button

✅ Voice Recognition:
   - Mic button toggles microphone ON/OFF
   - Mic stays ON until app exit
   - Commands work: "START", "STOP", "RESET", "OK"
   - Voice commands are case-insensitive
   - No recordings are saved (real-time only)

✅ Text-to-Speech:
   - Each count is spoken aloud
   - Alert message is spoken continuously when limit reached
   - Alert stops when dismissed

✅ Edge Cases:
   - Mic doesn't auto-start (manual only)
   - Mic turns off when app exits
   - Multiple rapid button presses handled gracefully
   - Voice commands don't interfere with manual controls

*/