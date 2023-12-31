
import 'SkillFileDetail.dart';

class SkillProblem {
  var _id;
  var _problem;
  var _solution;
  var _type;
  var _orderId;
  var _component;
  var _fileId;
  var _exampleText;
  var _updatedAt;
  var _createdAt;
  var _deletedAt;
  var _typeName;
  var _fileName;
  SkillFileDetail? _fileDetail;

  SkillProblem(
      [this._id,
      this._problem,
      this._solution,
      this._type,
      this._orderId,
      this._component,
      this._fileId,
      this._exampleText,
      this._updatedAt,
      this._createdAt,
      this._deletedAt,
      this._typeName,
      this._fileName,
      this._fileDetail]);

  get id => this._id;

  set id(var value) => this._id = value;

  get problem => this._problem;

  set problem(value) => this._problem = value;

  get solution => this._solution;

  set solution(value) => this._solution = value;

  get type => this._type;

  set type(value) => this._type = value;

  get orderId => this._orderId;

  set orderId(value) => this._orderId = value;

  get component => this._component;

  set component(value) => this._component = value;

  get fileId => this._fileId;

  set fileId(value) => this._fileId = value;

 String get exampleText => this._exampleText ??'';

  set exampleText(value) => this._exampleText = value;

  get updatedAt => this._updatedAt;

  set updatedAt(value) => this._updatedAt = value;

  get createdAt => this._createdAt;

  set createdAt(value) => this._createdAt = value;

  get deletedAt => this._deletedAt;

  set deletedAt(value) => this._deletedAt = value;

  get typeName => this._typeName;

  set typeName(value) => this._typeName = value;

  get fileName => this._fileName;

  set fileName(value) => this._fileName = value;

  SkillFileDetail? get fileDetail => _fileDetail;

  set fileDetail(value) => this._fileDetail = value;
}
