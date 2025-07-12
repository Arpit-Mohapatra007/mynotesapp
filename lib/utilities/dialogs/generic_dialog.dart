import 'package:flutter/material.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionsBuilder,
  // New decorative parameters
  IconData? titleIcon,
  Color? titleColor,
  Color? titleIconColor,
  IconData? contentIcon,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Widget? contentWidget,
  ButtonStyle? buttonStyle,
}) {
  final options = optionsBuilder();
  return showDialog<T>(
    context: context,
    builder: (context) {
      return AlertDialog(
        // Enhanced styling
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
        elevation: elevation ?? 6.0,
        shape: shape ?? RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        
        // Enhanced title with optional icon
        title: titleIcon != null
            ? Row(
                children: [
                  Icon(
                    titleIcon,
                    color: titleIconColor ?? Theme.of(context).colorScheme.primary,
                    size: 24.0,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: titleColor ?? Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
        
        // Enhanced content
        content: contentWidget ??
            (contentIcon != null
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        contentIcon,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20.0,
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          content,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  )
                : Text(
                    content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )),
        
        // Enhanced action buttons
        actions: options.keys.map((optionTitle) {
          final value = options[optionTitle];
          return buttonStyle != null
              ? ElevatedButton(
                  style: buttonStyle,
                  onPressed: () {
                    if (value != null) {
                      Navigator.of(context).pop(value);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(optionTitle),
                )
              : TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    if (value != null) {
                      Navigator.of(context).pop(value);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(optionTitle),
                );
        }).toList(),
      );
    },
  );
}