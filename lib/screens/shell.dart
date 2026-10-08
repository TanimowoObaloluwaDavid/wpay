import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';
import 'scan.dart';
import 'tabs.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  void _go(int i) => setState(() => _tab = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          HomeTab(onOpenTab: _go),
          StatisticTab(onBack: () => _go(0)),
          NotificationsTab(onBack: () => _go(0)),
          const ProfileTab(),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: _BottomBar(
        index: _tab,
        onTap: _go,
        onScan: () => Navigator.push(context, slideRoute(const ScanScreen())),
      ),
    );
  }
}

/// White bar with the orange scan button raised in the middle (no notch), as in the kit.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onTap, required this.onScan});

  final int index;
  final ValueChanged<int> onTap;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96 + MediaQuery.paddingOf(context).bottom,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 72 + MediaQuery.paddingOf(context).bottom,
            padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, -4)),
              ],
            ),
            child: Row(
              children: [
                _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home', index == 0, () => onTap(0)),
                _NavItem(Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Statistic', index == 1, () => onTap(1)),
                const SizedBox(width: 80),
                _NavItem(
                  Icons.notifications_none_rounded,
                  Icons.notifications_rounded,
                  'Notification',
                  index == 2,
                  () => onTap(2),
                ),
                _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile', index == 3, () => onTap(3)),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: Tooltip(
              message: 'Scan QR',
              child: GestureDetector(
                onTap: onScan,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: WColors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 5),
                    boxShadow: [
                      BoxShadow(
                        color: WColors.orange.withValues(alpha: 0.4),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 26),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem(this.icon, this.activeIcon, this.label, this.active, this.onTap);

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Tooltip(
        message: label,
        child: InkResponse(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(active ? activeIcon : icon, color: active ? WColors.green : WColors.grey, size: 26)],
          ),
        ),
      ),
    );
  }
}
