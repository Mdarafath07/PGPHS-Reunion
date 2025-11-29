
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  late Animation<double> _scaleAnimation;
  late Animation<double> _pressRotationAnimation;
  late Animation<double> _shadowElevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _pressRotationAnimation = Tween<double>(begin: 0.0, end: -0.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _shadowElevationAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        HapticFeedback.lightImpact();
      }
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        if(mounted && Navigator.of(context).canPop()) {
          Navigator.pop(context);
        }
        widget.onFinished();
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
      child: SingleChildScrollView(

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
            const SizedBox(height: 60),
            GestureDetector(
              onTapDown: (_) => _controller.forward(),
              onTapUp: (_) {
                if (_controller.status != AnimationStatus.completed) {
                  _controller.reverse();
                }
              },
              onTapCancel: () => _controller.reverse(),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform(
                    alignment: FractionalOffset.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0015)
                      ..rotateX(_pressRotationAnimation.value),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 125,
                          width: 125,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: _shadowElevationAnimation.value,
                                spreadRadius: _shadowElevationAnimation.value / 2,
                                offset: Offset(0, _shadowElevationAnimation.value / 2),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 125,
                          width: 125,
                          child: CircularProgressIndicator(
                            value: _controller.value,
                            strokeWidth: 8,
                            valueColor: const AlwaysStoppedAnimation(Colors.blueAccent),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
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
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}