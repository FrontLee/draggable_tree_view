// Copyright ©2021 OrTrue. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Author: FrontLee(李锋)<ortrue@163.com>
// Changes based on the reorderable_list.dart

import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

///  * [DraggableList], a widget list that allows the user to drag
///    its items.
///  * [SliverDraggableList], a sliver list that allows the user to drag
///    its items.
///  * [DraggableListView], a material design list that allows the user to
///    drag its items.
typedef DragEndCallback = void Function(int oldIndex, int newIndex, int newPos);

typedef DragStartCallback = void Function(int index, double start, double end);

typedef DragingCallback = void Function(
    int oldIndex, int newIndex, int newPos, double start, double end);

typedef DragCancelCallback = void Function();

/// Signature for the builder callback used to decorate the dragging item in
/// [DraggableList] and [SliverDraggableList].
///
/// The [child] will be the item that is being dragged, and [index] is the
/// position of the item in the list.
///
/// The [animation] will be driven forward from 0.0 to 1.0 while the item is
/// being picked up during a drag operation, and reversed from 1.0 to 0.0 when
/// the item is dropped. This can be used to animate properties of the proxy
/// like an elevation or border.
///
/// The returned value will typically be the [child] wrapped in other widgets.
typedef DraggableItemProxyDecorator = Widget Function(
    Widget child, int index, Animation<double> animation);

/// A scrolling container that allows the user to interactively drag the
/// list items.
///
/// This widget is similar to one created by [ListView.builder], and uses
/// an [IndexedWidgetBuilder] to create each item.
///
/// It is up to the application to wrap each child (or an internal part of the
/// child such as a drag handle) with a drag listener that will recognize
/// the start of an item drag and then start the drag by calling
/// [DraggableListState.startItemDrag]. This is most easily achieved
/// by wrapping each child in a [DraggableDragStartListener] or a
/// [DraggableDelayedDragStartListener]. These will take care of recognizing
/// the start of a drag gesture and call the list state's
/// [DraggableListState.startItemDrag] method.
///
/// This widget's [DraggableListState] can be used to manually start an item
/// drag, or cancel a current drag. To refer to the
/// [DraggableListState] either provide a [GlobalKey] or use the static
/// [DraggableList.of] method from an item's build method.
///
/// See also:
///
///  * [SliverDraggableList], a sliver list that allows the user to drag
///    its items.
///  * [DraggableListView], a material design list that allows the user to
///    drag its items.
class DraggableList extends StatefulWidget {
  /// Creates a scrolling container that allows the user to interactively
  /// drag the list items.
  ///
  /// The [itemCount] must be greater than or equal to zero.
  const DraggableList({
    Key key,
    @required this.itemBuilder,
    @required this.itemCount,
    @required this.onDragEnd,
    @required this.onDragStart,
    @required this.onDraging,
    @required this.onDragCancel,
    this.proxyDecorator,
    this.padding,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.anchor = 0.0,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  })  : assert(itemCount >= 0),
        super(key: key);

  /// {@template flutter.widgets.Draggable_list.itemBuilder}
  /// Called, as needed, to build list item widgets.
  ///
  /// List items are only built when they're scrolled into view.
  ///
  /// The [IndexedWidgetBuilder] index parameter indicates the item's
  /// position in the list. The value of the index parameter will be between
  /// zero and one less than [itemCount]. All items in the list must have a
  /// unique [Key], and should have some kind of listener to start the drag
  /// (usually a [DraggableDragStartListener] or
  /// [DraggableDelayedDragStartListener]).
  /// {@endtemplate}
  final IndexedWidgetBuilder itemBuilder;

  /// {@template flutter.widgets.Draggable_list.itemCount}
  /// The number of items in the list.
  ///
  /// It must be a non-negative integer. When zero, nothing is displayed and
  /// the widget occupies no space.
  /// {@endtemplate}
  final int itemCount;

  /// {@template flutter.widgets.Draggable_list.onDragEnd}
  /// A callback used by the list to report that a list item has been dragged
  /// to a new location in the list and the application should update the order
  /// of the items.
  /// {@endtemplate}
  final DragEndCallback onDragEnd;

  final DragStartCallback onDragStart;

  final DragingCallback onDraging;

  final DragCancelCallback onDragCancel;

  /// {@template flutter.widgets.Draggable_list.proxyDecorator}
  /// A callback that allows the app to add an animated decoration around
  /// an item when it is being dragged.
  /// {@endtemplate}
  final DraggableItemProxyDecorator proxyDecorator;

  /// {@template flutter.widgets.Draggable_list.padding}
  /// The amount of space by which to inset the list contents.
  ///
  /// It defaults to `EdgeInsets.all(0)`.
  /// {@endtemplate}
  final EdgeInsetsGeometry padding;

  /// {@macro flutter.widgets.scroll_view.scrollDirection}
  final Axis scrollDirection;

  /// {@macro flutter.widgets.scroll_view.reverse}
  final bool reverse;

