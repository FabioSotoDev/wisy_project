import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisy_challenge/firebase.repository.dart';
import 'package:wisy_challenge/take_image.page.dart';

final imagesProvider = StreamProvider((ref) {
  final firebaseRepository = FirebaseRepository();

  return firebaseRepository.getImagesList();
});

class ListImagesPage extends ConsumerWidget {
  const ListImagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesToShow = ref.watch(imagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Uploads'),
      ),
      body: imagesToShow.when(
        data: (images) {
          images.sort(((a, b) {
            return a.uploadAt.millisecondsSinceEpoch -
                b.uploadAt.millisecondsSinceEpoch;
          }));

          return ListView(
            children: images
                .map(
                  (snapshotImage) => ListTile(
                    leading: Image.network(snapshotImage.path),
                    title: Text(snapshotImage.name),
                    subtitle: Text(snapshotImage.uploadAt.toIso8601String()),
                  ),
                )
                .toList(),
          );
        },
        error: (e, st) => Center(child: Text(e.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Upload'),
        icon: const Icon(Icons.upload),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: ((context) => TakeImagePage()),
            ),
          );
        },
      ),
    );
  }
}
