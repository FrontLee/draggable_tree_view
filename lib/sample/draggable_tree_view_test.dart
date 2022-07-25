import 'package:draggable_tree_view/draggable_tree_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'catalogue.dart';

class DraggableTreeViewTest extends StatefulWidget {
  @override
  _DraggableTreeViewTestState createState() => _DraggableTreeViewTestState();
}

class _DraggableTreeViewTestState extends State<DraggableTreeViewTest> {
  Catalogue rootCatalog; // 根目录
  List<Catalogue> catalogs = []; // 目录列表
  Map<String, Catalogue> catalogMap = new Map(); // 目录Map
  StateSetter catalogStateSetter; // 目录控制器
  StateSetter indicatorStateSetter; // 目录控制器
  List<Item> itemList = [];

  @override
  void initState() {
    super.initState();
    rootCatalog = Catalogue(
        noteId: 'root',
        title: '目录',
        preId: '',
        nextId: '',
        level: 0,
        upIds: [],
        hasChild: true);
    rootCatalog.expanded = true;
    catalogs.add(Catalogue(
        noteId: '1',
        title: '文稿1',
        preId: '',
        nextId: '7',
        level: 1,
        upIds: ['root'],
        hasChild: true));
    catalogs.add(Catalogue(
        noteId: '2',
        title: '文稿2',
        preId: '',
        nextId: '3',
        level: 2,
        upIds: ['root', '1'],
        hasChild: false));
    catalogs.add(Catalogue(
        noteId: '3',
        title: '文稿3',
        preId: '2',
        nextId: '4',
        level: 2,
        upIds: ['root', '1'],
        hasChild: false));
    catalogs.add(Catalogue(
        noteId: '4',
        title: '文稿4',
        preId: '3',
        nextId: '',
        level: 2,
        upIds: ['root', '1'],
        hasChild: true));
    catalogs.add(Catalogue(
        noteId: '5',
        title: '文稿5',
        preId: '',
        nextId: '6',
        level: 3,
        upIds: ['root', '1', '4'],
        hasChild: false));
    catalogs.add(Catalogue(
        noteId: '6',
        title: '文稿6',
        preId: '5',
        nextId: '',
        level: 3,
        upIds: ['root', '1', '4'],
        hasChild: false));
    catalogs.add(Catalogue(
        noteId: '7',
        title: '文稿7',
        preId: '1',
        nextId: '',
        level: 1,
        upIds: ['root'],
        hasChild: true));
    catalogs.add(Catalogue(
        noteId: '8',
        title: '文稿8',
        preId: '',
        nextId: '',
        level: 2,
        upIds: ['root', '7'],
        hasChild: false));
    catalogs.add(Catalogue(
        noteId: '9',
        title: '文稿9',
        preId: '7',
        nextId: '10',
        level: 1,
        upIds: ['root'],
        hasChild: false));

    for (int i = 10; i < 100; i++) {
      catalogs.add(Catalogue(
          noteId: '$i',
          title: '文稿$i',
          preId: '${i - 1}',
          nextId: '${i + 1}',
          level: 1,
          upIds: ['root'],
          hasChild: false));
    }

    catalogs.add(Catalogue(
        noteId: '100',
        title: '文稿101',
        preId: '99',
        nextId: '',
        level: 1,
        upIds: ['root'],
        hasChild: false));

    catalogMap[rootCatalog.noteId] = rootCatalog;
    catalogs.forEach((element) {
      catalogMap[element.noteId] = element;
    });

    calDisplay();
  }

  @override
  void dispose() {
    super.dispose();
  }

