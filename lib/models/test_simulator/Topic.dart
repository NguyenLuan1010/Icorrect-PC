import 'dart:collection';

import 'FileTopic.dart';
import 'QuestionTopic.dart';

class Topic {
  var _id;
  var _title;
  var _description;
  var _topicType;
  var _status;
  var _level;
  var _staffCreated;
  var _staffUpdated;
  var _updatedAt;
  var _createdAt;
  var _deletedAt;
  var _distributeCode;
  var _numPart;
  var _jsonString;

  var _followUp;
  var _endOfTest;
  FileTopic? _fileEndOfTest;
  List<QuestionTopic>? _questions;
  List<FileTopic>? _files;

  Topic(
      [this._numPart,
      this._id,
      this._title,
      this._description,
      this._topicType,
      this._status,
      this._level,
      this._staffCreated,
      this._staffUpdated,
      this._updatedAt,
      this._createdAt,
      this._deletedAt,
      this._distributeCode,
      this._jsonString,
      this._followUp,
      this._endOfTest,
      this._fileEndOfTest,
      this._questions,
      this._files]);

  get jsonString => this._jsonString;

  set jsonString(value) => this._jsonString = value;

  int get numPart => this._numPart ?? 0;

  set numPart(int value) => this._numPart = value;

  List<QuestionTopic> get followUp => this._followUp ?? [];

  set followUp(List<QuestionTopic> value) => this._followUp = value;

  ///////////////////////////////////////////////////////

  Map<String, dynamic> get endOfTest => this._endOfTest ?? {};

  set endOfTest(Map<String, dynamic> value) => this._endOfTest = value;

  //// EDIT END OF TEST ///

  FileTopic? get fileEndOfTest => this._fileEndOfTest;

  set fileEndOfTest(FileTopic? value) => this._fileEndOfTest = value;

  //////////////////////////////////////////

  get description => this._description;

  set description(var value) => this._description = value;

  get topicType => this._topicType;

  set topicType(value) => this._topicType = value;

  get status => this._status;

  set status(value) => this._status = value;

  get level => this._level;

  set level(value) => this._level = value;

  get staffCreated => this._staffCreated;

  set staffCreated(value) => this._staffCreated = value;

  get staffUpdated => this._staffUpdated;

  set staffUpdated(value) => this._staffUpdated = value;

  get updatedAt => this._updatedAt;

  set updatedAt(value) => this._updatedAt = value;

  get createdAt => this._createdAt;

  set createdAt(value) => this._createdAt = value;

  get deletedAt => this._deletedAt;

  set deletedAt(value) => this._deletedAt = value;

  get distributeCode => this._distributeCode;

  set distributeCode(value) => this._distributeCode = value;

  get id => this._id;

  set id(var value) => this._id = value;

  get title => this._title;

  set title(value) => this._title = value;

  List<QuestionTopic>? get questions => this._questions ?? [];

  set questions(value) => this._questions = value;

  List<FileTopic>? get files => this._files ?? [];

  set files(value) => this._files = value;
}
