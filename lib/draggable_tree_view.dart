// Copyright ©2021 OrTrue. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Author by: FrontLee(李锋)
// Email: ortrue@163.com
// Changes based on the reorderable_list.dart

library draggable_tree_view;

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'draggable_list.dart';
import 'draggable_list_view.dart';

typedef void ParentSelectChanged(bool isSelected);
typedef void DragEnd(int oldIndex, int newIndex, int newPos);
typedef void DragStart(int index, double start, double end);
typedef void Draging(
    int oldIndex, int newIndex, int newPos, double start, double end);
typedef void Hovering(int index);

/// # Tree View
///
/// Creates a draggable tree view widget. The widget is a List View with a [List] of
/// [Item] widgets. The [DraggableTreeView] is nested inside a [Scrollbar] if the
/// [DraggableTreeView.hasScrollBar] property is true.
class DraggableTreeView extends StatefulWidget {
  DraggableTreeView({
    @required this.itemList,
    this.onDragEnd,
    this.onDragStart,
    this.onDraging,
    this.hasScrollBar = false,
    this.indentStep = 10.0,
    this.onHovering,
    this.hoveringDelay = 600,
    this.padding = EdgeInsets.zero,
    this.proxyDecorator,
    this.buildDefaultDragHandles = true,
    this.header,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.anchor = 0.0,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  }) : assert(itemList != null);

  final List<Item> itemList;
  final bool hasScrollBar;
  final double indentStep;
  final DragEnd onDragEnd;
  final DragStart onDragStart;
  final Draging onDraging;
  final Hovering onHovering;
  final EdgeInsets padding;
  final int hoveringDelay;
  final DraggableItemProxyDecorator proxyDecorator;
  final bool buildDefaultDragHandles;

  /// A non-reorderable header item to show before the items of the list.
  ///
  /// If null, no header will appear before the list.
  final Widget header;

  /// {@macro flutter.widgets.scroll_view.scrollDirection}
  final Axis scrollDirection;

  /// {@macro flutter.widgets.scroll_view.reverse}
  final bool reverse;

  /// {@macro flutter.widgets.scroll_view.controller}
  final ScrollController scrollController;

  /// {@macro flutter.widgets.scroll_view.primary}

  /// Defaults to true when [scrollDirection] is [Axis.vertical] and
  /// [scrollController] is null.
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

  @override
  DraggableTreeViewState createState() => DraggableTreeViewState();
}

class DraggableTreeViewState extends State<DraggableTreeView> {
  StateSetter catalogStateSetter;
  StateSetter indicatorStateSetter; // 目录控制器
  double indicatorLeft = 0;
  double indicatorTop = -100;
  BuildContext context;
  String indicatorImage = 'images/indicator.png';
  Timer hoveringTimer;
  bool draging = false;
  int hoveringIndex = -1;
  int hoverStartTime = 0;

  @override
  void dispose() {
    cancelHoveringTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return widget.hasScrollBar
        ? Scrollbar(child: _getTreeList())
        : _getTreeList();
  }

