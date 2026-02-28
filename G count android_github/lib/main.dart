import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'backend/process.dart';
import 'frontend/pages.dart';

void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations (portrait only)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style (status bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF101922),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const GCountApp());
}

class GCountApp extends StatelessWidget {
  const GCountApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CounterProcessService(),
      child: MaterialApp(
        title: 'G Count',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF137FEC),
          scaffoldBackgroundColor: const Color(0xFF101922),
          fontFamily: 'Inter',
          brightness: Brightness.dark,
        ),
        home: const GCountHomePage(),
      ),
    );
  }
}

class GCountHomePage extends StatefulWidget {
  const GCountHomePage({Key? key}) : super(key: key);

  @override
  State<GCountHomePage> createState() => _GCountHomePageState();
}

class _GCountHomePageState extends State<GCountHomePage> {
  bool _hasShownLimitAlert = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<CounterProcessService>(
      builder: (context, process, child) {
        // Show limit reached alert
        if (process.limitReached && !_hasShownLimitAlert) {
          _hasShownLimitAlert = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showLimitReachedDialog(context, process);
          });
        }
        
        // Reset flag when limit alert is dismissed
        if (!process.limitReached && _hasShownLimitAlert) {
          _hasShownLimitAlert = false;
        }

        return WillPopScope(
          onWillPop: () async {
            // Turn off mic when exiting app
            if (process.isMicActive) {
              await process.onMicPressed();
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: const Color(0xFF101922),
            body: SafeArea(
              child: Column(
                children: [
                  // Header with Back and Set Limit buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        GestureDetector(
                          onTap: () async {
                            // Turn off mic before exiting
                            if (process.isMicActive) {
                              await process.onMicPressed();
                            }
                            // Exit app
                            SystemNavigator.pop();
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.arrow_back_ios,
                                color: Color(0xFF64748B),
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'BACK',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Set Limit Button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SetLimitScreenConnected(),
                              ),
                            );
                          },
                          child: const Text(
                            'SET LIMIT',
                            style: TextStyle(
                              color: Color(0xFF137FEC),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Large Counter Display
                  Text(
                    '${process.counter}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 120,
                      fontWeight: FontWeight.bold,
                      height: 1,
                      letterSpacing: -4,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Action Buttons Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        // START / STOP Button
                        SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: ElevatedButton(
                            onPressed: () {
                              if (process.isRunning) {
                                process.onStopPressed();
                              } else {
                                process.onStartPressed();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF137FEC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 8,
                              shadowColor: const Color(0xFF137FEC).withOpacity(0.3),
                            ),
                            child: Text(
                              process.isRunning ? 'STOP' : 'START',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // RESET Button (shows only when counter > 0)
                        if (process.counter > 0)
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () {
                                process.onResetPressed();
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF137FEC),
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'RESET',
                                style: TextStyle(
                                  color: Color(0xFF137FEC),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 40),

                        // Voice Control Section
                        Column(
                          children: [
                            // Microphone Button
                            GestureDetector(
                              onTap: () async {
                                await process.onMicPressed();
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: process.isMicActive
                                      ? const Color(0xFF137FEC).withOpacity(0.2)
                                      : const Color(0xFF137FEC).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: process.isMicActive
                                        ? const Color(0xFF137FEC)
                                        : const Color(0xFF137FEC).withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  process.isMicActive ? Icons.mic : Icons.mic_none,
                                  color: const Color(0xFF137FEC),
                                  size: 36,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Voice Control Label
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'VOICE CONTROL',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Info Icon - Navigate to Page 3
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const VoiceCommandsInfoScreen(),
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.info_outline,
                                    color: Colors.grey[500],
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Bottom spacing
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLimitReachedDialog(BuildContext context, CounterProcessService process) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.celebration,
                color: Color(0xFF137FEC),
                size: 32,
              ),
              SizedBox(width: 12),
              Text(
                'Limit Reached!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You have reached the target count of ${process.limit}!',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF137FEC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF137FEC).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF137FEC),
                      size: 48,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${process.limit}',
                      style: const TextStyle(
                        color: Color(0xFF137FEC),
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  process.onOkPressed();
                  Navigator.of(dialogContext).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF137FEC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// SET LIMIT SCREEN CONNECTED TO BACKEND
// ============================================================================

class SetLimitScreenConnected extends StatefulWidget {
  const SetLimitScreenConnected({Key? key}) : super(key: key);

  @override
  State<SetLimitScreenConnected> createState() => _SetLimitScreenConnectedState();
}

class _SetLimitScreenConnectedState extends State<SetLimitScreenConnected> {
  String limitValue = '0';

  void _onNumberPress(String number) {
    setState(() {
      if (limitValue == '0') {
        limitValue = number;
      } else {
        limitValue += number;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (limitValue.length > 1) {
        limitValue = limitValue.substring(0, limitValue.length - 1);
      } else {
        limitValue = '0';
      }
    });
  }

  void _onOk() {
    final process = Provider.of<CounterProcessService>(context, listen: false);
    process.onSetLimit(int.parse(limitValue));
    Navigator.pop(context);
  }

  void _onCancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101922),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101922),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF137FEC)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Set Limit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Icon and Title Section
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF137FEC).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  color: Color(0xFF137FEC),
                  size: 32,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Set Counter Limit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'The counter will pause once this target is reached.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 40),

              // Limit Value Display
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey[700]!,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    limitValue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // OK and Cancel Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _onOk,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF137FEC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _onCancel,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.grey[700]!,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Number Pad
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  if (index == 9) {
                    return const SizedBox.shrink();
                  } else if (index == 10) {
                    return _buildNumberButton('0');
                  } else if (index == 11) {
                    return _buildBackspaceButton();
                  } else {
                    return _buildNumberButton('${index + 1}');
                  }
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberPress(number),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[800]!,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: _onBackspace,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: Colors.grey[500],
            size: 28,
          ),
        ),
      ),
    );
  }
}