  /// {@macro flutter.widgets.scroll_view.controller}
  final ScrollController controller;

  /// {@macro flutter.widgets.scroll_view.primary}
  final bool primary;

  /// {@macro flutter.widgets.scroll_view.physics}
  final ScrollPhysics physics;

  /// {@macro flutter.widgets.scroll_view.shrinkWrap}
  final bool shrinkWrap;

  /// {@macro flutter.widgets.scroll_view.anchor}
  final double anchor;

  /// {@macro flutter.rendering.RenderViewportBase.cacheExtent}
  final double cacheExtent;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// {@macro flutter.widgets.scroll_view.keyboardDismissBehavior}
  ///
  /// The default is [ScrollViewKeyboardDismissBehavior.manual]
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// {@macro flutter.widgets.scrollable.restorationId}
  final String restorationId;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [DraggableList] item widgets that
  /// insert or remove items in response to user input.
  ///
  /// If no [DraggableList] surrounds the given context, then this function
  /// will assert in debug mode and throw an exception in release mode.
  ///
  /// See also:
  ///
  ///  * [maybeOf], a similar function that will return null if no
  ///    [DraggableList] ancestor is found.
  static DraggableListState of(BuildContext context) {
    assert(context != null);
    final DraggableListState result =
        context.findAncestorStateOfType<DraggableListState>();
    assert(() {
      if (result == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
              'DraggableList.of() called with a context that does not contain a DraggableList.'),
          ErrorDescription(
              'No DraggableList ancestor could be found starting from the context that was passed to DraggableList.of().'),
          ErrorHint(
              'This can happen when the context provided is from the same StatefulWidget that '
              'built the DraggableList. Please see the DraggableList documentation for examples '
              'of how to refer to an DraggableListState object:'
              '  https://api.flutter.dev/flutter/widgets/DraggableListState-class.html'),
          context.describeElement('The context used was')
        ]);
      }
      return true;
    }());
    return result;
  }

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [DraggableList] item widgets that insert
  /// or remove items in response to user input.
  ///
  /// If no [DraggableList] surrounds the context given, then this function will
  /// return null.
  ///
  /// See also:
  ///
  ///  * [of], a similar function that will throw if no [DraggableList] ancestor
  ///    is found.
  static DraggableListState maybeOf(BuildContext context) {
    assert(context != null);
    return context.findAncestorStateOfType<DraggableListState>();
  }

  @override
  DraggableListState createState() => DraggableListState();
}

/// The state for a list that allows the user to interactively drag
/// the list items.
///
/// An app that needs to start a new item drag or cancel an existing one
/// can refer to the [DraggableList]'s state with a global key:
///
/// ```dart
/// GlobalKey<DraggableListState> listKey = GlobalKey<DraggableListState>();
/// ...
/// DraggableList(key: listKey, ...);
/// ...
/// listKey.currentState.cancelDrag();
/// ```
class DraggableListState extends State<DraggableList> {
  final GlobalKey<SliverDraggableListState> _sliverDraggableListKey =
      GlobalKey();

  /// Initiate the dragging of the item at [index] that was started with
  /// the pointer down [event].
  ///
  /// The given [recognizer] will be used to recognize and start the drag
  /// item tracking and lead to either an item drag, or a cancelled drag.
  /// The list will take ownership of the returned recognizer and will dispose
  /// it when it is no longer needed.
  ///
  /// Most applications will not use this directly, but will wrap the item
  /// (or part of the item, like a drag handle) in either a
  /// [DraggableDragStartListener] or [DraggableDelayedDragStartListener]
  /// which call this for the application.
  void startItemDrag({
    @required int index,
    @required PointerDownEvent event,
    @required MultiDragGestureRecognizer<MultiDragPointerState> recognizer,
  }) {
    _sliverDraggableListKey.currentState
        .startItemDrag(index: index, event: event, recognizer: recognizer);
  }

  /// Cancel any item drag in progress.
  ///
  /// This should be called before any major changes to the item list
  /// occur so that any item drags will not get confused by
  /// changes to the underlying list.
  ///
  /// If no drag is active, this will do nothing.
  void cancelDrag() {
    _sliverDraggableListKey.currentState.cancelDrag();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      anchor: widget.anchor,
      cacheExtent: widget.cacheExtent,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      slivers: <Widget>[
        SliverPadding(
          padding: widget.padding ?? EdgeInsets.zero,
          sliver: SliverDraggableList(
            key: _sliverDraggableListKey,
            itemBuilder: widget.itemBuilder,
            itemCount: widget.itemCount,
            onDragStart: widget.onDragStart,
            onDragEnd: widget.onDragEnd,
            onDraging: widget.onDraging,
            onDragCancel: widget.onDragCancel,
            proxyDecorator: widget.proxyDecorator,
          ),
        ),
      ],
    );
  }
}

