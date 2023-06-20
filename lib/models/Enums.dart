enum Status {
  CORRECTED(2),
  LATE(-1),
  OUT_OF_DATE(-2),
  SUBMITTED(1),
  NOT_COMPLETED(0),
  TRUE(1),
  FALSE(0),
  HIGHTLIGHT(1),
  OTHERS(0),
  HAD_SCORE(1),
  ALL_HOMEWORK(-1);

  const Status(this.get);

  final int get;
}

enum Type {
  TEST("test"),
  HOMEWORK("homework");

  const Type(this.get);

  final String get;
}

enum SizeScreen {
  MINIMUM_WiDTH_1(1200),
  MINIMUM_WiDTH_2(900);

  const SizeScreen(this.size);
  final double size;
}

enum Alert {
  NETWORK_ERROR({
    Alert.cancelTitle: 'Exit',
    Alert.actionTitle: 'Try again',
    Alert.icon: 'assets/img_no_internet.png'
  }),
  SERVER_ERROR({
    Alert.cancelTitle: 'Exit',
    Alert.actionTitle: 'Contact with us',
    Alert.icon: 'assets/img_server_error.png'
  }),

  WARNING({
    Alert.cancelTitle: 'Cancel',
    Alert.actionTitle: 'Out the test',
    Alert.icon: 'assets/img_warning.png'
  }),

  DOWNLOAD_ERROR({
    Alert.cancelTitle: 'Exit',
    Alert.actionTitle: 'Try again',
    Alert.icon: 'assets/img_server_error.png'
  }),

  DATA_NOT_FOUND({
    Alert.cancelTitle: 'Exit',
    Alert.actionTitle: 'Try again',
    Alert.icon: 'assets/img_not_found.png'
  });

  const Alert(this.type);
  static const cancelTitle = 'cancel_title';
  static const actionTitle = 'action_title';
  static const icon = 'icon';
  final Map<String, String> type;
}

enum PartOfTest {
  INTRODUCE(0),
  PART1(1),
  PART2(2),
  PART3(3),
  FOLLOW_UP(4),
  END_OF_TEST(5);

  const PartOfTest(this.get);
  final int get;
}

enum Question {
  FILE_INTRO(0),
  INTRODUCE(1),
  PART1(2),
  PART2(3),
  PART3(4),
  FOLLOW_UP(5),
  END_OF_QUESTION(6);

  const Question(this.part);
  final int part;
}
