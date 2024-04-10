import 'package:flutter/material.dart';

class PveQuestion extends StatelessWidget {
  final String? text;

  const PveQuestion({
    super.key,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 5.0, 0.0),
      child: Text(
        text!,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class PveAnswer extends StatelessWidget {
  final String text;
  final List<TextSpan>? spans;

  const PveAnswer({
    super.key,
    required this.text,
    this.spans,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 5.0, 5.0, 5.0),
      child: RichText(
        text: TextSpan(
          text: text,
          style: DefaultTextStyle.of(context).style,
          children: spans,
        ),
      ),
    );
  }
}

class PveWelcomePageContent extends StatelessWidget {
  final Widget? child;
  const PveWelcomePageContent({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500), child: child),
      )),
    );
  }
}
