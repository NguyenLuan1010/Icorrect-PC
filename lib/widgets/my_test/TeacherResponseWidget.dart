import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../cutoms/GradientBorderPainter.dart';
import '../../../theme/app_themes.dart';
import '../../callbacks/ViewMainCallBack.dart';
import '../../cutoms/NothingWidget.dart';
import '../../dialog/CircleLoading.dart';
import '../../dialog/ExampleProblemDialog.dart';
import '../../dialog/MessageDialog.dart';
import '../../models/Enums.dart';
import '../../models/my_test/ResultResponse.dart';
import '../../models/my_test/SkillProblem.dart';
import '../../models/others/HomeWorks.dart';
import '../../presenter/MyTestPresenter.dart';

class TeacherResponseWidget extends StatefulWidget {
  HomeWorks homeWork;
  TeacherResponseWidget({super.key, required this.homeWork});

  @override
  State<TeacherResponseWidget> createState() => _TeacherResponseWidgetState();
}

class _TeacherResponseWidgetState extends State<TeacherResponseWidget>
    implements ResultResponseTestCallBack {
  bool _selected = true;
  bool _visible = false;
  double _widthBonus = 35;

  late MyTestPresenter _presenter;
  CircleLoading? _loading;

  ResultResponse _resultResponse = ResultResponse();

  @override
  void initState() {
    _loading = CircleLoading();
    _loading?.show(context);
    _presenter = MyTestPresenter();
    _presenter.getResultResponse(widget.homeWork, this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildResultTest();
  }

  @override
  void reassemble() {
    _presenter.getResultResponse(widget.homeWork, this);
    super.reassemble();
  }

  Widget buildResultTest() {
    var radius = const Radius.circular(5);
    return LayoutBuilder(builder: (context, constaint) {
      return Container(
        margin: const EdgeInsets.only(bottom: 50),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
            color: AppThemes.colors.opacity,
            borderRadius: BorderRadius.all(radius),
            border: Border.all(color: Colors.black, width: 2)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    color: AppThemes.colors.purple),
                child: Text(
                    "Overall Score: ${_resultResponse.overallScore.toString()}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: Text(
                  _resultResponse.overallComment.toString(),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              (constaint.maxWidth < SizeScreen.MINIMUM_WiDTH_2.size)
                  ? _resultListMobileScreen()
                  : _resultListDesktopScreen()
            ],
          ),
        ),
      );
    });
  }

  Widget _resultListMobileScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _resultItem('Fluency: ${_resultResponse.fluency.toString()}',
            _resultResponse.fluencyProblem),
        const SizedBox(height: 20),
        _resultItem('Grammatical: ${_resultResponse.grammatical.toString()}',
            _resultResponse.grammaticalProblem),
        const SizedBox(height: 20),
        _resultItem(
            'Lexical Resource: ${_resultResponse.lexicalResource.toString()}',
            _resultResponse.lexicalResourceProblem),
        const SizedBox(height: 20),
        _resultItem(
            'Pronunciation: ${_resultResponse.pronunciation.toString()}',
            _resultResponse.pronunciationProblem)
      ],
    );
  }

  Widget _resultListDesktopScreen() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            _resultItem('Fluency: ${_resultResponse.fluency.toString()}',
                _resultResponse.fluencyProblem),
            const SizedBox(height: 20),
            _resultItem(
                'Grammatical: ${_resultResponse.grammatical.toString()}',
                _resultResponse.grammaticalProblem)
          ],
        ),
        Column(
          children: [
            _resultItem(
                'Lexical Resource: ${_resultResponse.lexicalResource.toString()}',
                _resultResponse.lexicalResourceProblem),
            const SizedBox(height: 20),
            _resultItem(
                'Pronunciation: ${_resultResponse.pronunciation.toString()}',
                _resultResponse.pronunciationProblem)
          ],
        )
      ],
    );
  }

  Widget _resultItem(String title, List<SkillProblem> problems) {
    double width = 400, height = 200;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Center(
          child: Container(
            width: width,
            height: height + (_visible ? _widthBonus : -_widthBonus),
            padding: EdgeInsets.zero,
            child: AnimatedAlign(
                alignment:
                    _selected ? Alignment.topRight : Alignment.bottomLeft,
                duration: const Duration(seconds: 1),
                curve: Curves.fastOutSlowIn,
                onEnd: () {
                  _visible = !_selected;
                },
                child: Visibility(
                    visible: _visible,
                    child: Container(
                      width: width,
                      height: height,
                      margin: EdgeInsets.zero,
                      child: CustomPaint(
                          painter: GradientBorderPainter(width, height),
                          child: (problems.isNotEmpty)
                              ? ListView.builder(
                                  itemCount: problems.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return _problemItem(
                                        index, problems.elementAt(index));
                                  })
                              : NothingWidget.init().buildNothingWidget(
                                  'No Problem and Solution in here.',
                                  widthSize: 150,
                                  heightSize: 150)),
                    ))),
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              _selected = !_selected;
              _visible = !_selected;
            });
          },
          child: Container(
            width: width - 50,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: AppThemes.colors.purple),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white)),
                (_selected && problems.isNotEmpty)
                    ? const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white,
                      )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _problemItem(int index, SkillProblem problem) {
    AudioPlayer audioPlayer = AudioPlayer();
    audioPlayer.stop();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber, color: Colors.amber),
                const SizedBox(width: 10),
                Text("Problem ${index > 0 ? index : ''}: ",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(problem.problem.toString(),
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w300)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.light_mode_outlined, color: Colors.amber),
                    const SizedBox(width: 10),
                    Text("Solution ${index > 0 ? index : ''}: ",
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold))
                  ],
                ),
              ),
              Visibility(
                  visible: problem.exampleText.isNotEmpty,
                  child: InkWell(
                    onTap: () {
                      ExampleProblemDialog dialog = ExampleProblemDialog();
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return dialog.showDialog(context, problem);
                          });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.all(color: AppThemes.colors.purple),
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text('Xem ví dụ',
                            style: TextStyle(
                                color: AppThemes.colors.purple, fontSize: 13)),
                      ),
                    ),
                  ))
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(problem.solution.toString(),
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w300)),
          )
        ],
      ),
    );
  }

  @override
  void resultResponseDetail(ResultResponse response) {
    _loading?.hide();
    if (mounted) {
      setState(() {
        _resultResponse = response;
      });
    }
  }

  @override
  void failToGetResultResponse(String message) {
    _loading?.hide();
  }
}
