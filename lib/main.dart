// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This example shows how to show the text 'Hello, world.' using the raw
// interface to the engine.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:multi_window/widgets/view_collection.dart';

import 'widgets/binding.dart';

void beginFrame(Duration timeStamp) {
  final double devicePixelRatio = ui.window.devicePixelRatio;
  final ui.Size logicalSize = ui.window.physicalSize / devicePixelRatio;

  final ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
    ui.ParagraphStyle(textDirection: ui.TextDirection.ltr),
  )..addText('Hello, world.');
  final ui.Paragraph paragraph = paragraphBuilder.build()
    ..layout(ui.ParagraphConstraints(width: logicalSize.width));

  final ui.Rect physicalBounds =
      ui.Offset.zero & (logicalSize * devicePixelRatio);
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder, physicalBounds);
  canvas.scale(devicePixelRatio, devicePixelRatio);
  canvas.drawParagraph(
      paragraph,
      ui.Offset(
        (logicalSize.width - paragraph.maxIntrinsicWidth) / 2.0,
        (logicalSize.height - paragraph.height) / 2.0,
      ));
  final ui.Picture picture = recorder.endRecording();

  final ui.SceneBuilder sceneBuilder = ui.SceneBuilder()
    // TODO(abarth): We should be able to add a picture without pushing a
    // container layer first.
    ..pushClipRect(physicalBounds)
    ..addPicture(ui.Offset.zero, picture)
    ..pop();

  ui.window.render(sceneBuilder.build());
}

ui.Picture _createText(String text) {
  final double devicePixelRatio = ui.window.devicePixelRatio;
  final ui.Size logicalSize = ui.window.physicalSize / devicePixelRatio;
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
    ui.ParagraphStyle(textDirection: ui.TextDirection.ltr),
  )..addText(text);
  final ui.Paragraph paragraph = paragraphBuilder.build()
    ..layout(ui.ParagraphConstraints(width: logicalSize.width));
  final ui.Rect physicalBounds =
      ui.Offset.zero & (logicalSize * devicePixelRatio);
  final ui.Canvas canvas = ui.Canvas(recorder, physicalBounds);

  canvas.drawParagraph(
      paragraph,
      ui.Offset(
        (logicalSize.width - paragraph.maxIntrinsicWidth) / 2.0,
        (logicalSize.height - paragraph.height) / 2.0,
      ));
  return recorder.endRecording();
}

ui.Picture _CreateColoredBox(Color color, Size size) {
  Paint paint = Paint();
  paint.color = color;
  ui.PictureRecorder baseRecorder = ui.PictureRecorder();
  Canvas canvas = Canvas(baseRecorder);
  canvas.drawRect(Rect.fromLTRB(0.0, 0.0, size.width, size.height), paint);
  return baseRecorder.endRecording();
}

void _paintMultiView() {
  ui.PlatformDispatcher.instance.onBeginFrame = (Duration duration) {
    Color red = Color.fromARGB(125, 8, 114, 60);
    Size size = Size(700.0, 510.0);
    ui.SceneBuilder builder = ui.SceneBuilder();
    builder.pushOffset(0.0, 0.0);
    builder.addPicture(
        Offset(10.0, 10.0), _CreateColoredBox(red, size)); // red - flutter
    builder.addPicture(Offset(10, 10), _createText('hello world1'));
    Color red1 = Colors.blue;
    Size size1 = Size(150.0, 450.0);
    ui.SceneBuilder builder1 = ui.SceneBuilder();
    builder1.pushClipRRect(RRect.fromRectAndCorners(
        Rect.fromCenter(center: Offset(100, 600), width: 200, height: 200)));
    builder1.addPicture(
        Offset(0, 500.0), _CreateColoredBox(red1, size1)); // red - flutter
    builder1.pop();
    builder.pop();
    ui.FlutterView(0, ui.PlatformDispatcher.instance).render(builder1.build());
    // ui.FlutterView(1, ui.PlatformDispatcher.instance).render(builder.build());
    // ui.PlatformDispatcher.instance.views.first.render(builder.build());
    // ui.PlatformDispatcher.instance.views.last.render(builder1.build());
  };
}

// This function is the primary entry point to your application. The engine
// calls main() as soon as it has loaded your code.
void main(List<String> args) {
  View;
  // ui.MultiView;
  // print("args:" + args.toString());
  // // if (args != null && args.length > 0 && args.first == 'secondWindow') {
  runMultiApp(viewCollection);
  // runApp(Home());
  // runApp;
  // return;
  // }

  // // The engine calls onBeginFrame whenever it wants us to produce a frame.
  // ui.PlatformDispatcher.instance.onBeginFrame = beginFrame;
  // // Here we kick off the whole process by asking the engine to schedule a new
  // // frame. The engine will eventually call onBeginFrame when it is time for us
  // // to actually produce the frame.
  // _paintMultiView();
  // ui.PlatformDispatcher.instance.scheduleFrame();
}

ViewCollection viewCollection() {
  return ViewCollection(
      rootWidget: View(
        child: Home(),
        view: ui.PlatformDispatcher.instance.implicitView!,
      ),
      views: [
        if (RendererBinding.instance.platformDispatcher.views
            .where((element) => element.viewId as int >= 1)
            .isNotEmpty)
          View(
            view: RendererBinding.instance.platformDispatcher.views
                .lastWhere((element) => element.viewId as int >= 1),
            child: Home2(),
          ),
      ]);
}

var cacheString = 1;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

var colorChange = ColorChange(Colors.red);

class ColorChange extends ValueNotifier<Color> {
  ColorChange(value) : super(value);
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  var a = ui.PlatformDispatcher.instance;
  @override
  Widget build(BuildContext context) {
    print('main page');
    print(MediaQuery.of(context).size.width);
    return MaterialApp(
      theme: ThemeData(
          primaryColor: colorChange.value,
          appBarTheme: AppBarTheme(backgroundColor: colorChange.value)),
      home: Scaffold(
        appBar: AppBar(
          title: Text('第一个界面'),
        ),
        body: Center(
          child: TextButton(
            child: Text('切换主题'),
            onPressed: () {
              setState(() {
                var primaryColor = colorChange.value;
                colorChange.value = primaryColor
                    .withBlue(primaryColor.blue + 20)
                    .withGreen(primaryColor.green + 20)
                    .withRed(primaryColor.red - 20);
              });
              // WidgetsBinding.instance.scheduleForcedFrame();
            },
          ),
        ),
      ),
    );
  }
}

class Home2 extends StatefulWidget {
  const Home2({Key? key}) : super(key: key);

  @override
  State<Home2> createState() => _Home2State();
}

class _Home2State extends State<Home2> {
  var a = ui.PlatformDispatcher.instance;
  Color _primaryColor = colorChange.value;
  @override
  void initState() {
    super.initState();
    colorChange.addListener(() {
      setState(() {
        _primaryColor = colorChange.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print(View.of(context).physicalSize);
    print(MediaQuery.of(context).size.width);
    // return Container(width: 100,height: 100,color: Colors.red);
    return MaterialApp(
      theme: ThemeData(
          primaryColor: _primaryColor,
          appBarTheme: AppBarTheme(backgroundColor: _primaryColor)),
      home: Scaffold(
        appBar: AppBar(
          title: Text('第二个界面'),
        ),
      ),
    );
  }
}
