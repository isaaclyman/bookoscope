import 'package:flutter/material.dart';

Future<T?> showMenuAtContext<T>(
    BuildContext context, List<PopupMenuEntry<T>> items) {
  final RenderBox button = context.findRenderObject()! as RenderBox;
  final RenderBox overlay =
      Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
  final RelativeRect position = RelativeRect.fromRect(
    Rect.fromPoints(
      button.localToGlobal(Offset.zero, ancestor: overlay),
      button.localToGlobal(
        button.size.bottomRight(Offset.zero) + Offset.zero,
        ancestor: overlay,
      ),
    ),
    Offset.zero & overlay.size,
  );
  return showMenu(context: context, position: position, items: items);
}
