import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wisy_challenge/firebase.repository.dart';
import 'package:wisy_challenge/image.dto.dart';

XFile? _image;

final imageProvider = StateProvider<XFile?>((ref) {
  return _image;
});

class TakeImagePage extends ConsumerWidget {
  TakeImagePage({super.key});

  final ImagePicker imagePicker = ImagePicker();
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final firebaseRepository = FirebaseRepository();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageToUpload = ref.watch(imageProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Upload image'),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 20, bottom: 20),
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor),
              ),
              child: imageToUpload == null
                  ? Icon(
                      Icons.image,
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    )
                  : Image.file(
                      File(imageToUpload.path),
                    ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextFormField(
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name not provided';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter a name for the image',
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  child: const Text('From camera'),
                  onPressed: () async {
                    XFile? file =
                        await imagePicker.pickImage(source: ImageSource.camera);
                    if (file != null) {
                      ref.read(imageProvider.notifier).update((image) => file);
                    }
                  },
                ),
                ElevatedButton(
                  child: const Text('From galery'),
                  onPressed: () async {
                    XFile? file = await imagePicker.pickImage(
                        source: ImageSource.gallery);
                    if (file != null) {
                      ref.read(imageProvider.notifier).update((image) => file);
                    }
                  },
                ),
              ],
            ),
            Container(
              alignment: Alignment.center,
              child: ElevatedButton(
                child: const Text('Submit'),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    if (imageToUpload != null) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: ((BuildContext context) {
                          return AlertDialog(
                            content: FutureBuilder(
                              future: firebaseRepository.uploadImage(
                                ImageDTO(
                                  name: nameController.text,
                                  path: imageToUpload.path,
                                  uploadAt: DateTime.now(),
                                ),
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Container(
                                    padding: const EdgeInsets.all(20),
                                    child: TextButton(
                                      child: const Text('Upload Complete'),
                                      onPressed: () {
                                        ref
                                            .read(imageProvider.notifier)
                                            .update((image) => null);
                                        nameController.clear();
                                        Navigator.pop(context);
                                      },
                                    ),
                                  );
                                }

                                return Row(
                                  children: [
                                    const CircularProgressIndicator(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: const Text('Uploading'),
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        }),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Image not found'),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
