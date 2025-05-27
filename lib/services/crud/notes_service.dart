import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class NotesService {
  Database?_db;

  List<DatabaseNote>_notes = [];
  
  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance(){
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: (){
        _notesStreamController.sink.add(_notes);
      }
    );
  }
  factory NotesService() => _shared;

  late final StreamController<List<DatabaseNote>> _notesStreamController;
  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;
  
  Future<DatabaseUser> getOrCreateUser({required String email}) async{
    try{
      return await getUser(email: email);
    } on CouldNotFindUser{
      return await createUser(email: email);
    } catch (e){
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> updateNote({required DatabaseNote note, required String text}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);
    final updateCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });
    if (updateCount==0) {
      throw CouldNotUpdateNote();
    }else{
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note)=> note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((noteRow)=>DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable, limit:1, where: 'ID = ?', whereArgs: [id]);
    if (notes.isEmpty) {
      throw CouldNotFindNote();
    }else{
      final note = DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note)=> note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNotes() async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletion = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletion;
  }

  Future<void>deleteNote({required int id}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(noteTable, where: 'ID = ?', whereArgs: [id]);
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      final countBefore = _notes.length;
      _notes.removeWhere((note)=> note.id == id);
      if (_notes.length != countBefore) {
        _notesStreamController.add(_notes);
      }
    }
  }

  Future <DatabaseNote> createNote({required DatabaseUser owner}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();      
    }
    const text = '';
    final noteId = await db.insert(noteTable, {userIdColumn: owner.id, textColumn: text, isSyncedWithCloudColumn: 1 });

    final note = DatabaseNote(id: noteId, userId: owner.id, text: text, isSyncedWithCloud: true);
    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future <DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable, limit: 1, where: 'EMAIL = ?', whereArgs: [email.toLowerCase()]);
    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else{
      return DatabaseUser.fromRow(results.first);
    }

  }

  Future <DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable, limit: 1, where: 'EMAIL = ?', whereArgs: [email.toLowerCase()]);
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(id: userId, email: email);
  }

  Future <void> deleteUser({required String email}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(userTable,where: 'EMAIL = ?', whereArgs: [email.toLowerCase()]);
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow(){
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    }else{
      return db;
    }
  }
  
  Future <void> close() async{
    final db=_db;
    if (db == null){
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db=null;
    }
    
  }

  Future <void> _ensureDbIsOpen() async{
    try {
      await open();
    } on DatabaseAlreadyOpenException{

    }
  }

  Future <void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path,dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);
      await db.execute(createNotesTable);

      await _cacheNotes();
    } on MissingPlatformDirectoryException{
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id, 
    required this.email,
    });
    DatabaseUser.fromRow(Map<String,Object?>map): id = map[idColumn] as int, email = map[emailColumn] as String;
  @override
  String toString()=> 'Person, ID=$id, email=$email';

  @override
  bool operator ==(covariant DatabaseUser other)=> id==other.id;
  
  @override
  int get hashCode => id.hashCode;
  
}

class DatabaseNote{
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  const DatabaseNote({required this.id, required this.userId, required this.text, required this.isSyncedWithCloud});
  DatabaseNote.fromRow(Map<String,Object?>map): id = map[idColumn] as int, userId = map[userIdColumn] as int, text = map[textColumn] as String, isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int)==1?true:false;
  @override
  String toString()=>'Note, ID = $id, userID = $userId, isSyncedWithCloud = $isSyncedWithCloud';

  @override
  bool operator ==(covariant DatabaseUser other)=> id==other.id;
  
  @override
  int get hashCode => id.hashCode;
}
const dbName = 'notes.db';
const noteTable = 'NOTES';
const userTable = 'USER';
const idColumn = 'ID';
const emailColumn='EMAIL';
const userIdColumn= 'USER_ID';
const textColumn = 'TEXT';
const isSyncedWithCloudColumn = 'IS_SYNCED_WITH_CLOUD';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "USER" (
                                  "ID"	INTEGER NOT NULL,
                                  "EMAIL"	TEXT NOT NULL UNIQUE,
                                  PRIMARY KEY("ID" AUTOINCREMENT)
                                );''';
const createNotesTable = '''CREATE TABLE IF NOT EXISTS "NOTES" (
                                  "ID"	INTEGER NOT NULL,
                                  "USER_ID"	INTEGER NOT NULL,
                                  "TEXT"	TEXT,
                                  "IS_SYNCED_WITH_CLOUD"	INTEGER NOT NULL DEFAULT 0,
                                  PRIMARY KEY("ID" AUTOINCREMENT),
                                  FOREIGN KEY("USER_ID") REFERENCES "USER"("ID")
                                );''';                    
