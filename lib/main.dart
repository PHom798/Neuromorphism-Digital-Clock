import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neumorphic Clock Suite',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: MainNavigationScreen(),
    );
  }
}

// Design System Class - Centralizes all styling
class NeumorphicDesign {
  static const Color lightBg = Color(0xFFE4E9F2);
  static const Color darkBg = Color(0xFF2E3440);
  static const Color lightShadowDark = Color(0xFFBEC8D1);
  static const Color lightShadowLight = Color(0xFFFFFFFF);
  static const Color darkShadowDark = Color(0xFF1A1F2E);
  static const Color darkShadowLight = Color(0xFF3E4553);

  static Color backgroundColor(bool isDark) => isDark ? darkBg : lightBg;
  static Color shadowDark(bool isDark) => isDark ? darkShadowDark : lightShadowDark;
  static Color shadowLight(bool isDark) => isDark ? darkShadowLight : lightShadowLight;
  static Color textColor(bool isDark) => isDark ? Colors.white70 : Colors.black87;

  static Widget buildNeumorphicContainer({
    required Widget child,
    required bool isDarkMode,
    double? width,
    double? height,
    EdgeInsets? padding,
    double borderRadius = 20,
    bool isPressed = false,
    bool isInset = false,
  }) {
    Color bg = backgroundColor(isDarkMode);
    Color shadowD = shadowDark(isDarkMode);
    Color shadowL = shadowLight(isDarkMode);

    if (isInset) {
      return AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(color: shadowL, offset: Offset(4, 4), blurRadius: 8),
            BoxShadow(color: shadowD, offset: Offset(-4, -4), blurRadius: 8),
          ],
        ),
        child: Container(
          padding: padding ?? EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(color: shadowD, offset: Offset(2, 2), blurRadius: 4),
              BoxShadow(color: shadowL, offset: Offset(-2, -2), blurRadius: 4),
            ],
          ),
          child: child,
        ),
      );
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: width,
      height: height,
      padding: padding ?? EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isPressed
            ? [
          BoxShadow(color: shadowD, offset: Offset(2, 2), blurRadius: 5),
          BoxShadow(color: shadowL, offset: Offset(-2, -2), blurRadius: 5),
        ]
            : [
          BoxShadow(color: shadowD, offset: Offset(8, 8), blurRadius: 16),
          BoxShadow(color: shadowL, offset: Offset(-8, -8), blurRadius: 16),
        ],
      ),
      child: child,
    );
  }

  static Widget buildNeumorphicButton({
    required VoidCallback onPressed,
    required Widget child,
    required bool isDarkMode,
    required AnimationController scaleController,
    double borderRadius = 15,
  }) {
    return GestureDetector(
      onTapDown: (_) => scaleController.forward(),
      onTapUp: (_) => scaleController.reverse(),
      onTapCancel: () => scaleController.reverse(),
      onTap: onPressed,
      child: AnimatedBuilder(
        animation: scaleController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (scaleController.value * 0.05),
            child: buildNeumorphicContainer(
              child: child!,
              isDarkMode: isDarkMode,
              borderRadius: borderRadius,
              isPressed: scaleController.value > 0.5,
            ),
          );
        },
        child: child,
      ),
    );
  }
}

// Main Navigation Screen
class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  bool _isDarkMode = false;
  late AnimationController _scaleController;
  int _currentIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _screens.addAll([
      DigitalClockScreen(isDarkMode: _isDarkMode, onThemeToggle: _toggleTheme),
      TimerScreen(isDarkMode: _isDarkMode),
      StopwatchScreen(isDarkMode: _isDarkMode),
      AlarmScreen(isDarkMode: _isDarkMode),
    ]);
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicDesign.backgroundColor(_isDarkMode),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DigitalClockScreen(isDarkMode: _isDarkMode, onThemeToggle: _toggleTheme),
          TimerScreen(isDarkMode: _isDarkMode),
          StopwatchScreen(isDarkMode: _isDarkMode),
          AlarmScreen(isDarkMode: _isDarkMode),
        ],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(20),
        child: NeumorphicDesign.buildNeumorphicContainer(
          isDarkMode: _isDarkMode,
          borderRadius: 25,
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.access_time, 'Clock', 0),
              _buildNavItem(Icons.timer, 'Timer', 1),
              _buildNavItem(Icons.timer_outlined, 'Stopwatch', 2),
              _buildNavItem(Icons.alarm, 'Alarm', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isSelected
              ? (_isDarkMode ? Colors.blue.withOpacity(0.2) : Colors.blue.withOpacity(0.1))
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (_isDarkMode ? Colors.blue.shade300 : Colors.blue.shade600)
                  : NeumorphicDesign.textColor(_isDarkMode),
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? (_isDarkMode ? Colors.blue.shade300 : Colors.blue.shade600)
                    : NeumorphicDesign.textColor(_isDarkMode),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Updated Digital Clock Screen
class DigitalClockScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  DigitalClockScreen({required this.isDarkMode, required this.onThemeToggle});

  @override
  _DigitalClockScreenState createState() => _DigitalClockScreenState();
}