/// A sliver list that allows the user to interactively drag the list items.
///
/// It is up to the application to wrap each child (or an internal part of the
/// child) with a drag listener that will recognize the start of an item drag
/// and then start the drag by calling
/// [SliverDraggableListState.startItemDrag]. This is most easily
/// achieved by wrapping each child in a [DraggableDragStartListener] or
/// a [DraggableDelayedDragStartListener]. These will take care of
/// recognizing the start of a drag gesture and call the list state's start
/// item drag method.
///
/// This widget's [SliverDraggableListState] can be used to manually start an item
/// drag, or cancel a current drag that's already underway. To refer to the
/// [SliverDraggableListState] either provide a [GlobalKey] or use the static
/// [SliverDraggableList.of] method from an item's build method.
///
/// See also:
///
///  * [DraggableList], a regular widget list that allows the user to drag
///    its items.
///  * [DraggableListView], a material design list that allows the user to
///    drag its items.
class SliverDraggableList extends StatefulWidget {
  /// Creates a sliver list that allows the user to interactively drag its
  /// items.
  ///
  /// The [itemCount] must be greater than or equal to zero.
  const SliverDraggableList({
    Key key,
    @required this.itemBuilder,
    @required this.itemCount,
    @required this.onDragEnd,
    @required this.onDragStart,
    @required this.onDraging,
    @required this.onDragCancel,
    this.proxyDecorator,
  })  : assert(itemCount >= 0),
        super(key: key);

  /// {@macro flutter.widgets.Draggable_list.itemBuilder}
  final IndexedWidgetBuilder itemBuilder;

  /// {@macro flutter.widgets.Draggable_list.itemCount}
  final int itemCount;

  /// {@macro flutter.widgets.Draggable_list.onDragEnd}
  final DragEndCallback onDragEnd;

  final DragStartCallback onDragStart;

  final DragingCallback onDraging;

  final DragCancelCallback onDragCancel;

  /// {@macro flutter.widgets.Draggable_list.proxyDecorator}
  final DraggableItemProxyDecorator proxyDecorator;

  @override
  SliverDraggableListState createState() => SliverDraggableListState();

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [SliverDraggableList] item widgets to
  /// start or cancel an item drag operation.
  ///
  /// If no [SliverDraggableList] surrounds the context given, this function
  /// will assert in debug mode and throw an exception in release mode.
  ///
  /// See also:
  ///
  ///  * [maybeOf], a similar function that will return null if no
  ///    [SliverDraggableList] ancestor is found.
  static SliverDraggableListState of(BuildContext context) {
    assert(context != null);
    final SliverDraggableListState result =
        context.findAncestorStateOfType<SliverDraggableListState>();
    assert(() {
      if (result == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
              'SliverDraggableList.of() called with a context that does not contain a SliverDraggableList.'),
          ErrorDescription(
              'No SliverDraggableList ancestor could be found starting from the context that was passed to SliverDraggableList.of().'),
          ErrorHint(
              'This can happen when the context provided is from the same StatefulWidget that '
              'built the SliverDraggableList. Please see the SliverDraggableList documentation for examples '
              'of how to refer to an SliverDraggableList object:'
              '  https://api.flutter.dev/flutter/widgets/SliverDraggableListState-class.html'),
          context.describeElement('The context used was')
        ]);
      }
      return true;
    }());
    return result;
  }

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [SliverDraggableList] item widgets that
  /// insert or remove items in response to user input.
  ///
  /// If no [SliverDraggableList] surrounds the context given, this function
  /// will return null.
  ///
  /// See also:
  ///
  ///  * [of], a similar function that will throw if no [SliverDraggableList]
  ///    ancestor is found.
  static SliverDraggableListState maybeOf(BuildContext context) {
    assert(context != null);
    return context.findAncestorStateOfType<SliverDraggableListState>();
  }
}

