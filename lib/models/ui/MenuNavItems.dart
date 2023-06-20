class MenuNavItems {
  dynamic _strImage;
  dynamic _title;

  MenuNavItems([this._strImage,this._title]);

  get strImage => this._strImage;

  set strImage(value) => this._strImage = value;

  get title => this._title;

  set title(value) => this._title = value;
}
