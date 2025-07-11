import 'package:flutter/material.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

// Enhanced Delete Dialog
Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: context.loc.delete,
    content: context.loc.delete_note_prompt,
    
    // Delete-themed decorations
    titleIcon: Icons.delete_outline,
    titleIconColor: Theme.of(context).colorScheme.error,
    contentIcon: Icons.warning_outlined,
    
    // Enhanced styling
    backgroundColor: Theme.of(context).colorScheme.surface,
    elevation: 10.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
      side: BorderSide(
        color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        width: 1.5,
      ),
    ),
    
    optionsBuilder: () => {
      context.loc.cancel: false,
      context.loc.ok: true,
    },
  ).then((value) => value ?? false);
}
