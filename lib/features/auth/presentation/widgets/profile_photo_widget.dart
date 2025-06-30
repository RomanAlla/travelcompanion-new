import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';

class ProfilePhotoWidget extends ConsumerWidget {
  const ProfilePhotoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final isLoading = ref.watch(authProvider).isLoading;

    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: user?.avatarUrl != null
              ? NetworkImage(
                  user!.avatarUrl!,
                  headers: const {
                    'Cache-Control': 'no-cache',
                  },
                )
              : null,
          child: user?.avatarUrl == null
              ? const Icon(Icons.person, size: 50)
              : null,
          onBackgroundImageError: (exception, stackTrace) {

            if (user?.avatarUrl != null) {
              ref.read(authProvider.notifier).updateProfile(
                    userId: user!.id,
                    avatarUrl: null,
                  );
            }
          },
        ),
        if (isLoading)
          const Positioned.fill(
            child: CircularProgressIndicator(),
          ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              onPressed: isLoading
                  ? null
                  : () => ref.read(authProvider.notifier).pickAndUploadPhoto(),
            ),
          ),
        ),
      ],
    );
  }
}
