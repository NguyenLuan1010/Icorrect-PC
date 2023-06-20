class HomeWorks {
  var _id;
  var _aiResponseLink;
  var _haveAIResponse;
  var _aiScore;
  var _aiOrder;
  var _startDate;
  var _endDate;
  var _start;
  var _end;
  var _startTime;
  var _endTime;
  var _name;
  var _description;
  var _testOption, _status;
  var _testID, _orderId;
  var _stubmitedDate;
  var _classId;
  var _className;
  var _activityType;
  var _isTested;

  HomeWorks(
      [this._id,
      this._aiResponseLink,
      this._haveAIResponse,
      this._aiScore,
      this._aiOrder,
      this._startDate,
      this._endDate,
      this._start,
      this._end,
      this._endTime,
      this._startTime,
      this._name,
      this._description,
      this._testOption,
      this._status,
      this._testID,
      this._orderId,
      this._stubmitedDate,
      this._classId,
      this._className,
      this._activityType,
      this._isTested]);

  get aiScore => this._aiScore;

  set aiScore(var value) => this._aiScore = value;

  get aiOrder => this._aiOrder;

  set aiOrder(value) => this._aiOrder = value;

  String get aiResponseLink => this._aiResponseLink ?? '';

  set aiResponseLink(value) => this._aiResponseLink = value;

  get haveAIResponse => this._haveAIResponse;

  bool haveAIScore() {
    return _aiOrder != 0;
  }

  set haveAIResponse(value) => this._haveAIResponse = value;

  int get testOption => this._testOption;

  set testOption(int value) => this._testOption = value;

  get testID => this._testID;

  set testID(value) => this._testID = value;

  get id => this._id;

  set id(value) => this._id = value;

  get startDate => this._startDate;

  set startDate(value) => this._startDate = value;

  get endDate => this._endDate;

  set endDate(value) => this._endDate = value;

  get start => this._start;

  set start(value) => this._start = value;

  String get end => this._end;

  set end(value) => this._end = value;

  get startTime => this._startTime;

  set startTime(value) => this._startTime = value;

  get endTime => this._endTime;

  set endTime(value) => this._endTime = value;

  get name => this._name;

  set name(value) => this._name = value;

  get description => this._description;

  set description(value) => this._description = value;

  get status => this._status;

  set status(value) => this._status = value;

  get orderId => this._orderId;

  set orderId(value) => this._orderId = value;

  get stubmitedDate => this._stubmitedDate;

  set stubmitedDate(value) => this._stubmitedDate = value;

  get classId => this._classId;

  set classId(value) => this._classId = value;

  get className => this._className;

  set className(value) => this._className = value;

  get activityType => this._activityType;

  set activityType(value) => this._activityType = value;

  get isTested => this._isTested;

  set isTested(value) => this._isTested = value;
}