class _DigitalClockScreenState extends State<DigitalClockScreen>
    with TickerProviderStateMixin {
  DateTime _currentTime = DateTime.now();
  Timer? _timer;
  bool _is24HourFormat = true;
  late AnimationController _pulseController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _pulseController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  String _formatTime() {
    if (_is24HourFormat) {
      return '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}:${_currentTime.second.toString().padLeft(2, '0')}';
    } else {
      int hour = _currentTime.hour;
      String period = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      return '${hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')} $period';
    }
  }

  String _formatDate() {
    List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    List<String> days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return '${days[_currentTime.weekday - 1]}, ${months[_currentTime.month - 1]} ${_currentTime.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicDesign.backgroundColor(widget.isDarkMode),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Digital Clock',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: NeumorphicDesign.textColor(widget.isDarkMode),
                        letterSpacing: 1.2,
                      ),
                    ),
                    NeumorphicDesign.buildNeumorphicButton(
                      onPressed: widget.onThemeToggle,
                      isDarkMode: widget.isDarkMode,
                      scaleController: _scaleController,
                      borderRadius: 25,
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Icon(
                          widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          color: NeumorphicDesign.textColor(widget.isDarkMode),
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 60),

                // Main clock display
                NeumorphicDesign.buildNeumorphicContainer(
                  isDarkMode: widget.isDarkMode,
                  width: double.infinity,
                  padding: EdgeInsets.all(40),
                  borderRadius: 30,
                  child: Column(
                    children: [
                      // Digital time with enhanced gradient glow effect
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.isDarkMode
                                      ? Colors.cyan.withOpacity(0.4 * _pulseController.value)
                                      : Colors.deepPurple.withOpacity(0.3 * _pulseController.value),
                                  blurRadius: 25,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: widget.isDarkMode
                                    ? [Colors.cyan.withOpacity(0.9), Colors.blue.withOpacity(0.9)]
                                    : [Colors.deepPurple.withOpacity(0.9), Colors.pink.withOpacity(0.9)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: Text(
                                _formatTime(),
                                style: TextStyle(
                                  fontSize: 46,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                  fontFamily: 'monospace',
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      Text(
                        _formatDate(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: NeumorphicDesign.textColor(widget.isDarkMode).withOpacity(0.7),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),

                // Time segments
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTimeSegment('${_currentTime.hour.toString().padLeft(2, '0')}', 'HOUR'),
                    _buildTimeSegment('${_currentTime.minute.toString().padLeft(2, '0')}', 'MIN'),
                    _buildTimeSegment('${_currentTime.second.toString().padLeft(2, '0')}', 'SEC'),
                  ],
                ),
                SizedBox(height: 40),

                // Control button
                NeumorphicDesign.buildNeumorphicButton(
                  onPressed: () => setState(() => _is24HourFormat = !_is24HourFormat),
                  isDarkMode: widget.isDarkMode,
                  scaleController: _scaleController,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_rounded, color: NeumorphicDesign.textColor(widget.isDarkMode), size: 24),
                        SizedBox(width: 10),
                        Text(
                          _is24HourFormat ? '24H' : '12H',
                          style: TextStyle(
                            color: NeumorphicDesign.textColor(widget.isDarkMode),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSegment(String value, String label) {
    return NeumorphicDesign.buildNeumorphicContainer(
      isDarkMode: widget.isDarkMode,
      width: 80,
      height: 80,
      padding: EdgeInsets.all(8),
      borderRadius: 15,
      isInset: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: NeumorphicDesign.textColor(widget.isDarkMode),
              fontFamily: 'monospace',
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: NeumorphicDesign.textColor(widget.isDarkMode).withOpacity(0.6),
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// Timer Screen
class TimerScreen extends StatefulWidget {
  final bool isDarkMode;
  TimerScreen({required this.isDarkMode});

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  Duration _duration = Duration(minutes: 5);
  Duration _remaining = Duration(minutes: 5);
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(duration: Duration(milliseconds: 200), vsync: this);
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds > 0) {
        setState(() => _remaining = Duration(seconds: _remaining.inSeconds - 1));
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
        // Timer finished - could add notification here
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remaining = _duration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicDesign.backgroundColor(widget.isDarkMode),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Timer',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: NeumorphicDesign.textColor(widget.isDarkMode),
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 60),

              // Timer display
              NeumorphicDesign.buildNeumorphicContainer(
                isDarkMode: widget.isDarkMode,
                width: double.infinity,
                padding: EdgeInsets.all(40),
                borderRadius: 30,
                child: Column(
                  children: [
                    Text(
                      '${_remaining.inMinutes.toString().padLeft(2, '0')}:${(_remaining.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: NeumorphicDesign.textColor(widget.isDarkMode),
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: (_duration.inSeconds - _remaining.inSeconds) / _duration.inSeconds,
                      backgroundColor: NeumorphicDesign.shadowDark(widget.isDarkMode),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.isDarkMode ? Colors.cyan : Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NeumorphicDesign.buildNeumorphicButton(
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    isDarkMode: widget.isDarkMode,
                    scaleController: _scaleController,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Icon(
                        _isRunning ? Icons.pause : Icons.play_arrow,
                        color: NeumorphicDesign.textColor(widget.isDarkMode),
                        size: 32,
                      ),
                    ),
                  ),
                  NeumorphicDesign.buildNeumorphicButton(
                    onPressed: _resetTimer,
                    isDarkMode: widget.isDarkMode,
                    scaleController: _scaleController,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Icon(
                        Icons.stop,
                        color: NeumorphicDesign.textColor(widget.isDarkMode),
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scaleController.dispose();
    super.dispose();
  }
}

// Stopwatch Screen
class StopwatchScreen extends StatefulWidget {
  final bool isDarkMode;
  StopwatchScreen({required this.isDarkMode});

  @override
  _StopwatchScreenState createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(duration: Duration(milliseconds: 200), vsync: this);
  }

  void _start() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(Duration(milliseconds: 10), (timer) {
      setState(() => _elapsed = Duration(milliseconds: _elapsed.inMilliseconds + 10));
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _elapsed = Duration.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    String minutes = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    String milliseconds = ((_elapsed.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: NeumorphicDesign.backgroundColor(widget.isDarkMode),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Stopwatch',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: NeumorphicDesign.textColor(widget.isDarkMode),
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 60),

              // Stopwatch display
              NeumorphicDesign.buildNeumorphicContainer(
                isDarkMode: widget.isDarkMode,
                width: double.infinity,
                padding: EdgeInsets.all(40),
                borderRadius: 30,
                child: Text(
                  '$minutes:$seconds.$milliseconds',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    color: NeumorphicDesign.textColor(widget.isDarkMode),
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                  ),
                ),
              ),
              SizedBox(height: 40),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NeumorphicDesign.buildNeumorphicButton(
                    onPressed: _isRunning ? _pause : _start,
                    isDarkMode: widget.isDarkMode,
                    scaleController: _scaleController,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Icon(
                        _isRunning ? Icons.pause : Icons.play_arrow,
                        color: NeumorphicDesign.textColor(widget.isDarkMode),
                        size: 32,
                      ),
                    ),
                  ),
                  NeumorphicDesign.buildNeumorphicButton(
                    onPressed: _reset,
                    isDarkMode: widget.isDarkMode,
                    scaleController: _scaleController,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Icon(
                        Icons.stop,
                        color: NeumorphicDesign.textColor(widget.isDarkMode),
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scaleController.dispose();
    super.dispose();
  }
}

// Alarm Screen
class AlarmScreen extends StatefulWidget {
  final bool isDarkMode;
  AlarmScreen({required this.isDarkMode});

  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  List<AlarmItem> _alarms = [
    AlarmItem(time: TimeOfDay(hour: 7, minute: 30), label: 'Wake up', isEnabled: true),
    AlarmItem(time: TimeOfDay(hour: 12, minute: 0), label: 'Lunch', isEnabled: false),
  ];

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(duration: Duration(milliseconds: 200), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicDesign.backgroundColor(widget.isDarkMode),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Alarms',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: NeumorphicDesign.textColor(widget.isDarkMode),
                      letterSpacing: 1.2,
                    ),
                  ),
                  NeumorphicDesign.buildNeumorphicButton(
                    onPressed: () {
                      // Add new alarm functionality
                    },
                    isDarkMode: widget.isDarkMode,
                    scaleController: _scaleController,
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Icon(
                        Icons.add,
                        color: NeumorphicDesign.textColor(widget.isDarkMode),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              Expanded(
                child: ListView.builder(
                  itemCount: _alarms.length,
                  itemBuilder: (context, index) {
                    AlarmItem alarm = _alarms[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: NeumorphicDesign.buildNeumorphicContainer(
                        isDarkMode: widget.isDarkMode,
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        borderRadius: 20,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alarm.time.format(context),
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w300,
                                      color: NeumorphicDesign.textColor(widget.isDarkMode),
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    alarm.label,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: NeumorphicDesign.textColor(widget.isDarkMode).withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: alarm.isEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _alarms[index].isEnabled = value;
                                });
                              },
                              activeColor: widget.isDarkMode ? Colors.cyan : Colors.deepPurple,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }
}

// Alarm model class
class AlarmItem {
  TimeOfDay time;
  String label;
  bool isEnabled;

  AlarmItem({required this.time, required this.label, required this.isEnabled});
}