import 'package:flutter/material.dart';

import '../../callbacks/ViewMainCallBack.dart';
import '../../cutoms/NothingWidget.dart';
import '../../dialog/CircleLoading.dart';
import '../../models/Enums.dart';
import '../../models/my_test/StudentsResults.dart';
import '../../presenter/MyTestPresenter.dart';
import '../../theme/app_themes.dart';

class OtherHomeWorks extends StatefulWidget {
  String activityId;
  OtherHomeWorks({super.key, required this.activityId});

  @override
  State<OtherHomeWorks> createState() => _OtherHomeWorksState();
}

class _OtherHomeWorksState extends State<OtherHomeWorks>
    implements GetHomeWorksByTypeCallBack {
  late MyTestPresenter _presenter;
  List<StudentsResults> _studentResult = [];
  CircleLoading? _loading;

  @override
  void initState() {
    super.initState();

    _loading = CircleLoading();
    _loading?.show(context);
    _presenter = MyTestPresenter();

    _presenter.getHighLightHomeWorks(
        widget.activityId, Status.OTHERS.get, this);
  }

  @override
  void reassemble() {
    super.reassemble();

    _presenter.getHighLightHomeWorks(
        widget.activityId, Status.HIGHTLIGHT.get, this);
  }

  @override
  Widget build(BuildContext context) {
    return _buildHighLightHomeWorks();
  }

  Widget _buildHighLightHomeWorks() {
    return Container(
        margin: const EdgeInsets.only(bottom: 50),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
            color: AppThemes.colors.opacity,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.black, width: 2)),
        child: LayoutBuilder(builder: (context, constraint) {
          if (_studentResult.isNotEmpty) {
            if (constraint.maxWidth < SizeScreen.MINIMUM_WiDTH_2.size) {
              return ListView.builder(
                  itemCount: _studentResult.length,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  itemBuilder: (BuildContext context, int index) {
                    return _othersItem(_studentResult.elementAt(index));
                  });
            } else {
              return Center(
                  child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 6,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
                children: _studentResult
                    .map(
                      (data) => _othersItem(data),
                    )
                    .toList(),
              ));
            }
          } else {
            return NothingWidget.init().buildNothingWidget(
                'No other homeworks in here.',
                widthSize: 200,
                heightSize: 200);
          }
        }));
  }

  Widget _othersItem(StudentsResults results) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey, width: 2)),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 170,
                  margin: const EdgeInsets.only(right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(0),
                        child: const CircleAvatar(
                          child: Image(
                            image: AssetImage("assets/default_avatar.png"),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Text(results.students!.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 92, 90, 90),
                              fontSize: 14,
                              fontWeight: FontWeight.w400))
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(results.activityResult!.name,
                        style: TextStyle(
                            color: AppThemes.colors.purple,
                            fontSize: 15,
                            fontWeight: FontWeight.w500)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('AI Score : ',
                            style: TextStyle(
                                color: AppThemes.colors.purple,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        Text(
                            (results.aiScore.toString().isEmpty)
                                ? 'No Score'
                                : '${results.aiScore}/9.0',
                            style: TextStyle(
                                color: AppThemes.colors.purple,
                                fontSize: 15,
                                fontWeight: FontWeight.w400))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Teacher Score : ',
                            style: TextStyle(
                                color: AppThemes.colors.purple,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        Text(
                            (results.overallScore.toString().isEmpty)
                                ? 'No Score'
                                : '${results.overallScore}/9.0',
                            style: TextStyle(
                                color: AppThemes.colors.purple,
                                fontSize: 15,
                                fontWeight: FontWeight.w400))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Time : ',
                            style: TextStyle(
                                color: AppThemes.colors.purple,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        Text(results.updateAt.toString(),
                            style: TextStyle(
                                color: AppThemes.colors.purple,
                                fontSize: 15,
                                fontWeight: FontWeight.w400))
                      ],
                    ),
                  ],
                )
              ],
            )
          ],
        ));
  }

  @override
  void failToHomeWorksByType(String message) {
    _loading?.hide();
  }

  @override
  void homeworksByType(List<StudentsResults> studentsResults) {
    if (mounted) {
      setState(() {
        _studentResult = studentsResults;
      });
    }
    _loading?.hide();
  }
}
