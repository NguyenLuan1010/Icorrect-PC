import 'FileTopic.dart';

class QuestionTopic {
  var _id;
  var _content;
  var _type;
  var topic_id;
  bool? _is_follow_up;
  var _cue_card;
  var _tips;
  var _tip_type;
  var _reanswer_count;
  List<FileTopic>? _answers;
  var _numPart;
  List<FileTopic>? _files;

  QuestionTopic(
      [this._id,
      this._content,
      this._type,
      this._reanswer_count,
      this.topic_id,
      this._is_follow_up,
      this._cue_card,
      this._tips,
      this._tip_type,
      this._answers,
      this._files,
      this._numPart]);

  get numPart => this._numPart;

  set numPart(var value) => this._numPart = value;

  List<FileTopic>? get answers => this._answers ?? [];

  set answers(value) => this._answers = value;

  get reanswer_count => _reanswer_count;

  set reanswer_count(var value) => _reanswer_count = value;

  String get cue_card => _cue_card ?? '';

  set cue_card(value) => _cue_card = value;
  get id => _id;

  set id(var value) => _id = value;

  get content => _content;

  set content(value) => _content = value;

  get type => _type;

  set type(value) => _type = value;

  get topicid => topic_id;

  set topicid(value) => topic_id = value;
  bool? get is_follows_up => _is_follow_up;

  set is_follow_up(bool value) => _is_follow_up = value;

  get tips => _tips;

  set tips(value) => _tips = value;

  get tip_type => _tip_type;

  set tip_type(value) => _tip_type = value;

  List<FileTopic>? get files => _files;

  set files(value) => _files = value;

  void add(QuestionTopic question) {}
}
