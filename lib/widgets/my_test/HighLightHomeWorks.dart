import 'package:flutter/material.dart';


import '../../callbacks/ViewMainCallBack.dart';
import '../../cutoms/NothingWidget.dart';
import '../../dialog/CircleLoading.dart';
import '../../models/Enums.dart';
import '../../models/my_test/StudentsResults.dart';
import '../../presenter/MyTestPresenter.dart';
import '../../provider/VariableProvider.dart';
import '../../theme/app_themes.dart';

class HighLightHomeWorks extends StatefulWidget {
  String activityId;
  HighLightHomeWorks({super.key, required this.activityId});

  @override
  State<HighLightHomeWorks> createState() => _HighLightHomeWorksState();
}

class _HighLightHomeWorksState extends State<HighLightHomeWorks>
    implements GetHomeWorksByTypeCallBack {
  late VariableProvider _provider;
  late MyTestPresenter _presenter;
  List<StudentsResults> _studentResult = [];
  CircleLoading? _loading;

  @override
  void initState() {
    super.initState();
    _provider = VariableProvider();
    _loading = CircleLoading();
    _loading?.show(context);
    _presenter = MyTestPresenter();

    _presenter.getHighLightHomeWorks(
        widget.activityId, Status.HIGHTLIGHT.get, this);
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
                    return _highLightItem(_studentResult.elementAt(index));
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
                      (data) => _highLightItem(data),
                    )
                    .toList(),
              ));
            }
          } else {
            return NothingWidget.init().buildNothingWidget(
                'No highlight homeworks in here.',
                widthSize: 200,
                heightSize: 200);
          }
        }));
  }

  Widget _highLightItem(StudentsResults results) {
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
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/img_tag.png")),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
                child: Text(
                    (results.overallScore.toString() == '0.0')
                        ? results.aiScore.toString()
                        : results.overallScore.toString(),
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center),
              ),
            ),
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
                        Text('${results.aiScore}/9.0',
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
                        Text('${results.overallScore}/9.0',
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
    print(message);
  }

  @override
  void homeworksByType(List<StudentsResults> studentsResults) {
    setState(() {
      _studentResult = studentsResults;
    });
    _loading?.hide();
  }
}
