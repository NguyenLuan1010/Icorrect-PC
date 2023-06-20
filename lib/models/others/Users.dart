import 'dart:convert';
import 'dart:math';

class Users {
  var _userId,
      _displayName,
      _phone,
      _email,
      _countryCode,
      _countryName,
      _countryFlag,
      _birthday,
      _avatar,
      _inviteCode,
      _numberInvited,
      _type,
      _transferCode,
      _target;

  var _gender, _totalPoint;

  var _notify, _vip, _showConversation, _conversationMessage;
  var _distributeCode;
  var _usd;

  var _numOfLike, _numOfFollow, _monthlyVip;

  var _select;
  var _firstDeposit;
  var _savedTime;

  Users(
      [this._userId,
      this._displayName,
      this._phone,
      this._email,
      this._countryCode,
      this._countryName,
      this._countryFlag,
      this._birthday,
      this._avatar,
      this._inviteCode,
      this._numberInvited,
      this._type,
      this._transferCode,
      this._target,
      this._gender,
      this._totalPoint,
      this._notify,
      this._vip,
      this._showConversation,
      this._conversationMessage,
      this._distributeCode,
      this._usd,
      this._numOfLike,
      this._numOfFollow,
      this._monthlyVip,
      this._select,
      this._firstDeposit,
      this._savedTime]);

  String get userId => _userId;

