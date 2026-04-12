import 'package:flutter/material.dart';

/// 아이템 타입별 아이콘 + 배경색 매핑
class ItemIcon extends StatelessWidget {
  const ItemIcon({required this.itemType, this.size = 32, super.key});

  final String itemType;
  final double size;

  @override
  Widget build(BuildContext context) {
    final config = _iconConfigs[itemType] ?? _defaultConfig;
    final iconSize = size * 0.55;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(config.icon, size: iconSize, color: config.fgColor),
    );
  }
}

class _IconConfig {
  const _IconConfig(this.icon, this.bgColor, this.fgColor);
  final IconData icon;
  final Color bgColor;
  final Color fgColor;
}

const _defaultConfig = _IconConfig(
  Icons.inventory_2,
  Color(0xFFE0E0E0),
  Color(0xFF616161),
);

const _iconConfigs = <String, _IconConfig>{
  'swapOrder': _IconConfig(
    Icons.shuffle_rounded,
    Color(0xFFE3F2FD),
    Color(0xFF1565C0),
  ),
  'shrinkDuration': _IconConfig(
    Icons.hourglass_bottom_rounded,
    Color(0xFFFFF3E0),
    Color(0xFFE65100),
  ),
  'reverseDirection': _IconConfig(
    Icons.swap_horiz_rounded,
    Color(0xFFE8F5E9),
    Color(0xFF2E7D32),
  ),
  'adjustGameDays': _IconConfig(
    Icons.calendar_month_rounded,
    Color(0xFFF3E5F5),
    Color(0xFF7B1FA2),
  ),
};
