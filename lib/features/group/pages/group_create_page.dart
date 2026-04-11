import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bomb_pass/core/constants/app_constants.dart';
import 'package:bomb_pass/features/group/controllers/group_controller.dart';
import '../../../core/router/app_router.dart';

class GroupCreatePage extends ConsumerStatefulWidget {
  const GroupCreatePage({super.key});

  @override
  ConsumerState<GroupCreatePage> createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends ConsumerState<GroupCreatePage> {
  final _nameController = TextEditingController();
  int _maxMembers = 4;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groupControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('그룹 만들기')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 그룹 이름
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '그룹 이름',
                  hintText: '예) 우리반 폭탄돌리기',
                  border: OutlineInputBorder(),
                ),
                maxLength: 20,
              ),
              const SizedBox(height: 24),

              // 참가 인원 슬라이더
              Text(
                '참가 인원: $_maxMembers명',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: _maxMembers.toDouble(),
                min: AppConstants.minGroupSize.toDouble(),
                max: AppConstants.maxGroupSize.toDouble(),
                divisions: AppConstants.maxGroupSize - AppConstants.minGroupSize,
                label: '$_maxMembers명',
                onChanged: (v) => setState(() => _maxMembers = v.toInt()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${AppConstants.minGroupSize}명',
                      style: const TextStyle(color: Colors.grey)),
                  Text('${AppConstants.maxGroupSize}명',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    state.error.toString(),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const Spacer(),

              // 생성 버튼
              ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () async {
                        final name = _nameController.text.trim();
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('그룹 이름을 입력해주세요.')),
                          );
                          return;
                        }
                        final groupId = await ref
                            .read(groupControllerProvider.notifier)
                            .createGroup(name: name, maxMembers: _maxMembers);
                        if (groupId != null && context.mounted) {
                          context.go('${AppRoutes.game}/$groupId');
                        }
                      },
                child: state.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('그룹 만들기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
