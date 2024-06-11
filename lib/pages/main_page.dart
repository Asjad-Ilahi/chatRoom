import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trictux_chatroom/pages/all_assistants.dart';
import 'package:trictux_chatroom/pages/all_charts.dart';
import 'package:trictux_chatroom/pages/data_input.dart';
import 'package:trictux_chatroom/pages/home_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const AllChatBots(),
    SalesPage(),
    ChartsPage(),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  void _onNavBarTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        color: Theme.of(context).colorScheme.secondary,
        height: 60,
        items: [
          Icon(Icons.chat_outlined, color: Theme.of(context).colorScheme.inversePrimary),
          FaIcon(FontAwesomeIcons.bots, color: Theme.of(context).colorScheme.inversePrimary),
          Icon(Icons.dataset_outlined, color: Theme.of(context).colorScheme.inversePrimary),
          Icon(Icons.bar_chart_outlined, color: Theme.of(context).colorScheme.inversePrimary),
        ],
        index: _pageIndex,
        onTap: _onNavBarTapped,
      ),
    );
  }
}