  static Users userInfo(Map<String, dynamic> dataMap) {
    print("data: ${dataMap.toString()}");
    String userInfoJson = jsonEncode(dataMap['user_info']).toString();
    Map<String, dynamic> userInfoMap = jsonDecode(userInfoJson);
    String email = userInfoMap['email'].toString();
    String distributeCode = userInfoMap['distributor_code'].toString();
    String inviteCode = userInfoMap['invite_code'].toString();
    var type = userInfoMap['type'];

    String profileJson = jsonEncode(dataMap['profile']).toString();
    Map<String, dynamic> profileMap = jsonDecode(profileJson);
    String userId = profileMap['user_id'].toString();
    String displayName = profileMap['display_name'].toString();
    String phone = profileMap['phone'].toString();
    String birthday = profileMap['birthday'].toString();
    String avatar = profileMap['avatar'].toString();
    var numInvited = profileMap['invited'];
    var target = profileMap['target'];
    var gender = profileMap['gender'];
    var pointTotal = profileMap['point_total'];
    var vip = profileMap['vip'];
    var numLike = profileMap['likes'];
    var numFollow = profileMap['follow'];
    var monthlyVip = profileMap['monthly_vip'];

    var notify = dataMap['notify'];
    var showConversation = dataMap['show_conversation'];
    var conversationMessage = dataMap['conversation_message'];
    var firstDeposite = dataMap['fist_deposit'];

    String walletJson = jsonEncode(profileMap['wallet']).toString();
    Map<String, dynamic> walletMap = jsonDecode(walletJson);
    String codeTransfer = walletMap['code_transfer'].toString();
    var usd = walletMap['usd'];

    String countryJson = jsonEncode(profileMap['country']).toString();
    Map<String, dynamic> countryMap = jsonDecode(countryJson);
    var countryCode = countryMap['id'];
    String countryName = countryMap['name'].toString();

    return Users(
        userId,
        displayName,
        phone,
        email,
        countryCode,
        countryName,
        "",
        birthday,
        avatar,
        inviteCode,
        numInvited,
        type,
        codeTransfer,
        target,
        gender,
        pointTotal,
        notify,
        vip,
        showConversation,
        conversationMessage,
        distributeCode,
        usd,
        numLike,
        numFollow,
        monthlyVip,
        1,
        firstDeposite);
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': _userId,
      'display_name': _displayName,
      'phone': _phone,
      'email': _email,
      'country_code': _countryCode,
      'country_name': _countryName,
      'country_flag': _countryFlag,
      'birthday': _birthday,
      'avatar': _avatar,
      'invited_code': _inviteCode,
      'num_invited': _numberInvited,
      'type': _type,
      'code_transfer': _transferCode,
      'target': _target,
      'gender': _gender,
      'point_total': _totalPoint,
      'notify': _notify,
      'vip': _vip,
      'show_conversation': _showConversation,
      'conversation_message': _conversationMessage,
      'distribute_code': _distributeCode,
      'usd': _usd,
      'num_of_like': _numOfLike,
      'num_of_follow': _numOfFollow,
      'monthly_vip': _monthlyVip,
      'select': _select,
      'first_deposite': _firstDeposit,
      'saved_time':_savedTime
    };
  }

  static Users fromJson(Map<String, dynamic> json) {
    return Users(
      json['user_id'],
      json['display_name'],
      json['phone'],
      json['email'],
      json['country_code'],
      json['country_name'],
      json['country_flag'],
      json['birthday'],
      json['avatar'],
      json['invited_code'],
      json['num_invited'],
      json['type'],
      json['code_transfer'],
      json['target'],
      json['gender'],
      json['point_total'],
      json['notify'],
      json['vip'],
      json['show_conversation'],
      json['conversation_message'],
      json['distribute_code'],
      json['usd'],
      json['num_of_like'],
      json['num_of_follow'],
      json['monthly_vip'],
      json['select'],
      json['first_deposite'],
      json['saved_time']
    );
  }

  set userId(String value) {
    _userId = value;
  }

  get savedTime => this._savedTime;

  set savedTime(value) => this._savedTime = value;

  get displayName => _displayName;

  int get firstDeposit => _firstDeposit;

  set firstDeposit(int value) {
    _firstDeposit = value;
  }

  int get select => _select;

  set select(int value) {
    _select = value;
  }

  get monthlyVip => _monthlyVip;

  set monthlyVip(value) {
    _monthlyVip = value;
  }

  get numOfFollow => _numOfFollow;

  set numOfFollow(value) {
    _numOfFollow = value;
  }

  int get numOfLike => _numOfLike;

  set numOfLike(int value) {
    _numOfLike = value;
  }

  double get usd => double.parse(_usd.toString());

  set usd(double value) {
    _usd = value;
  }

  String get distributeCode => _distributeCode;

  set distributeCode(String value) {
    _distributeCode = value;
  }

  get conversationMessage => _conversationMessage;

  set conversationMessage(value) {
    _conversationMessage = value;
  }

  get showConversation => _showConversation;

  set showConversation(value) {
    _showConversation = value;
  }

  get vip => _vip;

  set vip(value) {
    _vip = value;
  }

  int get notify => _notify;

  set notify(int value) {
    _notify = value;
  }

  get totalPoint => _totalPoint;

  set totalPoint(value) {
    _totalPoint = value;
  }

  int get gender => _gender;

  set gender(int value) {
    _gender = value;
  }

  get target => _target;

  set target(value) {
    _target = value;
  }

  get transferCode => _transferCode;

  set transferCode(value) {
    _transferCode = value;
  }

  get type => _type;

  set type(value) {
    _type = value;
  }

  get numberInvited => _numberInvited;

  set numberInvited(value) {
    _numberInvited = value;
  }

  get inviteCode => _inviteCode;

  set inviteCode(value) {
    _inviteCode = value;
  }

  get avatar => _avatar;

  set avatar(value) {
    _avatar = value;
  }

  get birthday => _birthday;

  set birthday(value) {
    _birthday = value;
  }

  get countryFlag => _countryFlag;

  set countryFlag(value) {
    _countryFlag = value;
  }

  get countryName => _countryName;

  set countryName(value) {
    _countryName = value;
  }

  get countryCode => _countryCode;

  set countryCode(value) {
    _countryCode = value;
  }

  get email => _email;

  set email(value) {
    _email = value;
  }

  get phone => _phone;

  set phone(value) {
    _phone = value;
  }

  set displayName(value) {
    _displayName = value;
  }
}