  double globalToLocal(BuildContext context, double y) {
    RenderBox box = context.findRenderObject();
    return box.globalToLocal(Offset(0, y)).dy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 0,
          title: const Text(
            "Markdown Editor",
            style: TextStyle(
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        body: Stack(children: <Widget>[
          StatefulBuilder(
            builder: (BuildContext context, StateSetter stateSetter) {
              catalogStateSetter = stateSetter;
              return Column(children: <Widget>[
                SizedBox(height: 10),
                getCatalogRootWidget(),
                Expanded(
                    child: DraggableTreeView(
                  itemList: _getItemList(),
                  indentStep: 10.0,
                  indicatorCenter: Image.asset(
                    'images/indicator_center.png',
                    height: 30,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                  indicatorSide: Image.asset(
                    'images/indicator.png',
                    height: 30,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                  indicatorOffset: Offset(0, -15),
                  onDragStart: (int index, double start, double end) {
                    print('on drag start');
                    Catalogue catalog = catalogs[index];
                    if (catalog.expanded == true) {
                      catalog.expanded = false;
                      calDisplay();
                      catalogStateSetter(() {});
                    }
                  },
                  onDraging: (int oldIndex, int newIndex, int newPos,
                      double start, double end) {
                    print('on draging');
                  },
                  onHovering: (int index) {
                    print('on hovering');
                    Catalogue catalog = catalogs[index];
                    if (catalog.expanded == false) {
                      catalog.expanded = true;
                      calDisplay();
                      catalogStateSetter(() {});
                    }
                  },
                  onDragEnd: (int oldIndex, int newIndex, int newPos) {
                    // re-arrange your tree
                    // toTargetPos: 1 - pre; 2 - child; 3 - next
                    print(
                        'on drag end, originIndex:$oldIndex, targetIndex:$newIndex, toTargetPos:$newPos');
                  },
                )),
                SizedBox(height: 20),
              ]);
            },
          )
        ]));
  }

  // 递归展开树列表
  List<Item> _getItemList() {
    itemList = [];
    catalogs.forEach((catalog) {
      Item item = _getItem(catalog: catalog);
      itemList.add(item);
    });
    return itemList;
  }

  Item _getItem({@required Catalogue catalog}) {
    return Item(
      key: ValueKey(catalog.noteId),
      item: _getItemWidget(catalog: catalog),
      display: catalog.display,
      level: catalog.level,
    );
  }

  calDisplay() {
    for (Catalogue element in catalogs) {
      if (element.upIds.last == 'root') {
        element.display = true;
        continue;
      }
      bool display = true;
      element.upIds.forEach((element) {
        Catalogue up = catalogMap[element];
        if (!up.expanded) {
          display = false;
          return;
        }
      });
      element.display = display;
    }
  }

  Widget getCatalogRootWidget() {
    return Row(
      children: [
        Icon(
          Icons.double_arrow_outlined,
          color: Colors.black54,
          size: 18,
        ),
        Expanded(
          child: GestureDetector(
            child: Text(
              rootCatalog.title == '' ? '目录' : rootCatalog.title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  background: Paint()
                    ..style = PaintingStyle.fill
                    ..color = Colors.black12),
              maxLines: 1,
            ),
            onTap: () {},
          ),
        ),
        TextButton(
          child: Icon(
            Icons.account_tree_outlined,
            size: 24,
            color: Colors.black54,
          ),
          onPressed: () {},
          style: ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: MaterialStateProperty.all(Size(0, 0)),
            padding: MaterialStateProperty.all(EdgeInsets.zero),
            backgroundColor: MaterialStateProperty.all(Colors.white),
          ),
        ),
        SizedBox(
          width: 10,
          height: 24,
        )
      ],
    );
  }

  Widget _getItemWidget({@required Catalogue catalog}) {
    return Row(children: [
      SizedBox(
        width: 10.0 * catalog.level,
        height: 24,
      ),
      GestureDetector(
        child: Opacity(
          opacity: catalog.hasChild ? 1.0 : 0.0, //
          child: Icon(
            catalog.expanded
                ? Icons.keyboard_arrow_down
                : Icons.keyboard_arrow_right,
            color: Colors.black54,
          ),
        ),
        onTap: () {
          if (catalog.hasChild) {
            catalog.expanded = !catalog.expanded;
            print('expanded:${catalog.expanded}');
            calDisplay();
            catalogStateSetter(() {});
          }
        },
      ),
      Expanded(
          child: GestureDetector(
              child: Text(
                catalog.title == '' ? '新文稿' : catalog.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                maxLines: 1,
              ),
              onTap: () {})),
      SizedBox(
        width: 10,
        height: 24,
      ),
      TextButton(
        child: Icon(
          Icons.delete_outlined,
          size: 24,
          color: Colors.black54,
        ),
        onPressed: () {},
        style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: MaterialStateProperty.all(Size(0, 0)),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          backgroundColor: MaterialStateProperty.all(Colors.white),
        ),
      ),
      SizedBox(
        width: 5,
        height: 24,
      ),
      TextButton(
        child: Icon(
          Icons.add_box_outlined,
          size: 24,
          color: Colors.black54,
        ),
        onPressed: () {},
        style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: MaterialStateProperty.all(Size(0, 0)),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          backgroundColor: MaterialStateProperty.all(Colors.white),
        ),
      ),
      SizedBox(
        width: 5,
        height: 24,
      ),
      TextButton(
        child: Icon(
          Icons.account_tree_outlined,
          size: 24,
          color: Colors.black54,
        ),
        onPressed: () {},
        style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: MaterialStateProperty.all(Size(0, 0)),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          backgroundColor: MaterialStateProperty.all(Colors.white),
        ),
      ),
      SizedBox(
        width: 10,
        height: 24,
      )
    ]);
  }
}
