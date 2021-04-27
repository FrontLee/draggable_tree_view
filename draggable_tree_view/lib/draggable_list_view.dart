// Copyright ©2021 OrTrue. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Author by: FrontLee(李锋)
// Email: ortrue@163.com
// Changes based on the reorderable_list_view.dart

import 'dart:ui' show lerpDouble;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'draggable_list.dart' as Draggable;

class DraggableListView extends StatefulWidget {
  DraggableListView({
    Key key,
    @required List<Widget> children,
    @required this.onDragEnd,
    @required this.onDragStart,
    @required this.onDraging,
    this.proxyDecorator,
    this.buildDefaultDragHandles = true,
    this.padding,
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
  })  : assert(scrollDirection != null),
        assert(onDragEnd != null),
        assert(children != null),
        assert(
          children.every((Widget w) => w.key != null),
          'All children of this widget must have a key.',
        ),
        assert(buildDefaultDragHandles != null),
        itemBuilder = ((BuildContext context, int index) => children[index]),
        itemCount = children.length,
        super(key: key);

  const DraggableListView.builder({
    Key key,
    @required this.itemBuilder,
    @required this.itemCount,
    @required this.onDragEnd,
    @required this.onDragStart,
    @required this.onDraging,
    this.proxyDecorator,
    this.buildDefaultDragHandles = true,
    this.padding,
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
  })  : assert(scrollDirection != null),
        assert(itemCount >= 0),
        assert(onDragEnd != null),
        assert(buildDefaultDragHandles != null),
        super(key: key);

  final IndexedWidgetBuilder itemBuilder;

  final int itemCount;

  final Draggable.DragEndCallback onDragEnd;

  final Draggable.DragStartCallback onDragStart;

  final Draggable.DragingCallback onDraging;

  final Draggable.DraggableItemProxyDecorator proxyDecorator;

  final bool buildDefaultDragHandles;

  /// {@macro flutter.widgets.reorderable_list.padding}
  final EdgeInsets padding;

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
  _DraggableListViewState createState() => _DraggableListViewState();
}

// This top-level state manages an Overlay that contains the list and
// also any items being dragged on top fo the list.
//
// The Overlay doesn't properly keep state by building new overlay entries,
// and so we cache a single OverlayEntry for use as the list layer.
// That overlay entry then builds a _ReorderableListContent which may
// insert items being dragged into the Overlay above itself.
class _DraggableListViewState extends State<DraggableListView> {
  // This entry contains the scrolling list itself.
  OverlayEntry _listOverlayEntry;

  @override
  void initState() {
    super.initState();
    print('init Draggable tree');
    _listOverlayEntry = OverlayEntry(
      opaque: true,
      builder: (BuildContext context) {
        return _DraggableListViewContent(
          itemBuilder: widget.itemBuilder,
          itemCount: widget.itemCount,
          onDragEnd: widget.onDragEnd,
          onDragStart: widget.onDragStart,
          onDraging: widget.onDraging,
          proxyDecorator: widget.proxyDecorator,
          buildDefaultDragHandles: widget.buildDefaultDragHandles,
          padding: widget.padding,
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
        );
      },
    );
  }

  @override
  void didUpdateWidget(DraggableListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // As this depends on pretty much everything, it
    // is ok to mark this as dirty unconditionally.
    _listOverlayEntry.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return Overlay(
      initialEntries: <OverlayEntry>[_listOverlayEntry],
    );
  }
}

class _DraggableListViewContent extends StatefulWidget {
  const _DraggableListViewContent({
    @required this.itemBuilder,
    @required this.itemCount,
    @required this.onDragEnd,
    @required this.onDragStart,
    @required this.onDraging,
    @required this.proxyDecorator,
    @required this.buildDefaultDragHandles,
    @required this.padding,
    @required this.header,
    @required this.scrollDirection,
    @required this.reverse,
    @required this.scrollController,
    @required this.primary,
    @required this.physics,
    @required this.shrinkWrap,
    @required this.anchor,
    @required this.cacheExtent,
    @required this.dragStartBehavior,
    @required this.keyboardDismissBehavior,
    @required this.restorationId,
    @required this.clipBehavior,
  });

  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final Draggable.DragEndCallback onDragEnd;
  final Draggable.DragStartCallback onDragStart;
  final Draggable.DragingCallback onDraging;
  final Draggable.DraggableItemProxyDecorator proxyDecorator;
  final bool buildDefaultDragHandles;
  final EdgeInsets padding;
  final Widget header;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController scrollController;
  final bool primary;
  final ScrollPhysics physics;
  final bool shrinkWrap;
  final double anchor;
  final double cacheExtent;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String restorationId;
  final Clip clipBehavior;

  @override
  _DraggableListViewContentState createState() =>
      _DraggableListViewContentState();
}

