import 'package:bomb_pass/features/group/controllers/group_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/audio_service.dart';

class GroupJoinPage extends ConsumerStatefulWidget {
  const GroupJoinPage({super.key, this.initialCode});

  final String? initialCode;

  @override
  ConsumerState<GroupJoinPage> createState() => _GroupJoinPageState();
}

class _GroupJoinPageState extends ConsumerState<GroupJoinPage> {
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(
      text: widget.initialCode?.toUpperCase() ?? '',
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupCtrl = ref.read(groupControllerProvider.notifier);
    final state = ref.watch(groupControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('그룹 참여')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '참여 코드 입력',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  hintText: '6자리 코드를 입력하세요',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    state.error.toString(),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
                onPressed: state.isLoading
                    ? null
                    : () async {
                        ref.read(audioServiceProvider).playSfx('ButtonClickSound1.mp3');
                        final groupId = await groupCtrl.joinGroup(
                          _codeController.text.trim().toUpperCase(),
                        );
                        if (!context.mounted) return;
                        if (groupId != null) {
                          context.go('${AppRoutes.nickname}/$groupId');
                        } else {
                          final err = ref.read(groupControllerProvider).error;
                          if (err != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$err')),
                            );
                          }
                        }
                      },
                icon: state.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: const Text('참여하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