/// The state for a sliver list that allows the user to interactively drag
/// the list items.
///
/// An app that needs to start a new item drag or cancel an existing one
/// can refer to the [SliverDraggableList]'s state with a global key:
///
/// ```dart
/// GlobalKey<SliverDraggableListState> listKey = GlobalKey<SliverDraggableListState>();
/// ...
/// SliverDraggableList(key: listKey, ...);
/// ...
/// listKey.currentState.cancelDrag();
/// ```
///
/// [DraggableDragStartListener] and [DraggableDelayedDragStartListener]
/// refer to their [SliverDraggableList] with the static
/// [SliverDraggableList.of] method.
class SliverDraggableListState extends State<SliverDraggableList>
    with TickerProviderStateMixin {
  // Map of index -> child state used manage where the dragging item will need
  // to be inserted.
  final Map<int, _DraggableItemState> _items = <int, _DraggableItemState>{};

  bool _reorderingDrag = false;
  bool _autoScrolling = false;
  OverlayEntry _overlayEntry;
  _DraggableItemState _dragItem;
  _DragInfo _dragInfo;
  int _insertIndex;
  int _insertPos; // 1-前 2-中 3-后
  Offset _finalDropPosition;
  MultiDragGestureRecognizer<MultiDragPointerState> _recognizer;

  ScrollableState _scrollable;
  Axis get _scrollDirection => axisDirectionToAxis(_scrollable.axisDirection);
  bool get _reverse =>
      _scrollable.axisDirection == AxisDirection.up ||
      _scrollable.axisDirection == AxisDirection.left;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollable = Scrollable.of(context);
  }

  @override
  void didUpdateWidget(covariant SliverDraggableList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemCount != oldWidget.itemCount) {
      cancelDrag();
    }
  }

  @override
  void dispose() {
    _dragInfo?.dispose();
    super.dispose();
  }

  /// Initiate the dragging of the item at [index] that was started with
  /// the pointer down [event].
  ///
  /// The given [recognizer] will be used to recognize and start the drag
  /// item tracking and lead to either an item drag, or a cancelled drag.
  ///
  /// Most applications will not use this directly, but will wrap the item
  /// (or part of the item, like a drag handle) in either a
  /// [DraggableDragStartListener] or [DraggableDelayedDragStartListener]
  /// which call this method when they detect the gesture that triggers a drag
  /// start.
  void startItemDrag({
    @required int index,
    @required PointerDownEvent event,
    @required MultiDragGestureRecognizer<MultiDragPointerState> recognizer,
  }) {
    assert(0 <= index && index < widget.itemCount);
    setState(() {
      if (_reorderingDrag) {
        cancelDrag();
      }
      if (_items.containsKey(index)) {
        _dragItem = _items[index];
        _recognizer = recognizer
          ..onStart = _dragStart
          ..addPointer(event);
      } else {
        throw Exception('Attempting to start a drag on a non-visible item');
      }
    });
  }

  /// Cancel any item drag in progress.
  ///
  /// This should be called before any major changes to the item list
  /// occur so that any item drags will not get confused by
  /// changes to the underlying list.
  ///
  /// If a drag operation is in progress, this will immediately reset
  /// the list to back to its pre-drag state.
  ///
  /// If no drag is active, this will do nothing.
  void cancelDrag() {
    if (_reorderingDrag) widget.onDragCancel();
    _dragReset();
  }

  void _registerItem(_DraggableItemState item) {
    _items[item.index] = item;
  }

  void _unregisterItem(int index, _DraggableItemState item) {
    final _DraggableItemState currentItem = _items[index];
    if (currentItem == item) {
      _items.remove(index);
    }
  }

  Drag _dragStart(Offset position) {
    assert(_reorderingDrag == false);
    final _DraggableItemState item = _dragItem;

    _insertIndex = item.index;
    _reorderingDrag = true;
    // todo 替换为目标位置标识
    _dragInfo = _DragInfo(
      item: item,
      initialPosition: position,
      scrollDirection: _scrollDirection,
      onUpdate: _dragUpdate,
      onCancel: _dragCancel,
      onEnd: _dragEnd,
      onDropCompleted: _dropCompleted,
      proxyDecorator: widget.proxyDecorator,
      tickerProvider: this,
    );

    // final OverlayState overlay = Overlay.of(context);
    // assert(_overlayEntry == null);
    // _overlayEntry = OverlayEntry(builder: _dragInfo.createProxy);
    // overlay.insert(_overlayEntry);

    _dragInfo.startDrag();

    item.dragging = true;
    // for (final _DraggableItemState childItem in _items.values) {
    //   if (childItem == item || !childItem.mounted) continue;
    //   childItem.updateForGap(
    //       _insertIndex, 2, _dragInfo.itemExtent, false, _reverse);
    // }
    final double itemStart = _offsetExtent(
        _dragInfo.dragPosition - _dragInfo.dragOffset, _scrollDirection);
    final double itemEnd = itemStart + _dragInfo.itemExtent;

    widget.onDragStart.call(_insertIndex, itemStart, itemEnd);
    return _dragInfo;
  }

  void _dragUpdate(_DragInfo item, Offset position, Offset delta) {
    setState(() {
      _overlayEntry?.markNeedsBuild();
      _dragUpdateItems();
      _autoScrollIfNecessary();
    });
  }

  void _dragCancel(_DragInfo item) {
    if (_reorderingDrag) widget.onDragCancel.call();
    _dragReset();
  }

  void _dragEnd(_DragInfo item) {
    setState(() {
      if (_insertIndex < widget.itemCount - 1) {
        // Find the location of the item we want to insert before
        _finalDropPosition = _itemOffsetAt(_insertIndex);
      } else {
        // Inserting into the last spot on the list. If it's the only spot, put
        // it back where it was. Otherwise, grab the second to last and move
        // down by the gap.
        final int itemIndex =
            _items.length > 1 ? _insertIndex - 1 : _insertIndex;
        if (_reverse) {
          _finalDropPosition = _itemOffsetAt(itemIndex) -
              _extentOffset(item.itemExtent, _scrollDirection);
        } else {
          _finalDropPosition = _itemOffsetAt(itemIndex) +
              _extentOffset(item.itemExtent, _scrollDirection);
        }
      }
    });
  }

  void _dropCompleted() {
    final int fromIndex = _dragItem.index;
    final int toIndex = _insertIndex;
    final int toPos = _insertPos;
    widget.onDragEnd.call(fromIndex, toIndex, toPos);
    _dragReset();
  }

  void _dragReset() {
    setState(() {
      if (_reorderingDrag) {
        _reorderingDrag = false;
        _dragItem.dragging = false;
        _dragItem = null;
        _dragInfo?.dispose();
        _dragInfo = null;
        _resetItemGap();
        _recognizer?.dispose();
        _recognizer = null;
        _overlayEntry?.remove();
        _overlayEntry = null;
        _finalDropPosition = null;
      }
    });
  }

  void _resetItemGap() {
    for (final _DraggableItemState item in _items.values) {
      item.resetGap();
    }
  }

  void _dragUpdateItems() {
    assert(_reorderingDrag);
    assert(_dragItem != null);
    assert(_dragInfo != null);
    final _DraggableItemState gapItem = _dragItem;
    final double proxyItemStart = _offsetExtent(
            _dragInfo.dragPosition - _dragInfo.dragOffset, _scrollDirection) +
        _dragInfo.itemExtent / 2;

    // Find the new index for inserting the item being dragged.
    int newIndex = _insertIndex;
    int newPos = 2;

    bool found = false;
    double itemStart = 0;
    double itemEnd = 0;
    for (final _DraggableItemState item in _items.values) {
      if (item == gapItem || !item.mounted) continue;

      final Rect geometry = item.targetGeometry();
      itemStart =
          _scrollDirection == Axis.vertical ? geometry.top : geometry.left;
      final double itemExtent =
          _scrollDirection == Axis.vertical ? geometry.height : geometry.width;
      itemEnd = itemStart + itemExtent;
      final double itemUpper = itemStart + itemExtent / 3;
      final double itemLower = itemUpper + itemExtent / 3;

      if (_reverse) {
        if (proxyItemStart >= itemStart && proxyItemStart <= itemEnd) {
          newIndex = item.index;
          if (proxyItemStart <= itemUpper) {
            newPos = 3;
          } else if (proxyItemStart <= itemLower) {
            newPos = 2;
          } else {
            newPos = 1;
          }
          found = true;
          break;
        }
      } else {
        if (proxyItemStart >= itemStart && proxyItemStart <= itemEnd) {
          newIndex = item.index;
          if (proxyItemStart <= itemUpper) {
            newPos = 1;
          } else if (proxyItemStart <= itemLower) {
            newPos = 2;
          } else {
            newPos = 3;
          }
          found = true;
          break;
        }
      }
    }
    if (!found) return;
    if (newIndex != _insertIndex || newPos != _insertPos) {
      _insertIndex = newIndex;
      _insertPos = newPos;
      widget.onDraging
          .call(_dragItem.index, _insertIndex, _insertPos, itemStart, itemEnd);
      // for (final _DraggableItemState item in _items.values) {
      //   if (item == gapItem || !item.mounted) continue;
      //   item.updateForGap(newIndex, _insertPos, gapExtent, true, _reverse);
      // }
    }
  }

  Future<void> _autoScrollIfNecessary() async {
    if (!_autoScrolling && _dragInfo != null && _dragInfo.scrollable != null) {
      final ScrollPosition position = _dragInfo.scrollable.position;
      double newOffset;
      const Duration duration = Duration(milliseconds: 14);
      const double step = 1.0;
      const double overDragMax = 20.0;
      const double overDragCoef = 10;

      final RenderBox scrollRenderBox =
          _dragInfo.scrollable.context.findRenderObject() as RenderBox;
      final Offset scrollOrigin = scrollRenderBox.localToGlobal(Offset.zero);
      final double scrollStart = _offsetExtent(scrollOrigin, _scrollDirection);
      final double scrollEnd =
          scrollStart + _sizeExtent(scrollRenderBox.size, _scrollDirection);

      final double proxyStart = _offsetExtent(
          _dragInfo.dragPosition - _dragInfo.dragOffset, _scrollDirection);
      final double proxyEnd = proxyStart + _dragInfo.itemExtent;

      if (_reverse) {
        if (proxyEnd > scrollEnd &&
            position.pixels > position.minScrollExtent) {
          final double overDrag = max(proxyEnd - scrollEnd, overDragMax);
          newOffset = max(position.minScrollExtent,
              position.pixels - step * overDrag / overDragCoef);
        } else if (proxyStart < scrollStart &&
            position.pixels < position.maxScrollExtent) {
          final double overDrag = max(scrollStart - proxyStart, overDragMax);
          newOffset = min(position.maxScrollExtent,
              position.pixels + step * overDrag / overDragCoef);
        }
      } else {
        if (proxyStart < scrollStart &&
            position.pixels > position.minScrollExtent) {
          final double overDrag = max(scrollStart - proxyStart, overDragMax);
          newOffset = max(position.minScrollExtent,
              position.pixels - step * overDrag / overDragCoef);
        } else if (proxyEnd > scrollEnd &&
            position.pixels < position.maxScrollExtent) {
          final double overDrag = max(proxyEnd - scrollEnd, overDragMax);
          newOffset = min(position.maxScrollExtent,
              position.pixels + step * overDrag / overDragCoef);
        }
      }

      if (newOffset != null && (newOffset - position.pixels).abs() >= 1.0) {
        _autoScrolling = true;
        await position.animateTo(newOffset,
            duration: duration, curve: Curves.linear);
        _autoScrolling = false;
        if (_dragItem != null) {
          _dragUpdateItems();
          _autoScrollIfNecessary();
        }
      }
    }
  }

  Offset _itemOffsetAt(int index) {
    final RenderBox itemRenderBox =
        _items[index].context.findRenderObject() as RenderBox;
    return itemRenderBox.localToGlobal(Offset.zero);
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (_dragInfo != null && index >= widget.itemCount) {
      switch (_scrollDirection) {
        case Axis.horizontal:
          return SizedBox(width: _dragInfo.itemExtent);
        case Axis.vertical:
          return SizedBox(height: _dragInfo.itemExtent);
      }
    }
    final Widget child = widget.itemBuilder(context, index);
    assert(child.key != null, 'All list items must have a key');
    final OverlayState overlay = Overlay.of(context);
    return _DraggableItem(
      key: _DraggableItemGlobalKey(child.key, index, this),
      index: index,
      child: child,
      capturedThemes:
          InheritedTheme.capture(from: context, to: overlay.context),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasOverlay(context));
    return SliverList(
      // When dragging, the dragged item is still in the list but has been replaced
      // by a zero height SizedBox, so that the gap can move around. To make the
      // list extent stable we add a dummy entry to the end.
      delegate: SliverChildBuilderDelegate(_itemBuilder,
          childCount: widget.itemCount + (_reorderingDrag ? 1 : 0)),
    );
  }
}

