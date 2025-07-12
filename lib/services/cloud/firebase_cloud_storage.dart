import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> deleteNote({required String documentId}) async{
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({required String documentId, required String text}) async {
    try{
      await notes.doc(documentId).update({
        textFieldName: text,
        updatedAtFieldName: FieldValue.serverTimestamp(),
      });
    } catch(e){
      throw CouldNotUpdateNoteException();
    }
  }

  Stream<Iterable<CloudNote>>allNotes({required String ownerUserId})=>
    notes.where(ownerUserIdFieldName,isEqualTo: ownerUserId).snapshots().map((event)=>event.docs
      .map((doc)=> CloudNote.fromSnapshot(doc)));

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    try {
      final document = await notes.add({
        ownerUserIdFieldName: ownerUserId,
        textFieldName: '',
        createdAtFieldName: FieldValue.serverTimestamp(),
        updatedAtFieldName: FieldValue.serverTimestamp(),
      });
      
      // Fetch the document again to get the actual server timestamps
      final fetchedNote = await document.get();
      return CloudNote.fromSnapshot(fetchedNote as QueryDocumentSnapshot<Map<String, dynamic>>);
    } catch (e) {
      throw CouldNotCreateNoteException();
    }
  }

  static final FirebaseCloudStorage _shared= 
    FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}