# draggable_tree_view

A draggable tree view for Flutter.

## Getting Started

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
    onDragStart: (int index, double start, double end) {
        Catalogue catalog = catalogs[index];
        if (catalog.expanded == true) {
            catalog.expanded = false;
            calDisplay();
            catalogStateSetter(() {});
        }
    },
    onDraging: (int oldIndex, int newIndex, int newPos,
        double start, double end) {
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
        // do something to reorder the list...
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
                    catalog.title == '' ? '新文稿' : catalog.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                    maxLines: 1,
                ),
                onTap: () {}
            )
        ),
    ]);
}

```
