import 'package:flutter/widgets.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<bool>showDeleteDialog(BuildContext context){
  return showGenericDialog<bool>(
    context: context, 
    title: context.loc.delete, 
    content: context.loc.delete_note_prompt, 
    optionsBuilder: ()=>{
      context.loc.cancel:false,
      context.loc.ok: true,
    },
  ).then((value)=>value ?? false);
}
