import 'package:flutter/material.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: context.loc.sharing,
    content: context.loc.cannot_share_empty_note_prompt,
    
    // Share-themed decorations
    titleIcon: Icons.share_outlined,
    titleIconColor: Theme.of(context).colorScheme.primary,
    contentIcon: Icons.note_outlined,
    
    // Enhanced styling
    backgroundColor: Theme.of(context).colorScheme.surface,
    elevation: 8.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
      side: BorderSide(
        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        width: 1.0,
      ),
    ),
    
    optionsBuilder: () => {
      context.loc.ok: null,
    },
  );
}