  Widget _getTreeList() {
    return Stack(children: <Widget>[
      StatefulBuilder(builder: (BuildContext context, StateSetter stateSetter) {
        catalogStateSetter = stateSetter;
        return DraggableListView.builder(
            itemBuilder: (context, index) {
              return widget.itemList[index];
            },
            itemCount: widget.itemList.length,
            padding: widget.padding,
            proxyDecorator: widget.proxyDecorator,
            buildDefaultDragHandles: widget.buildDefaultDragHandles,
            header: widget.header,
            scrollDirection: widget.scrollDirection,
            reverse: widget.reverse,
            scrollController: widget.scrollController,
            primary: widget.primary,
            physics: widget.physics,
            shrinkWrap: widget.shrinkWrap,
            anchor: widget.anchor,
            cacheExtent: widget.cacheExtent,
            dragStartBehavior: widget.dragStartBehavior,
            keyboardDismissBehavior: widget.keyboardDismissBehavior,
            restorationId: widget.restorationId,
            clipBehavior: widget.clipBehavior,
            onDragEnd: (int oldIndex, int newIndex, int newPos) {
              draging = false;
              hoveringIndex = -1;
              cancelHoveringTimer();
              indicatorTop = -100;
              indicatorStateSetter(() {});
              if (newIndex < 0) return;
              if (widget.onDragEnd != null)
                widget.onDragEnd(oldIndex, newIndex, newPos);
            },
            onDragStart: (int index, double start, double end) {
              draging = true;
              hoveringIndex = -1;
              indicatorLeft = widget.itemList[index].level * 10.0;
              start = globalToLocal(context, start);
              indicatorTop = start + 2;
              indicatorImage = 'images/indicator.png';
              indicatorStateSetter(() {});
              startHoveringTimer();
              if (widget.onDragStart != null) {
                widget.onDragStart(index, start, end);
              }
            },
            onDraging: (int oldIndex, int newIndex, int newPos, double start,
                double end) {
              indicatorLeft =
                  widget.itemList[newIndex].level * widget.indentStep;
              double height = end - start;
              start = globalToLocal(context, start);
              end = start + height;
              int now = new DateTime.now().millisecondsSinceEpoch;
              if (newPos == 1) {
                indicatorTop = start + 2;
                indicatorImage = 'images/indicator.png';
                hoverStartTime = now;
                hoveringIndex = -1;
              } else if (newPos == 3) {
                indicatorTop = end - 2;
                indicatorImage = 'images/indicator.png';
                hoverStartTime = now;
                hoveringIndex = -1;
              } else {
                indicatorTop = start + height * 0.5;
                indicatorImage = 'images/indicator_center.png';
                if (newIndex != hoveringIndex) {
                  hoverStartTime = now;
                }
                hoveringIndex = newIndex;
              }
              indicatorStateSetter(() {});
              if (widget.onDraging != null) {
                widget.onDraging(oldIndex, newIndex, newPos, start, end);
              }
            });
      }),
      StatefulBuilder(builder: (BuildContext context, StateSetter stateSetter) {
        indicatorStateSetter = stateSetter;
        return Positioned(
            left: indicatorLeft,
            top: indicatorTop - 15,
            child: Image.asset(
              indicatorImage,
              height: 30,
              width: 200,
              fit: BoxFit.cover,
            ));
      })
    ]);
  }

  double globalToLocal(BuildContext context, double y) {
    RenderBox box = context.findRenderObject();
    return box.globalToLocal(Offset(0, y)).dy;
  }

  void cancelHoveringTimer() {
    if (hoveringTimer != null) {
      hoveringTimer.cancel();
    }
  }

  void startHoveringTimer() {
    final Duration duration = Duration(milliseconds: 200);
    cancelHoveringTimer();

    hoveringTimer = Timer.periodic(duration, (timer) {
      if (widget.onHovering == null) return;
      if (!draging) return;
      if (hoveringIndex < 0) return;
      int now = new DateTime.now().millisecondsSinceEpoch;
      if (now - hoverStartTime < widget.hoveringDelay) return;
      widget.onHovering(hoveringIndex);
    });
  }
}

/// # Parent widget
///
/// The [Parent] widget holds the [Parent.parent] widget and
/// [Parent.childList] which is a [List] of child widgets.
///
/// The [Parent] widget is wrapped around a [Column]. The [Parent.childList]
/// is collapsed by default. When clicked the child widget is expanded.
class Item extends StatefulWidget {
  final Widget item;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final Key key;
  final bool display;
  final int level;

  Item(
      {@required this.key,
      @required this.item,
      this.mainAxisAlignment = MainAxisAlignment.center,
      this.crossAxisAlignment = CrossAxisAlignment.start,
      this.mainAxisSize = MainAxisSize.min,
      this.display = false,
      this.level = 0});

  @override
  ItemState createState() => ItemState();
}

class ItemState extends State<Item> {
  bool display = false;
  @override
  Widget build(BuildContext context) {
    display = widget.display;
    return _getItem();
  }

  Widget _getItem() {
    return display ? widget.item : Container();
  }
}
