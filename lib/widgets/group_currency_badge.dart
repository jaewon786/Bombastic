import 'package:bomb_pass/data/firebase/firebase_providers.dart';
import 'package:bomb_pass/widgets/currency_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupCurrencyBadge extends ConsumerWidget {
  const GroupCurrencyBadge({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(groupCurrencyProvider(groupId));

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4D6),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFFFC94A)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CurrencyIcon(size: 16),
              const SizedBox(width: 6),
              Text(
                '$currency',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF5D4037),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