class _DraggableItem extends StatefulWidget {
  const _DraggableItem({
    @required Key key,
    @required this.index,
    @required this.child,
    @required this.capturedThemes,
  }) : super(key: key);

  final int index;
  final Widget child;
  final CapturedThemes capturedThemes;

  @override
  _DraggableItemState createState() => _DraggableItemState();
}

class _DraggableItemState extends State<_DraggableItem> {
  SliverDraggableListState _listState;

  Offset _startOffset = Offset.zero;
  Offset _targetOffset = Offset.zero;
  AnimationController _offsetAnimation;

  Key get key => widget.key;
  int get index => widget.index;

  bool get dragging => _dragging;
  set dragging(bool dragging) {
    if (mounted) {
      setState(() {
        _dragging = dragging;
      });
    }
  }

  bool _dragging = false;

  @override
  void initState() {
    _listState = SliverDraggableList.of(context);
    _listState._registerItem(this);
    super.initState();
  }

  @override
  void dispose() {
    _offsetAnimation?.dispose();
    _listState._unregisterItem(index, this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _DraggableItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _listState._unregisterItem(oldWidget.index, this);
      _listState._registerItem(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dragging) {
      return const SizedBox();
    }
    _listState._registerItem(this);
    return Transform(
      transform: Matrix4.translationValues(offset.dx, offset.dy, 0.0),
      child: widget.child,
    );
  }

  @override
  void deactivate() {
    _listState._unregisterItem(index, this);
    super.deactivate();
  }

  Offset get offset {
    if (_offsetAnimation != null) {
      final double animValue =
          Curves.easeInOut.transform(_offsetAnimation.value);
      return Offset.lerp(_startOffset, _targetOffset, animValue);
    }
    return _targetOffset;
  }

  void updateForGap(
      int gapIndex, int gapPos, double gapExtent, bool animate, bool reverse) {
    Offset newTargetOffset;
    if (gapPos == 2) {
      newTargetOffset = Offset.zero;
    } else if (gapIndex == index) {
      if (reverse) {
        newTargetOffset = _extentOffset(
            gapPos == 1 ? -gapExtent : 0, _listState._scrollDirection);
      } else {
        newTargetOffset = _extentOffset(
            gapPos == 1 ? gapExtent : 0, _listState._scrollDirection);
      }
    } else if (index > gapIndex) {
      if (reverse) {
        newTargetOffset =
            _extentOffset(-gapExtent, _listState._scrollDirection);
      } else {
        newTargetOffset = _extentOffset(gapExtent, _listState._scrollDirection);
      }
    } else {
      newTargetOffset = Offset.zero;
    }
    if (newTargetOffset != _targetOffset) {
      _targetOffset = newTargetOffset;
      if (animate) {
        if (_offsetAnimation == null) {
          _offsetAnimation = AnimationController(
            vsync: _listState,
            duration: const Duration(milliseconds: 250),
          )
            ..addListener(rebuild)
            ..addStatusListener((AnimationStatus status) {
              if (status == AnimationStatus.completed) {
                _startOffset = _targetOffset;
                _offsetAnimation.dispose();
                _offsetAnimation = null;
              }
            })
            ..forward();
        } else {
          _startOffset = offset;
          _offsetAnimation.forward(from: 0.0);
        }
      } else {
        if (_offsetAnimation != null) {
          _offsetAnimation.dispose();
          _offsetAnimation = null;
        }
        _startOffset = _targetOffset;
      }
      rebuild();
    }
  }

  void resetGap() {
    if (_offsetAnimation != null) {
      _offsetAnimation.dispose();
      _offsetAnimation = null;
    }
    _startOffset = Offset.zero;
    _targetOffset = Offset.zero;
    rebuild();
  }

  Rect targetGeometry() {
    final RenderBox itemRenderBox = context.findRenderObject() as RenderBox;
    final Offset itemPosition =
        itemRenderBox.localToGlobal(Offset.zero) + _targetOffset;
    return itemPosition & itemRenderBox.size;
  }

  void rebuild() {
    if (mounted) {
      setState(() {});
    }
  }
}

/// A wrapper widget that will recognize the start of a drag on the wrapped
/// widget by a [PointerDownEvent], and immediately initiate dragging the
/// wrapped item to a new location in a Draggable list.
///
/// See also:
///
///  * [DraggableDelayedDragStartListener], a similar wrapper that will
///    only recognize the start after a long press event.
///  * [DraggableList], a widget list that allows the user to drag
///    its items.
///  * [SliverDraggableList], a sliver list that allows the user to drag
///    its items.
///  * [DraggableListView], a material design list that allows the user to
///    drag its items.
class DraggableDragStartListener extends StatelessWidget {
  /// Creates a listener for a drag immediately following a pointer down
  /// event over the given child widget.
  ///
  /// This is most commonly used to wrap part of a list item like a drag
  /// handle.
  const DraggableDragStartListener({
    Key key,
    @required this.child,
    @required this.index,
  }) : super(key: key);

