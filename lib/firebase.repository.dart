import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:wisy_challenge/image.dto.dart';

class FirebaseRepository {
  final _storageInstance = FirebaseStorage.instance;
  final _firestoreInstance = FirebaseFirestore.instance;

  Future uploadImage(ImageDTO image) async {
    try {
      Reference referenceRoot = _storageInstance.ref();
      Reference referenceToUpload = referenceRoot.child(
          '${image.name}-${image.uploadAt.millisecondsSinceEpoch.toString()}');

      await referenceToUpload.putFile(File(image.path));

      image.path = await referenceToUpload.getDownloadURL();

      CollectionReference referenceCollection =
          _firestoreInstance.collection('images');
      await referenceCollection.add(image.toJson());

      return 'Complete';
    } catch (error) {
      rethrow;
    }
  }

  Stream<List<ImageDTO>> getImagesList() {
    final Query query = FirebaseFirestore.instance.collection('images');
    final Stream<QuerySnapshot> snapshots = query.snapshots();

    return snapshots.map((snapshot) {
      final result = snapshot.docs.map((element) {
        return ImageDTO.fromJson(element.data() as Map<String, dynamic>);
      }).toList();
      return result;
    });
  }
}
