class FileTopic {
  var id;
  var url;
  var type;

  FileTopic(this.id, {required this.url, required this.type});

  get getId => this.id;

  set setId(var id) => this.id = id;

   get getUrl => this.url ;

  set setUrl(url) => this.url = url;

  get getType => this.type;

  set setType(type) => this.type = type;
}
