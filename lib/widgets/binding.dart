import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:multi_window/widgets/view_collection.dart';

typedef ViewCollection ViewCollectionFun();

mixin MyWidgetsBinding
    on
        BindingBase,
        ServicesBinding,
        SchedulerBinding,
        GestureBinding,
        RendererBinding,
        SemanticsBinding {
  static MyWidgetsBinding get instance => BindingBase.checkInstance(_instance);
  static MyWidgetsBinding? _instance;
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
    platformDispatcher.onScheduleWarmUpFrame = _handlePersistentFrameCallback;
  }

  void _handlePersistentFrameCallback(Object id) {
    _attachWidgetList(id);
  }

  Map<Object, MultiViewOwner> multiViewOwnerMaps = {};

  Iterable<MultiViewOwner> get multiViewOwners => multiViewOwnerMaps.values;

  ViewCollectionFun? _viewCollectionFun;
  void _attachWidgetList(Object viewId) {
    var viewCollection = _viewCollectionFun!();
    for (final view in viewCollection.views) {
      if (view.view.viewId != viewId) break;
      var buildOwner = BuildOwner();
      buildOwner.onBuildScheduled = _handleBuildScheduled;
      final pipelineOwner = PipelineOwner();
      WidgetsBinding.instance.pipelineOwner.adoptChild(pipelineOwner);
      final renderView = RenderView(
          configuration: createViewConfigurationByView(view.view),
          view: view.view);
      pipelineOwner.rootNode = renderView;
      renderView.prepareInitialFrame();
      var element = RenderObjectToWidgetAdapter<RenderBox>(
        container: renderView,
        debugShortDescription: view.child.toStringShort(),
        child: view,
      ).attachToRenderTree(buildOwner, null);
      multiViewOwnerMaps[viewId] = MultiViewOwner(
          element: element,
          buildOwner: buildOwner,
          renderView: renderView,
          flutterView: view.view);
      // scheduleWarmUpFrame();
    }
  }

  @override
  void handleMetricsChanged(Object viewId) {
    var multiViewOwner = multiViewOwnerMaps[viewId];
    if (multiViewOwner != null) {
      multiViewOwner.renderView.configuration =
          createViewConfigurationByView(multiViewOwner.flutterView);
      if (multiViewOwner.renderView.child != null) {
        scheduleForcedFrame();
      }
    }
  }

  @override
  void hitTestByViewId(int viewId, HitTestResult result, Offset position) {
    var multiViewOwner = multiViewOwnerMaps[viewId];
    if (multiViewOwner != null) {
      multiViewOwner.renderView.hitTest(result, position: position);
      result.add(HitTestEntry(this));
    }
  }

  @override
  Future<void> performReassemble() {
    assert(() {
      WidgetInspectorService.instance.performReassemble();
      return true;
    }());

    for (MultiViewOwner multiViewOwner in multiViewOwners) {
      multiViewOwner.buildOwner.reassemble(
          multiViewOwner.element, BindingBase.debugReassembleConfig);
    }
    return super.performReassemble();
  }

  void attachWidget({ViewCollectionFun? viewCollectionFun}) {
    // setRoot
    _viewCollectionFun ??= viewCollectionFun;
    var viewCollection = _viewCollectionFun!();
    var buildOwner = BuildOwner();
    buildOwner.onBuildScheduled = _handleBuildScheduled;
    var element = RenderObjectToWidgetAdapter<RenderBox>(
      container: renderView,
      debugShortDescription: 'root',
      child: viewCollection.rootWidget,
    ).attachToRenderTree(buildOwner, null);
    multiViewOwnerMaps[platformDispatcher.implicitView!.viewId] =
        (MultiViewOwner(
            element: element,
            buildOwner: buildOwner,
            renderView: renderView,
            flutterView: platformDispatcher.implicitView!));
    scheduleWarmUpFrame();
    ensureVisualUpdate();
  }

  bool _needToReportFirstFrame = true;
  final Completer<void> _firstFrameCompleter = Completer<void>();
  @override
  void drawFrame() {
    TimingsCallback? firstFrameCallback;
    if (_needToReportFirstFrame) {
      assert(!_firstFrameCompleter.isCompleted);

      firstFrameCallback = (List<FrameTiming> timings) {
        assert(sendFramesToEngine);
        if (!kReleaseMode) {
          // Change the current user tag back to the default tag. At this point,
          // the user tag should be set to "AppStartUp" (originally set in the
          // engine), so we need to change it back to the default tag to mark
          // the end of app start up for CPU profiles.
          developer.UserTag.defaultTag.makeCurrent();
          developer.Timeline.instantSync('Rasterized first useful frame');
          developer.postEvent('Flutter.FirstFrame', <String, dynamic>{});
        }
        SchedulerBinding.instance.removeTimingsCallback(firstFrameCallback!);
        firstFrameCallback = null;
        _firstFrameCompleter.complete();
      };
      // Callback is only invoked when FlutterView.render is called. When
      // sendFramesToEngine is set to false during the frame, it will not be
      // called and we need to remove the callback (see below).
      SchedulerBinding.instance.addTimingsCallback(firstFrameCallback!);
    }

    try {
      for (MultiViewOwner multiViewOwner in multiViewOwners) {
        multiViewOwner.buildOwner.buildScope(multiViewOwner.element);
        multiViewOwner.buildOwner.finalizeTree();
      }
      super.drawFrame();
    } finally {}
    if (!kReleaseMode) {
      if (_needToReportFirstFrame && sendFramesToEngine) {
        developer.Timeline.instantSync('Widgets built first useful frame');
      }
    }
    _needToReportFirstFrame = false;
    if (firstFrameCallback != null && !sendFramesToEngine) {
      // This frame is deferred and not the first frame sent to the engine that
      // should be reported.
      _needToReportFirstFrame = true;
      SchedulerBinding.instance.removeTimingsCallback(firstFrameCallback!);
    }
  }

  void _handleBuildScheduled() {
    ensureVisualUpdate();
  }

  ViewConfiguration createViewConfigurationByView(FlutterView view) {
    final double devicePixelRatio = view.devicePixelRatio;
    return ViewConfiguration(
      size: view.physicalSize / devicePixelRatio,
      devicePixelRatio: devicePixelRatio,
    );
  }
}

