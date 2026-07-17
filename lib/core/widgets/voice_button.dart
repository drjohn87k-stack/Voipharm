import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated microphone button with a pulse effect while listening.
class VoiceButton extends StatefulWidget {
  const VoiceButton({
    super.key,
    required this.onTap,
    required this.isListening,
    this.size = 56,
    this.tooltip,
  });

  final VoidCallback onTap;
  final bool isListening;
  final double size;
  final String? tooltip;

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton>
    with TickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didUpdateWidget(covariant VoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.isListening && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.reset();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip ?? '',
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            final scale = 1 + (_pulse.value * 0.18);
            return Stack(
              alignment: Alignment.center,
              children: [
                if (widget.isListening)
                  Transform.scale(
                    scale: scale,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color:
                        widget.isListening ? AppTheme.errorRed : AppTheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (widget.isListening
                                ? AppTheme.errorRed
                                : AppTheme.primary)
                            .withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.isListening ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: widget.size * 0.45,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