  /// The widget for which the application would like to respond to a tap and
  /// drag gesture by starting a drag on a Draggable list.
  final Widget child;

  /// The index of the associated item that will be dragged in the list.
  final int index;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) => _startDragging(context, event),
      child: child,
    );
  }

  /// Provides the gesture recognizer used to indicate the start of a
  /// drag operation.
  ///
  /// By default this returns an [ImmediateMultiDragGestureRecognizer] but
  /// subclasses can use this to customize the drag start gesture.
  @protected
  MultiDragGestureRecognizer<MultiDragPointerState> createRecognizer() {
    return ImmediateMultiDragGestureRecognizer(debugOwner: this);
  }

  void _startDragging(BuildContext context, PointerDownEvent event) {
    final SliverDraggableListState list = SliverDraggableList.maybeOf(context);
    list?.startItemDrag(
        index: index, event: event, recognizer: createRecognizer());
  }
}

/// A wrapper widget that will recognize the start of a drag operation by
/// looking for a long press event. Once it is recognized, it will start
/// a drag operation on the wrapped item in the Draggable list.
///
/// See also:
///
///  * [DraggableDragStartListener], a similar wrapper that will
///    recognize the start of the drag immediately after a pointer down event.
///  * [DraggableList], a widget list that allows the user to drag
///    its items.
///  * [SliverDraggableList], a sliver list that allows the user to drag
///    its items.
///  * [DraggableListView], a material design list that allows the user to
///    drag its items.
class DraggableDelayedDragStartListener extends DraggableDragStartListener {
  /// Creates a listener for an drag following a long press event over the
  /// given child widget.
  ///
  /// This is most commonly used to wrap an entire list item in a Draggable
  /// list.
  const DraggableDelayedDragStartListener({
    Key key,
    @required Widget child,
    @required int index,
  }) : super(key: key, child: child, index: index);

