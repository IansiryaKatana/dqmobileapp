import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Push a full-screen route above the tab shell.
void pushRootRoute(BuildContext context, String location, {Object? extra}) {
  GoRouter.of(context).push(location, extra: extra);
}
