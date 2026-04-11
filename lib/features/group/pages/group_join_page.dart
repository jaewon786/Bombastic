import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../controllers/group_controller.dart';

class GroupJoinPage extends ConsumerStatefulWidget {
  const GroupJoinPage({super.key});

  @override
  ConsumerState<GroupJoinPage> createState() => _GroupJoinPageState();
}

class _GroupJoinPageState extends ConsumerState<GroupJoinPage> {
  final _codeController = TextEditingController();

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
              const Text('참여 코드 입력', style: TextStyle(fontSize: 20)),
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () async {
                        final groupId = await groupCtrl.joinGroup(
                          _codeController.text.trim(),
                        );
                        if (groupId != null && context.mounted) {
                          context.go('${AppRoutes.game}/$groupId');
                        }
                      },
                child: state.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('참여하기'),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: state.isLoading
                    ? null
                    : () => context.push(AppRoutes.groupCreate),
                child: const Text('새 그룹 만들기'),
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    state.error.toString(),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
