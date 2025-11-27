import 'package:flutter/material.dart';

void showLongPressAnimation(BuildContext context, VoidCallback onFinished) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return _LongPressWidget(onFinished: onFinished);
    },
  );
}

class _LongPressWidget extends StatefulWidget {
  final VoidCallback onFinished;
  const _LongPressWidget({required this.onFinished});

  @override
  State<_LongPressWidget> createState() => _LongPressWidgetState();
}

class _LongPressWidgetState extends State<_LongPressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // 2 সেকেন্ড চেপে ধরতে হবে
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if(mounted && Navigator.of(context).canPop()) {
          Navigator.pop(context); // ডায়ালগ বন্ধ
        }
        widget.onFinished(); // কাজ সম্পন্ন
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Hold to Confirm",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
              fontFamily: 'Arial',
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) {
              if (_controller.status != AnimationStatus.completed) {
                _controller.reverse();
              }
            },
            onTapCancel: () => _controller.reverse(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Circle
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
                // Progress Indicator
                SizedBox(
                  height: 120,
                  width: 120,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CircularProgressIndicator(
                        value: _controller.value,
                        strokeWidth: 8,
                        valueColor: const AlwaysStoppedAnimation(Colors.greenAccent),
                        backgroundColor: Colors.transparent,
                      );
                    },
                  ),
                ),
                // Icon inside
                Container(
                  height: 100,
                  width: 100,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fingerprint,
                    size: 60,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}