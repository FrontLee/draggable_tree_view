# draggable_tree_view

A draggable tree view for Flutter.

# Installing

Add this to your pubspec.yaml file

```
dependencies:
  draggable_tree_view: ^0.0.3
```

And run

```
flutter packages get
```

# Example

You need to provide a flat list for tree data. For example,

### Original tree data:
Node 1   
|-- Node 2   
|-- Node 3   
|-- Node 4   
|&nbsp;&nbsp;&nbsp;|-- Node 5   
|&nbsp;&nbsp;&nbsp;'-- Node 6   
Node 7   
'-- Node 8   

### Provided tree data:
Node 1    
Node 2   
Node 3   
Node 4   
Node 5   
Node 6   
Node 7   
Node 8   

Each node with following properties:    
Key key: required.   
Widget item: the widget to diaplay node. Required.   
int display: control the draggable tree view either to show this node or not. For example, collapse Node 1, Node 2~6 should set display to false. You should handle the node display by your self.    
int level: the node indent level, to determine the drag target indicator shown position. Default 0.   

```
DraggableTreeView(
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
        // start: according to axis, the drag item start position
        // end: according to axis, the drag item end position
        Catalogue catalog = catalogs[index];
        if (catalog.expanded == true) {
            catalog.expanded = false;
            calDisplay();
            catalogStateSetter(() {});
        }
    },
    onDraging: (int oldIndex, int newIndex, int newPos,
        double start, double end) {
        // oldIndex: drag index
        // newIndex: target index
        // newPos: to target's 1-before 2-middle 3-after
        // start: according to axis, the target item start position
        // end: according to axis, the target item end position

    },
    onHovering: (int index) {
        Catalogue catalog = catalogs[index];
        if (catalog.expanded == false) {
            catalog.expanded = true;
            calDisplay();
            catalogStateSetter(() {});
        }
    },
    onDragEnd: (int oldIndex, int newIndex, int newPos) {
        // oldIndex: drag index
        // newIndex: target index
        // newPos: to target's 1-before 2-middle 3-after
    },
)

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
      key: ValueKey(catalog.articleId),
      item: _getItemWidget(catalog: catalog),
      display: catalog.display,
      level: catalog.level,
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
                if (!catalog.hasChild) return;
                catalog.expanded = !catalog.expanded;
                calDisplay();
                catalogStateSetter(() {});
            },
        ),
        Expanded(
            child: GestureDetector(
                child: Text(
                    catalog.title == '' ? '?????????' : catalog.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                    maxLines: 1,
                ),
                onTap: () {}
            )
        ),
    ]);
}

```

# Sample

<img src="http://files.ortrue.cn/draggable_tree_view.gif" alt="show" />

Sample code, please view /example, when you try the sample code, please do following step:

1???copy files under /example/images to your project /images

2??? add following code to your pubspec.yaml
```
flutter:
  assets:
    - images/indicator.png
    - images/indicator_center.png
```

3??? copy /example/catalogue.dart and /example/draggable_tree_view.dart to your project, fix import and set your home to DraggableTreeViewTest(), as follow:

```
void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // primaryColor: Color.fromARGB(255, 67, 150, 156),
        primaryColor: Color.fromARGB(255, 59, 132, 137),
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:  DraggableTreeViewTest(),
    );
  }
}
```

