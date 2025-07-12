import 'package:flutter/material.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

// Enhanced Logout Dialog
Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: context.loc.logout_button,
    content: context.loc.logout_dialog_prompt,
    
    // Logout-themed decorations
    titleIcon: Icons.logout_outlined,
    titleColor: Colors.red,
    titleIconColor: Colors.red,
    contentIcon: Icons.exit_to_app_outlined,
    
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
      context.loc.cancel: false,
      context.loc.logout_button: true,
    },
  ).then((value) => value ?? false);
}