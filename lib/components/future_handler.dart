import 'package:flutter/material.dart';

class BKFutureHandler<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(
    BuildContext context,
    T data,
  ) builder;
  final String errorMessage;
  final String nullDataMessage;

  const BKFutureHandler({
    super.key,
    required this.future,
    required this.builder,
    required this.errorMessage,
    required this.nullDataMessage,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        Widget child = const Center(
          child: CircularProgressIndicator(),
        );

        final data = snapshot.data;
        if (snapshot.hasError) {
          child = Center(
            child: Text(errorMessage),
          );
        } else if (data != null) {
          child = builder(context, data);
        } else if (snapshot.connectionState == ConnectionState.done) {
          child = Center(
            child: Text(nullDataMessage),
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          child: child,
        );
      },
    );
  }
}