  @override
  MultiDragGestureRecognizer<MultiDragPointerState> createRecognizer() {
    return DelayedMultiDragGestureRecognizer(debugOwner: this);
  }
}

typedef _DragItemUpdate = void Function(
    _DragInfo item, Offset position, Offset delta);
typedef _DragItemCallback = void Function(_DragInfo item);

class _DragInfo extends Drag {
  _DragInfo({
    @required this.item,
    Offset initialPosition = Offset.zero,
    this.scrollDirection = Axis.vertical,
    this.onUpdate,
    this.onEnd,
    this.onCancel,
    this.onDropCompleted,
    this.proxyDecorator,
    @required this.tickerProvider,
  }) {
    final RenderBox itemRenderBox =
        item.context.findRenderObject() as RenderBox;
    dragPosition = initialPosition;
    dragOffset = itemRenderBox.globalToLocal(initialPosition);
    itemSize = item.context.size;
    itemExtent = _sizeExtent(itemSize, scrollDirection);
    scrollable = Scrollable.of(item.context);
  }

  final _DraggableItemState item;
  final Axis scrollDirection;
  final _DragItemUpdate onUpdate;
  final _DragItemCallback onEnd;
  final _DragItemCallback onCancel;
  final VoidCallback onDropCompleted;
  final DraggableItemProxyDecorator proxyDecorator;
  final TickerProvider tickerProvider;

