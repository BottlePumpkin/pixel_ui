import 'package:flutter/material.dart';
import 'package:pixel_ui/pixel_ui.dart';

import 'widget_tuner.dart';
import 'widgets/box/box_tuner.dart';
import 'widgets/slider/slider_tuner.dart';
import 'widgets/switch/switch_tuner.dart';

typedef WidgetTunerFactory = WidgetTuner Function();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double _wideBreakpoint = 720;

  final List<WidgetTunerFactory> _factories = [
    () => BoxWidgetTuner(),
    () => SwitchWidgetTuner(),
    () => SliderWidgetTuner(),
  ];

  late final List<WidgetTuner?> _tuners =
      List.filled(_factories.length, null, growable: false);

  int _selectedIndex = 0;

  WidgetTuner _ensure(int i) => _tuners[i] ??= _factories[i]();

  @override
  void dispose() {
    for (final t in _tuners) {
      t?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > _wideBreakpoint;
          return SafeArea(
            child: Column(
              children: [
                _Header(narrowMenu: !isWide),
                Expanded(
                  child: isWide
                      ? _WideLayout(
                          tuner: _ensure(_selectedIndex),
                          factories: _factories,
                          selectedIndex: _selectedIndex,
                          onSelected: _select,
                        )
                      : _NarrowLayout(tuner: _ensure(_selectedIndex)),
                ),
              ],
            ),
          );
        },
      ),
      drawer: _NarrowDrawer(
        factories: _factories,
        selectedIndex: _selectedIndex,
        onSelected: (i) {
          _select(i);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _select(int i) {
    if (i == _selectedIndex) return;
    setState(() => _selectedIndex = i);
  }
}

class _Header extends StatelessWidget {
  final bool narrowMenu;
  const _Header({required this.narrowMenu});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF5A8A3A),
      child: Row(
        children: [
          if (narrowMenu)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          Expanded(
            child: Text(
              'PIXEL UI TUNER',
              style: PixelText.mulmaru(
                fontSize: 24,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  final WidgetTuner tuner;
  final List<WidgetTunerFactory> factories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _WideLayout({
    required this.tuner,
    required this.factories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Sidebar(
          factories: factories,
          selectedIndex: selectedIndex,
          onSelected: onSelected,
        ),
        Expanded(
          flex: 35,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: tuner.buildControls(context),
          ),
        ),
        Expanded(
          flex: 65,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                tuner.buildPreview(context),
                tuner.buildCode(context),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  final WidgetTuner tuner;
  const _NarrowLayout({required this.tuner});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          tuner.buildPreview(context),
          const SizedBox(height: 16),
          tuner.buildCode(context),
          const SizedBox(height: 16),
          tuner.buildControls(context),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final List<WidgetTunerFactory> factories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _Sidebar({
    required this.factories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      labelType: NavigationRailLabelType.all,
      backgroundColor: const Color(0xFF22232E),
      indicatorColor: const Color(0xFF5A8A3A),
      selectedLabelTextStyle:
          const TextStyle(color: Color(0xFFFFFFFF), fontSize: 12),
      unselectedLabelTextStyle:
          const TextStyle(color: Color(0xFFB7BCC9), fontSize: 12),
      destinations: [
        for (final factory in factories)
          NavigationRailDestination(
            icon: _IconFromFactory(factory: factory),
            selectedIcon: _IconFromFactory(factory: factory),
            label: Text(_nameFromFactory(factory)),
          ),
      ],
    );
  }
}

String _nameFromFactory(WidgetTunerFactory factory) {
  final t = factory();
  final name = t.name;
  t.dispose();
  return name;
}

class _IconFromFactory extends StatelessWidget {
  final WidgetTunerFactory factory;
  const _IconFromFactory({required this.factory});

  @override
  Widget build(BuildContext context) {
    final t = factory();
    final icon = t.pixelIcon;
    t.dispose();
    return icon;
  }
}

class _NarrowDrawer extends StatelessWidget {
  final List<WidgetTunerFactory> factories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _NarrowDrawer({
    required this.factories,
    required this.selectedIndex,
    required this.onSelected,
  });

  static const _itemStyle = PixelShapeStyle(
    corners: PixelCorners.sm,
    fillColor: Color(0xFF333A4D),
    borderColor: Color(0xFF12141A),
    borderWidth: 1,
  );

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF22232E),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'TUNER',
                  style: PixelText.mulmaru(fontSize: 16, color: Colors.white),
                ),
              ),
              const Divider(color: Color(0xFF3A3A4A)),
              for (var i = 0; i < factories.length; i++) ...[
                PixelListTile(
                  style: _itemStyle,
                  leading: _IconFromFactory(factory: factories[i]),
                  title: Text(
                    _nameFromFactory(factories[i]),
                    style: PixelText.mulmaru(
                      fontSize: 14,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                  trailing: selectedIndex == i
                      ? const Icon(Icons.check, color: Color(0xFFFFD643))
                      : null,
                  onTap: () => onSelected(i),
                ),
                const SizedBox(height: 4),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
