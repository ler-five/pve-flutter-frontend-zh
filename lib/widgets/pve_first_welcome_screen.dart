import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pve_flutter_frontend/utils/dot_indicator.dart';
import 'package:pve_flutter_frontend/utils/proxmox_colors.dart';
import 'package:pve_flutter_frontend/widgets/firstWelcomeScreen/pve_welcome_logo.dart';
import 'package:pve_flutter_frontend/widgets/firstWelcomeScreen/pve_welcome_faq.dart';
import 'package:pve_flutter_frontend/widgets/firstWelcomeScreen/pve_welcome_ssl_hint.dart';
import 'package:pve_flutter_frontend/widgets/firstWelcomeScreen/pve_welcome_last.dart';

class PveWelcome extends StatefulWidget {
  const PveWelcome({super.key});

  @override
  State<PveWelcome> createState() => _PveWelcomeState();
}

class _PveWelcomeState extends State<PveWelcome> with TickerProviderStateMixin {
  PageController? _controller;
  late SharedPreferences _sharedPreferences;

  final List<Widget> _pages = [
    const PveWelcomePageLogo(),
    const PveWelcomePageSSLValidation(),
    const PveWelcomePageFAQ(),
  ];

  static const Duration _pageChangeDuration = Duration(milliseconds: 150);
  static const Curve _pageChangeCurve = Curves.easeInOut;

  bool _isLast = false;
  bool _isFirst = true;

  final _buttonTextColor = Colors.white;
  final _buttonDisabledTextColor = Colors.white30;

  Future<void> _getPrefs() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void>? _prefs;

  @override
  void initState() {
    super.initState();

    _prefs = _getPrefs();
    _controller = PageController();

    // add last page here so we can define the callback for the start button
    _pages.add(PveWelcomePageLast(onDone: () {
      skipDone();
    }));

    _controller!.addListener(() {
      setState(() {
        _isLast = _controller!.page!.floor() == _pages.length - 1;
        _isFirst = _controller!.page!.floor() == 0;
      });
    });
  }

  Future<void> skipDone() async {
    await _sharedPreferences.setBool('showWelcomeScreen', false);
    Navigator.pushReplacementNamed(context, '/');
  }

  Widget nextDoneButton() {
    if (_isLast) {
      return TextButton(
        style: TextButton.styleFrom(
          foregroundColor: _buttonTextColor,
          disabledForegroundColor: _buttonDisabledTextColor,
        ),
        child: const Text(
          "Done",
        ),
        onPressed: () {
          skipDone();
        },
      );
    } else {
      return TextButton(
        style: TextButton.styleFrom(
          foregroundColor: _buttonTextColor,
          disabledForegroundColor: _buttonDisabledTextColor,
        ),
        onPressed: () {
          _controller!
              .nextPage(duration: _pageChangeDuration, curve: _pageChangeCurve);
        },
        child: const Text("Next"),
      );
    }
  }

  Widget skipPrevButton() {
    if (_isFirst) {
      return TextButton(
        style: TextButton.styleFrom(
          foregroundColor: _buttonTextColor,
          disabledForegroundColor: _buttonDisabledTextColor,
        ),
        onPressed: () {
          skipDone();
        },
        child: const Text(
          'Skip',
        ),
      );
    } else {
      return TextButton(
        style: TextButton.styleFrom(
          foregroundColor: _buttonTextColor,
          disabledForegroundColor: _buttonDisabledTextColor,
        ),
        child: const Text(
          "Prev",
        ),
        onPressed: () {
          _controller!.previousPage(
              duration: _pageChangeDuration, curve: _pageChangeCurve);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProxmoxColors.supportBlue,
      body: DefaultTextStyle(
        style: const TextStyle(color: Colors.white, fontSize: 18),
        child: FutureBuilder<void>(
          future: _prefs,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: _pages.length,
                        itemBuilder: (context, index) {
                          return _pages[index];
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        skipPrevButton(),
                        DotIndicator(
                          controller: _controller!,
                          itemCount: _pages.length,
                          onPageSelected: (int? page) {
                            _controller!.animateToPage(page ?? 0,
                                duration: _pageChangeDuration,
                                curve: _pageChangeCurve);
                          },
                        ),
                        nextDoneButton(),
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
