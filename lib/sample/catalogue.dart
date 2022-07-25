class Catalogue {
  String noteId;
  String title;
  String preId;
  String nextId;
  List<String> upIds;
  int level;
  bool hasChild;
  bool expanded = false;
  bool display = true;

  Catalogue(
      {this.noteId,
      this.title,
      this.preId,
      this.nextId,
      this.upIds,
      this.level,
      this.hasChild}) {
    this.display = !this.hasChild;
  }

  Catalogue.root() {
    this.noteId = 'root';
    this.title = '目录';
    this.preId = '';
    this.nextId = '';
    this.upIds = [];
    this.level = 0;
    this.hasChild = false;
    this.expanded = true;
    this.display = true;
  }
}
