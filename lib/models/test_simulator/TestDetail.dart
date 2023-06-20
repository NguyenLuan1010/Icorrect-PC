import 'Topic.dart';

class TestDetail {
  String? _id;
  String? _status;
  String? _activityType;
  String? _testOption;
  Topic? _introduce;
  List<Topic>? _part1;
  Topic? _part2;
  Topic? _part3;
  String? _domainName;
  String? _testId;
  String? _checkSum;
  String? _updateAt;
  String? _hasOrder;

  TestDetail(
      [this._id,
      this._status,
      this._activityType,
      this._testOption,
      this._introduce,
      this._part1,
      this._part2,
      this._part3,
      this._domainName,
      this._testId,
      this._checkSum,
      this._updateAt,
      this._hasOrder]);

  String? get id => this._id;

  set id(String? value) => this._id = value;

  get status => this._status;

  set status(value) => this._status = value;

  String? get activityType => this._activityType;

  set activityType(String? value) => this._activityType = value;

  get testOption => this._testOption;

  set testOption(value) => this._testOption = value;

  Topic? get introduce => this._introduce ;

  set introduce(value) => this._introduce = value;

  List<Topic>? get part1 => this._part1;

  set part1(value) => this._part1 = value;

  Topic? get part2 => this._part2 ;

  set part2(value) => this._part2 = value;

  Topic? get part3 => this._part3 ;

  set part3(value) => this._part3 = value;

  get domainName => this._domainName;

  set domainName(value) => this._domainName = value;

  get testId => this._testId;

  set testId(value) => this._testId = value;

  get checkSum => this._checkSum;

  set checkSum(value) => this._checkSum = value;
  get updateAt => this._updateAt;

  set updateAt(value) => this._updateAt = value;

  get hasOrder => this._hasOrder;

  set hasOrder(value) => this._hasOrder = value;
}
