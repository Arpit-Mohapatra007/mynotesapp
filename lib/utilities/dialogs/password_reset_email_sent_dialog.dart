import 'package:flutter/material.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

// Enhanced Password Reset Dialog
Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: context.loc.password_reset,
    content: context.loc.password_reset_dialog_prompt,
    
    // Password reset themed decorations
    titleIcon: Icons.email_outlined,
    titleIconColor: Theme.of(context).colorScheme.primary,
    contentIcon: Icons.check_circle_outline,
    
    // Enhanced styling
    backgroundColor: Theme.of(context).colorScheme.surface,
    elevation: 8.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
      side: BorderSide(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        width: 1.0,
      ),
    ),
    
    optionsBuilder: () => {
      context.loc.ok: null,
    },
  );
}