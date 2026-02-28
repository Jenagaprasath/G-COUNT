import 'package:flutter/material.dart';

// ============================================================================
// PAGE 1: MAIN COUNTER SCREEN (Home Page)
// ============================================================================

class MainCounterScreen extends StatefulWidget {
  const MainCounterScreen({Key? key}) : super(key: key);

  @override
  State<MainCounterScreen> createState() => _MainCounterScreenState();
}

class _MainCounterScreenState extends State<MainCounterScreen> {
  int counter = 0;
  bool isRunning = false;
  bool isMicActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    onTap: () {
                      // TODO: Connect to backend - Exit app
                      Navigator.pop(context);
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
                          builder: (context) => const SetLimitScreen(),
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
              '$counter',
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
                        setState(() {
                          isRunning = !isRunning;
                        });
                        // TODO: Connect to backend - Start/Stop counting
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
                        isRunning ? 'STOP' : 'START',
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

                  // RESET Button (shows only when counting has started)
                  if (counter > 0)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            counter = 0;
                            isRunning = false;
                          });
                          // TODO: Connect to backend - Reset counter
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
                        onTap: () {
                          setState(() {
                            isMicActive = !isMicActive;
                          });
                          // TODO: Connect to backend - Toggle microphone
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isMicActive
                                ? const Color(0xFF137FEC).withOpacity(0.2)
                                : const Color(0xFF137FEC).withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isMicActive
                                  ? const Color(0xFF137FEC)
                                  : const Color(0xFF137FEC).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            isMicActive ? Icons.mic : Icons.mic_none,
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
    );
  }
}

// ============================================================================
// PAGE 2: SET LIMIT SCREEN
// ============================================================================

class SetLimitScreen extends StatefulWidget {
  const SetLimitScreen({Key? key}) : super(key: key);

  @override
  State<SetLimitScreen> createState() => _SetLimitScreenState();
}

class _SetLimitScreenState extends State<SetLimitScreen> {
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
    // TODO: Connect to backend - Save limit value
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
                    // Empty space
                    return const SizedBox.shrink();
                  } else if (index == 10) {
                    // Zero button
                    return _buildNumberButton('0');
                  } else if (index == 11) {
                    // Backspace button
                    return _buildBackspaceButton();
                  } else {
                    // Number buttons 1-9
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

// ============================================================================
// PAGE 3: VOICE COMMANDS INFO SCREEN
// ============================================================================

class VoiceCommandsInfoScreen extends StatelessWidget {
  const VoiceCommandsInfoScreen({Key? key}) : super(key: key);

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
          'Voice Commands',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF137FEC).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.record_voice_over,
                    color: Color(0xFF137FEC),
                    size: 40,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              const Center(
                child: Text(
                  'Available Voice Commands',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Center(
                child: Text(
                  'Use these commands to control the counter',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Commands List
              _buildCommandCard(
                icon: Icons.play_arrow,
                command: 'START',
                description: 'Begin counting from current number',
                color: Colors.green,
              ),

              const SizedBox(height: 16),

              _buildCommandCard(
                icon: Icons.pause,
                command: 'STOP',
                description: 'Pause the counter',
                color: Colors.orange,
              ),

              const SizedBox(height: 16),

              _buildCommandCard(
                icon: Icons.refresh,
                command: 'RESET',
                description: 'Reset counter back to zero',
                color: Colors.red,
              ),

              const SizedBox(height: 16),

              _buildCommandCard(
                icon: Icons.check_circle,
                command: 'OK',
                description: 'Dismiss the limit reached alert',
                color: Colors.blue,
              ),

              const SizedBox(height: 40),

              // Instructions Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF137FEC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF137FEC).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFF137FEC),
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'How to Use',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      '1',
                      'Tap the microphone button on the main screen',
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionItem(
                      '2',
                      'Wait for the microphone to activate',
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionItem(
                      '3',
                      'Speak any of the commands clearly',
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionItem(
                      '4',
                      'The app will respond to your voice command',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Note Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Note',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Microphone stays active until you exit the app. No recordings are saved.',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommandCard({
    required IconData icon,
    required String command,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  command,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF137FEC).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFF137FEC),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}