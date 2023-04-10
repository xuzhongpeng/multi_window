import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ViewCollection {
  final List<View> views;

  final View rootWidget;

  const ViewCollection({required this.rootWidget, required this.views});
}
