import 'package:flutter/cupertino.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future <void> showErrorDialog(
  BuildContext context,
  String text
){
  return showGenericDialog(
    context: context, 
    title: context.loc.generic_error_prompt, 
    content: text, 
    optionsBuilder: ()=>{
      context.loc.ok:null,
    },
  );
}