  Offset dragPosition;
  Offset dragOffset;
  Size itemSize;
  double itemExtent;
  ScrollableState scrollable;
  AnimationController _proxyAnimation;

  void dispose() {
    _proxyAnimation?.dispose();
  }

  void startDrag() {
    _proxyAnimation = AnimationController(
      vsync: tickerProvider,
      duration: const Duration(milliseconds: 250),
    )
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.dismissed) {
          _dropCompleted();
        }
      })
      ..forward();
  }

  @override
  void update(DragUpdateDetails details) {
    final Offset delta = _restrictAxis(details.delta, scrollDirection);
    dragPosition += delta;
    onUpdate?.call(this, dragPosition, details.delta);
  }

  @override
  void end(DragEndDetails details) {
    _proxyAnimation.reverse();
    onEnd?.call(this);
  }

  @override
  void cancel() {
    _proxyAnimation?.dispose();
    _proxyAnimation = null;
    onCancel?.call(this);
  }

  void _dropCompleted() {
    _proxyAnimation?.dispose();
    _proxyAnimation = null;
    onDropCompleted?.call();
  }

  Widget createProxy(BuildContext context) {
    return item.widget.capturedThemes.wrap(_DragItemProxy(
      item: item,
      size: itemSize,
      animation: _proxyAnimation,
      position: dragPosition - dragOffset - _overlayOrigin(context),
      proxyDecorator: proxyDecorator,
    ));
  }
}

Offset _overlayOrigin(BuildContext context) {
  final OverlayState overlay = Overlay.of(context);
  final RenderBox overlayBox = overlay.context.findRenderObject() as RenderBox;
  return overlayBox.localToGlobal(Offset.zero);
}

class _DragItemProxy extends StatelessWidget {
  const _DragItemProxy({
    Key key,
    @required this.item,
    @required this.position,
    @required this.size,
    @required this.animation,
    @required this.proxyDecorator,
  }) : super(key: key);

  final _DraggableItemState item;
  final Offset position;
  final Size size;
  final AnimationController animation;
  final DraggableItemProxyDecorator proxyDecorator;

  @override
  Widget build(BuildContext context) {
    final Widget child = item.widget.child;
    final Widget proxyChild =
        proxyDecorator?.call(child, item.index, animation.view) ?? child;
    final Offset overlayOrigin = _overlayOrigin(context);

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        Offset effectivePosition = position;
        final Offset dropPosition = item._listState._finalDropPosition;
        if (dropPosition != null) {
          effectivePosition = Offset.lerp(dropPosition - overlayOrigin,
              effectivePosition, Curves.easeOut.transform(animation.value));
        }
        return Positioned(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: child,
          ),
          left: effectivePosition.dx,
          top: effectivePosition.dy,
        );
      },
      child: proxyChild,
    );
  }
}

// ignore: missing_return
double _sizeExtent(Size size, Axis scrollDirection) {
  switch (scrollDirection) {
    case Axis.horizontal:
      return size.width;
    case Axis.vertical:
      return size.height;
  }
}

// ignore: missing_return
double _offsetExtent(Offset offset, Axis scrollDirection) {
  switch (scrollDirection) {
    case Axis.horizontal:
      return offset.dx;
    case Axis.vertical:
      return offset.dy;
  }
}

// ignore: missing_return
Offset _extentOffset(double extent, Axis scrollDirection) {
  switch (scrollDirection) {
    case Axis.horizontal:
      return Offset(extent, 0.0);
    case Axis.vertical:
      return Offset(0.0, extent);
  }
}

// ignore: missing_return
Offset _restrictAxis(Offset offset, Axis scrollDirection) {
  switch (scrollDirection) {
    case Axis.horizontal:
      return Offset(offset.dx, 0.0);
    case Axis.vertical:
      return Offset(0.0, offset.dy);
  }
}

// A global key that takes its identity from the object and uses a value of a
// particular type to identify itself.
//
// The difference with GlobalObjectKey is that it uses [==] instead of [identical]
// of the objects used to generate widgets.
@optionalTypeArgs
class _DraggableItemGlobalKey extends GlobalObjectKey {
  const _DraggableItemGlobalKey(this.subKey, this.index, this.state)
      : super(subKey);

  final Key subKey;
  final int index;
  final SliverDraggableListState state;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is _DraggableItemGlobalKey &&
        other.subKey == subKey &&
        other.index == index &&
        other.state == state;
  }

  @override
  int get hashCode => hashValues(subKey, index, state);
}
