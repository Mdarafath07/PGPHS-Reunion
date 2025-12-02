import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showLongPressAnimation(BuildContext context, VoidCallback onFinished) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (context) {
      return _LongPressDialog(onFinished: onFinished);
    },
  );
}

class _LongPressDialog extends StatefulWidget {
  final VoidCallback onFinished;

  const _LongPressDialog({required this.onFinished});

  @override
  State<_LongPressDialog> createState() => _LongPressDialogState();
}

class _LongPressDialogState extends State<_LongPressDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        HapticFeedback.lightImpact();
        setState(() {
          _isPressed = true;
        });
      }

      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        _completed = true;

        // Close dialog first
        Navigator.of(context).pop();

        // Execute callback
        widget.onFinished();
      }

      if (status == AnimationStatus.dismissed ||
          status == AnimationStatus.reverse) {
        setState(() {
          _isPressed = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown() {
    if (!_completed && _controller.status != AnimationStatus.forward) {
      _controller.forward();
    }
  }

  void _handleTapUp() {
    if (_controller.status == AnimationStatus.forward && !_completed) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _handleTapDown(),
      onTapUp: (_) => _handleTapUp(),
      onTapCancel: () => _handleTapUp(),
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.transparent,
        child: Container(
          color: Colors.transparent,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Hold to Confirm",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              GestureDetector(
                onTapDown: (_) => _handleTapDown(),
                onTapUp: (_) => _handleTapUp(),
                onTapCancel: () => _handleTapUp(),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: CircularProgressIndicator(
                            value: _controller.value,
                            strokeWidth: 6,
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.blueAccent,
                            ),
                            backgroundColor: Colors.white.withOpacity(0.2),
                          ),
                        ),

                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: _isPressed
                                ? Colors.blue.shade50
                                : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.fingerprint,
                            size: 60,
                            color: _isPressed
                                ? Colors.blueAccent
                                : Colors.black87,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _isPressed
                      ? "Keep holding until 100%..."
                      : "Touch and hold anywhere on screen",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),

              if (_isPressed)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    "${(_controller.value * 100).toInt()}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
