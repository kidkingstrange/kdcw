import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps puzzle gameplay screens to bridge Flutter with the device's native IME keyboard
/// (Gboard, Samsung Keyboard, iOS software keyboard).
///
/// Utilizes a transparent native input field with a sentinel space character so that:
/// 1. The native keyboard opens immediately and reliably on mobile devices.
/// 2. Letters entered on any software keyboard auto-advance seamlessly.
/// 3. Backspace on soft keyboards is captured 100% reliably via text deletion.
/// 4. WidgetsBindingObserver recovers IME focus upon app resume.
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

  /// Static helper to explicitly summon the native soft keyboard
  static void requestKeyboard(FocusNode focusNode) {
    focusNode.requestFocus();
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  @override
  State<NativeKeyboardWrapper> createState() => _NativeKeyboardWrapperState();
}

class _NativeKeyboardWrapperState extends State<NativeKeyboardWrapper> with WidgetsBindingObserver {
  late final FocusNode _focusNode;
  static const String _sentinel = ' ';
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = TextEditingController(text: _sentinel);

    // Proactively summon the native software keyboard on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _requestNativeKeyboard();
      }
    });
  }

  void _requestNativeKeyboard() {
    _focusNode.requestFocus();
    SystemChannels.textInput.invokeMethod('TextInput.show');
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
        if (mounted) {
          _requestNativeKeyboard();
        }
      });
    }
  }

  void _resetController() {
    _controller.value = const TextEditingValue(
      text: _sentinel,
      selection: TextSelection.collapsed(offset: 1),
    );
  }

  void _handleChanged(String value) {
    // 1. Backspace detection on software keyboards:
    // When the user taps Backspace on Gboard/Samsung Keyboard, it deletes the sentinel character.
    if (value.isEmpty) {
      widget.onBackspace();
      _resetController();
      return;
    }

    // 2. Letter input detection:
    // Extract any new character(s) typed after/around the sentinel
    final newChars = value.replaceAll(_sentinel, '');
    if (newChars.isNotEmpty) {
      for (var i = 0; i < newChars.length; i++) {
        final ch = newChars[i].toUpperCase();
        if (RegExp(r'[A-Za-z0-9]').hasMatch(ch)) {
          widget.onLetterEntered(ch);
        }
      }
    }

    _resetController();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        widget.onBackspace();
        return KeyEventResult.handled;
      }
      final character = event.character;
      if (character != null && character.isNotEmpty && RegExp(r'[A-Za-z0-9]').hasMatch(character)) {
        widget.onLetterEntered(character.toUpperCase());
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _requestNativeKeyboard();
      },
      child: Stack(
        children: [
          // 1. Main interactive puzzle UI
          widget.child,

          // 2. Native Transparent Input Anchor (placed in layout bounds with minimal opacity so Android IME sees it as active)
          Positioned(
            left: 0,
            top: 0,
            width: 1,
            height: 1,
            child: Opacity(
              opacity: 0.01,
              child: Focus(
                onKeyEvent: _handleKeyEvent,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  showCursor: false,
                  textInputAction: TextInputAction.none,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: _handleChanged,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