class MultiViewOwner {
  final Element element;
  final BuildOwner buildOwner;
  final RenderView renderView;
  final FlutterView flutterView;

  MultiViewOwner({
    required this.element,
    required this.buildOwner,
    required this.renderView,
    required this.flutterView,
  });
}

class MyWidgetsFlutterBinding extends BindingBase
    with
        GestureBinding,
        SchedulerBinding,
        ServicesBinding,
        PaintingBinding,
        SemanticsBinding,
        RendererBinding,
        WidgetsBinding,
        MyWidgetsBinding {
  /// Returns an instance of the binding that implements
  /// [WidgetsBinding]. If no binding has yet been initialized, the
  /// [WidgetsFlutterBinding] class is used to create and initialize
  /// one.
  ///
  /// You only need to call this method if you need the binding to be
  /// initialized before calling [runApp].
  ///
  /// In the `flutter_test` framework, [testWidgets] initializes the
  /// binding instance to a [TestWidgetsFlutterBinding], not a
  /// [WidgetsFlutterBinding]. See
  /// [TestWidgetsFlutterBinding.ensureInitialized].
  static MyWidgetsBinding ensureInitialized() {
    // WidgetsFlutterBinding.ensureInitialized();
    if (MyWidgetsBinding._instance == null) {
      MyWidgetsFlutterBinding();
    }
    return MyWidgetsBinding.instance;
  }
}

void runMultiApp(ViewCollectionFun viewCollectionFun) {
  final MyWidgetsBinding binding = MyWidgetsFlutterBinding.ensureInitialized();
  binding.attachWidget(viewCollectionFun: viewCollectionFun);
}

class _BindingPipelineManifold extends ChangeNotifier
    implements PipelineManifold {
  _BindingPipelineManifold(this._binding) {
    _binding.addSemanticsEnabledListener(notifyListeners);
  }

  final RendererBinding _binding;

  @override
  void requestVisualUpdate() {
    _binding.ensureVisualUpdate();
  }

  @override
  bool get semanticsEnabled => _binding.semanticsEnabled;

  @override
  void dispose() {
    _binding.removeSemanticsEnabledListener(notifyListeners);
    super.dispose();
  }
}
