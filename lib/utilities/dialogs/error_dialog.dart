import 'package:flutter/material.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog(
    context: context,
    title: context.loc.generic_error_prompt,
    content: text,
    
    // Error-themed decorations
    titleIcon: Icons.error_outline,
    titleIconColor: Theme.of(context).colorScheme.error,
    contentIcon: Icons.warning_amber_outlined,
    
    // Enhanced styling
    backgroundColor: Theme.of(context).colorScheme.surface,
    elevation: 12.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
      side: BorderSide(
        color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        width: 2.0,
      ),
    ),
    
    // Enhanced button styling
    buttonStyle: ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.error,
      foregroundColor: Theme.of(context).colorScheme.onError,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    
    optionsBuilder: () => {
      context.loc.ok: null,
    },
  );
}