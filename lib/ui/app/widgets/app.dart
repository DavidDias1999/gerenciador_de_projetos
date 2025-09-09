import 'package:flutter/material.dart';
import 'package:gerenciador_de_projetos/ui/projects/widgets/projects.dart';

class AppGDP extends StatefulWidget {
  const AppGDP({super.key});

  @override
  State<AppGDP> createState() => _AppGDPState();
}

class _AppGDPState extends State<AppGDP> {
  int _selectedIndex = 0;

  static const List<String> _title = <String>["Projetos", "Finalizados"];
  static const List<Widget> _mainContents = <Widget>[Projects(), Scaffold()];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(_title[_selectedIndex])),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,

              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },

              labelType: NavigationRailLabelType.all,
              destinations: <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: const Icon(Icons.dashboard),
                  selectedIcon: const Icon(Icons.dashboard_outlined),
                  label: Text(_title[0]),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.source),
                  selectedIcon: const Icon(Icons.source_outlined),
                  label: Text(_title[1]),
                ),
              ],
            ),
            const VerticalDivider(
              thickness: 1,
              width: 1,
              endIndent: 80,
              indent: 10,
            ),
            Expanded(child: _mainContents[_selectedIndex]),
          ],
        ),
      ),
    );
  }
}
