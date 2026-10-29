import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps puzzle gameplay screens to bridge Flutter with the device's native IME keyboard
/// (Gboard, Samsung Keyboard, iOS software keyboard).
///
/// Features WidgetsBindingObserver lifecycle recovery so that backgrounding/resuming the app
/// automatically re-attaches focus without freezing or losing the soft keyboard.
class NativeKeyboardWrapper extends StatefulWidget {
  final Widget child;
  final ValueChanged<String> onLetterEntered;
  final VoidCallback onBackspace;
  final FocusNode? focusNode;

  const NativeKeyboardWrapper({
    super.key,
    required this.child,
    required this.onLetterEntered,
    required this.onBackspace,
    this.focusNode,
  });

  @override
  State<NativeKeyboardWrapper> createState() => _NativeKeyboardWrapperState();
}

class _NativeKeyboardWrapperState extends State<NativeKeyboardWrapper> with WidgetsBindingObserver {
  late final FocusNode _focusNode;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode = widget.focusNode ?? FocusNode();

    // Proactively request keyboard on screen mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  /// Lifecycle Recovery: On app resume (e.g. returning from phone call or lock screen),
  /// re-request IME focus to prevent Android keyboard detachment.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  void _handleChanged(String value) {
    if (value.isEmpty) return;

    final lastChar = value[value.length - 1];
    widget.onLetterEntered(lastChar);

    // Keep hidden buffer empty for next keystroke
    _controller.value = TextEditingValue.empty;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        widget.onBackspace();
        return KeyEventResult.handled;
      }
      final character = event.character;
      if (character != null && character.isNotEmpty && RegExp(r'[A-Za-z0-9]').hasMatch(character)) {
        widget.onLetterEntered(character);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      },
      child: Stack(
        children: [
          // Main interactive UI
          widget.child,

          // Invisible 1-pixel native TextField capturing software keyboard input
          Positioned(
            left: -100,
            top: -100,
            width: 1,
            height: 1,
            child: Focus(
              onKeyEvent: _handleKeyEvent,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                ],
                onChanged: _handleChanged,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
