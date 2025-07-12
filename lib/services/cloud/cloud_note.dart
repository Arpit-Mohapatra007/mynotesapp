import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/widgets.dart';

@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName] as String? ?? '',
        text = snapshot.data()[textFieldName] as String? ?? '',
        createdAt = _parseTimestamp(snapshot.data()['created_at']),
        updatedAt = _parseTimestamp(snapshot.data()['updated_at']);

  // Helper method to parse Firestore timestamps
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    } else {
      return DateTime.now(); // Fallback to current time
    }
  }

  // Convert to Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      ownerUserIdFieldName: ownerUserId,
      textFieldName: text,
      createdAtFieldName: Timestamp.fromDate(createdAt),
      updatedAtFieldName: Timestamp.fromDate(updatedAt),
    };
  }

  // Create a copy with updated fields
  CloudNote copyWith({
    String? documentId,
    String? ownerUserId,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CloudNote(
      documentId: documentId ?? this.documentId,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Useful getters
  bool get isEmpty => text.trim().isEmpty;
  bool get isNotEmpty => text.trim().isNotEmpty;
  
  String get preview {
    const maxLength = 100;
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  int get characterCount => text.length;
  int get wordCount => text.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CloudNote &&
        other.documentId == documentId &&
        other.ownerUserId == ownerUserId &&
        other.text == text &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        documentId,
        ownerUserId,
        text,
        createdAt,
        updatedAt,
      );

  @override
  String toString() {
    return 'CloudNote(documentId: $documentId, ownerUserId: $ownerUserId, text: $text, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}