class _DraggableListViewContentState extends State<_DraggableListViewContent> {
  Widget _wrapWithSemantics(Widget child, int index) {
    void reorder(int startIndex, int endIndex, int endPos) {
      widget.onDragEnd(startIndex, endIndex, endPos);
    }

    // First, determine which semantics actions apply.
    final Map<CustomSemanticsAction, VoidCallback> semanticsActions =
        <CustomSemanticsAction, VoidCallback>{};

    // Create the appropriate semantics actions.
    void moveToStart() => reorder(index, 0, 1);
    void moveToEnd() => reorder(index, widget.itemCount, 3);
    void moveBefore() => reorder(index, index - 1, 1);
    // To move after, we go to index+2 because we are moving it to the space
    // before index+2, which is after the space at index+1.
    void moveAfter() => reorder(index, index + 2, 3);

    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    // If the item can move to before its current position in the list.
    if (index > 0) {
      semanticsActions[
              CustomSemanticsAction(label: localizations.reorderItemToStart)] =
          moveToStart;
      String reorderItemBefore = localizations.reorderItemUp;
      if (widget.scrollDirection == Axis.horizontal) {
        reorderItemBefore = Directionality.of(context) == TextDirection.ltr
            ? localizations.reorderItemLeft
            : localizations.reorderItemRight;
      }
      semanticsActions[CustomSemanticsAction(label: reorderItemBefore)] =
          moveBefore;
    }

    // If the item can move to after its current position in the list.
    if (index < widget.itemCount - 1) {
      String reorderItemAfter = localizations.reorderItemDown;
      if (widget.scrollDirection == Axis.horizontal) {
        reorderItemAfter = Directionality.of(context) == TextDirection.ltr
            ? localizations.reorderItemRight
            : localizations.reorderItemLeft;
      }
      semanticsActions[CustomSemanticsAction(label: reorderItemAfter)] =
          moveAfter;
      semanticsActions[
              CustomSemanticsAction(label: localizations.reorderItemToEnd)] =
          moveToEnd;
    }

    // We pass toWrap with a GlobalKey into the item so that when it
    // gets dragged, the accessibility framework can preserve the selected
    // state of the dragging item.
    //
    // We also apply the relevant custom accessibility actions for moving the item
    // up, down, to the start, and to the end of the list.
    return MergeSemantics(
      child: Semantics(
        customSemanticsActions: semanticsActions,
        child: child,
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final Widget item = widget.itemBuilder(context, index);

    // TODO(goderbauer): The semantics stuff should probably happen inside
    //   _ReorderableItem so the widget versions can have them as well.
    final Widget itemWithSemantics = _wrapWithSemantics(item, index);
    final Key itemGlobalKey = _DraggableListViewChildGlobalKey(item.key, this);

    if (widget.buildDefaultDragHandles) {
      switch (Theme.of(context).platform) {
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
        case TargetPlatform.macOS:
          return Stack(
            key: itemGlobalKey,
            children: <Widget>[
              itemWithSemantics,
              Positioned.directional(
                textDirection: Directionality.of(context),
                top: 0,
                bottom: 0,
                end: 8,
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Draggable.DraggableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle),
                  ),
                ),
              ),
            ],
          );

        case TargetPlatform.iOS:
        case TargetPlatform.android:
          return Draggable.DraggableDelayedDragStartListener(
            key: itemGlobalKey,
            index: index,
            child: itemWithSemantics,
          );
      }
    }

    return KeyedSubtree(
      key: itemGlobalKey,
      child: itemWithSemantics,
    );
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue);
        return Material(
          child: child,
          elevation: elevation,
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    // If there is a header we can't just apply the padding to the list,
    // so we wrap the CustomScrollView in the padding for the top, left and right
    // and only add the padding from the bottom to the sliver list (or the equivalent
    // for other axis directions).
    final EdgeInsets padding = widget.padding ?? EdgeInsets.zero;
    EdgeInsets outerPadding;
    EdgeInsets listPadding;
    switch (widget.scrollDirection) {
      case Axis.horizontal:
        if (widget.reverse) {
          outerPadding = EdgeInsets.fromLTRB(
              0, padding.top, padding.right, padding.bottom);
          listPadding = EdgeInsets.fromLTRB(padding.left, 0, 0, 0);
        } else {
          outerPadding =
              EdgeInsets.fromLTRB(padding.left, padding.top, 0, padding.bottom);
          listPadding = EdgeInsets.fromLTRB(0, 0, padding.right, 0);
        }
        break;
      case Axis.vertical:
        if (widget.reverse) {
          outerPadding = EdgeInsets.fromLTRB(
              padding.left, 0, padding.right, padding.bottom);
          listPadding = EdgeInsets.fromLTRB(0, padding.top, 0, 0);
        } else {
          outerPadding =
              EdgeInsets.fromLTRB(padding.left, padding.top, padding.right, 0);
          listPadding = EdgeInsets.fromLTRB(0, 0, 0, padding.bottom);
        }
        break;
    }

    return Padding(
      padding: outerPadding,
      child: CustomScrollView(
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        controller: widget.scrollController,
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
          if (widget.header != null) SliverToBoxAdapter(child: widget.header),
          SliverPadding(
            padding: listPadding,
            sliver: Draggable.SliverDraggableList(
              itemBuilder: _itemBuilder,
              itemCount: widget.itemCount,
              onDragEnd: widget.onDragEnd,
              onDragStart: widget.onDragStart,
              onDraging: widget.onDraging,
              proxyDecorator: widget.proxyDecorator ?? _proxyDecorator,
            ),
          ),
        ],
      ),
    );
  }
}

// A global key that takes its identity from the object and uses a value of a
// particular type to identify itself.
//
// The difference with GlobalObjectKey is that it uses [==] instead of [identical]
// of the objects used to generate widgets.
@optionalTypeArgs
class _DraggableListViewChildGlobalKey extends GlobalObjectKey {
  const _DraggableListViewChildGlobalKey(this.subKey, this.state)
      : super(subKey);

  final Key subKey;
  final State state;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is _DraggableListViewChildGlobalKey &&
        other.subKey == subKey &&
        other.state == state;
  }

  @override
  int get hashCode => hashValues(subKey, state);
}
