import 'dart:collection';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';


import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_cef/webview_cef.dart';

import '../callbacks/ViewMainCallBack.dart';
import '../cutoms/NothingWidget.dart';
import '../dialog/AlertDialog.dart';
import '../dialog/CircleLoading.dart';
import '../models/Enums.dart';
import '../models/others/HomeWorks.dart';
import '../models/ui/AlertInfo.dart';
import '../presenter/HomeWorkPresenter.dart';
import '../provider/VariableProvider.dart';
import '../theme/app_themes.dart';
import 'ResultTestWidget.dart';
import 'my_test/AIResponseWidget.dart';
import 'simulator_test/DoingTest.dart';

class HomeWorksWidget extends StatefulWidget {
  const HomeWorksWidget({super.key});

  @override
  State<HomeWorksWidget> createState() => _HomeWorksWidgetState();
}

class _HomeWorksWidgetState extends State<HomeWorksWidget>
    implements GetHomeWorkCallBack, ActionAlertListener {
  late VariableProvider _provider;
  String _choosenClass = '';
  String _choosenStatus = '';
  List<HomeWorks> _homeworks = [];
  List<HomeWorks> _filterHomeWorks = [];

  CircleLoading? _loading;
  late HomeWorkPresenter _presenter;

  List<String> _classSelections = ['Alls'];
  final List<String> _statusSelections = [
    'Alls',
    'Submitted',
    'Corrected',
    'Not Completed',
    'Late',
    'Out of date'
  ];

  @override
  void initState() {
    super.initState();

    _provider = Provider.of<VariableProvider>(context, listen: false);
    _choosenClass = _classSelections.first;
    _choosenStatus = _statusSelections.first;
    _loading = CircleLoading();

    _loading?.show(context);
    _presenter = HomeWorkPresenter();
    _presenter.getHomeWorks(this);
  }

  @override
  void dispose() {
    dispose();
    super.dispose();
    _provider.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildWidget();
  }

  Widget _buildWidget() {
    return Container(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LayoutBuilder(builder: (context, contraints) {
              if (contraints.maxWidth < SizeScreen.MINIMUM_WiDTH_1.size) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      _buildClassFilterMobile(_classSelections),
                      const SizedBox(height: 10),
                      _buildStatusFilterMobile()
                    ],
                  ),
                );
              } else {
                return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 170),
                    child: Row(
                      children: [
                        _builClassFilterDesktop(_classSelections),
                        _buildStatusFilterDesktop()
                      ],
                    ));
              }
            }),
            LayoutBuilder(builder: (context, contraints) {
              if (contraints.maxWidth < SizeScreen.MINIMUM_WiDTH_1.size) {
                return _buildHomeworkListMobile();
              } else {
                return _buildHomeworkListDesktop();
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildClassFilterMobile(List<String> classSelections) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Class Filter",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _choosenClass,
          items: classSelections.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(fontSize: 15),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (mounted) {
              setState(() {
                _choosenClass = newValue ?? '';
                int status = _getFilterStatus(_choosenStatus);
                if (_homeworks.isNotEmpty) {
                  _filterHomeWorks = _presenter.filterHomeWorks(
                      _choosenClass, status, _homeworks);
                }
              });
            }
          },
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.deepPurple,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilterMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Status Filter",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _choosenStatus,
          items: _statusSelections.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(fontSize: 15),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (mounted) {
              setState(() {
                _choosenStatus = newValue ?? '';
                int status = _getFilterStatus(_choosenStatus);
                if (_homeworks.isNotEmpty) {
                  _filterHomeWorks = _presenter.filterHomeWorks(
                      _choosenClass, status, _homeworks);
                }
              });
            }
          },
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.deepPurple,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _builClassFilterDesktop(List<String> classSelections) {
    return Expanded(
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Class Filter",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _choosenClass,
                  items: classSelections.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 15),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (mounted) {
                      setState(() {
                        _choosenClass = newValue ?? '';
                        int status = _getFilterStatus(_choosenStatus);
                        if (_homeworks.isNotEmpty) {
                          _filterHomeWorks = _presenter.filterHomeWorks(
                              _choosenClass, status, _homeworks);
                        }
                      });
                    }
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.deepPurple,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            )));
  }

  Widget _buildStatusFilterDesktop() {
    return Expanded(
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Status Filter',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _choosenStatus,
                  items: _statusSelections.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 15),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (mounted) {
                      setState(() {
                        _choosenStatus = newValue ?? '';
                        int status = _getFilterStatus(_choosenStatus);
                        if (_homeworks.isNotEmpty) {
                          _filterHomeWorks = _presenter.filterHomeWorks(
                              _choosenClass, status, _homeworks);
                        }
                      });
                    }
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.deepPurple,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            )));
  }

  Widget _buildHomeworkListMobile() {
    double height = 400;

    return Container(
      margin: const EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 50),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemes.colors.purpleSlight2,
            const Color.fromARGB(0, 255, 255, 255),
            const Color.fromARGB(0, 255, 255, 255)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: DottedBorder(
          color: AppThemes.colors.purple,
          strokeWidth: 2,
          radius: const Radius.circular(50),
          dashPattern: const [8],
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 150,
                margin: const EdgeInsets.only(top: 20),
                child: InkWell(
                  onTap: () {
                    _loading?.show(context);
                    _presenter.getHomeWorks(this);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.refresh_rounded),
                      Text(
                        'Refresh Data',
                        style: TextStyle(
                            color: AppThemes.colors.purple,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                  child: Container(
                height: height,
                margin: const EdgeInsets.only(bottom: 10),
                child: (_filterHomeWorks.isNotEmpty)
                    ? ListView.builder(
                        itemCount: _filterHomeWorks.length,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        itemBuilder: (BuildContext context, int index) {
                          return _questionItemMobile(
                              _filterHomeWorks.elementAt(index));
                        })
                    : NothingWidget.init().buildNothingWidget(
                        'Nothing your homeworks in here',
                        widthSize: 250,
                        heightSize: 250),
              ))
            ],
          )),
    );
  }

  Widget _buildHomeworkListDesktop() {
    double height = 450;

    return Container(
      margin: const EdgeInsets.only(top: 20, left: 100, right: 100),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemes.colors.purpleSlight2,
            const Color.fromARGB(0, 255, 255, 255),
            const Color.fromARGB(0, 255, 255, 255)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: DottedBorder(
          color: AppThemes.colors.purple,
          strokeWidth: 2,
          radius: const Radius.circular(50),
          dashPattern: const [8],
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              InkWell(
                  onTap: () {
                    _loading?.show(context);
                    _presenter.getHomeWorks(this);
                  },
                  child: Container(
                    width: 120,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(Icons.refresh_rounded),
                          const SizedBox(width: 5),
                          Text('Refresh Data',
                              style: TextStyle(
                                color: AppThemes.colors.purple,
                                fontSize: 16,
                              )),
                        ]),
                  )),
              SingleChildScrollView(
                  child: Container(
                height: height,
                margin: const EdgeInsets.only(top: 20, bottom: 10),
                child: (_filterHomeWorks.isNotEmpty)
                    ? Center(
                        child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 7,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 1,
                        children: _filterHomeWorks
                            .map((data) => _questionItem(data))
                            .toList(),
                      ))
                    : NothingWidget.init().buildNothingWidget(
                        'Nothing your homeworks in here',
                        widthSize: 250,
                        heightSize: 250),
              ))
            ],
          )),
    );
  }

  Widget _questionItem(HomeWorks homeWork) {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1, color: AppThemes.colors.purple),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.only(right: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 2, color: AppThemes.colors.purple),
                    borderRadius: const BorderRadius.all(Radius.circular(100))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Part",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppThemes.colors.purple,
                            fontWeight: FontWeight.w400,
                            fontSize: 8)),
                    Text(_getPartOfTest(homeWork.testOption),
                        style: TextStyle(
                            color: AppThemes.colors.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 14))
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 300,
                      child: Text(homeWork.name.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 17, color: Colors.black))),
                  Row(
                    children: [
                      Text(
                          (homeWork.end.isNotEmpty)
                              ? homeWork.end.toString()
                              : '0000-00-00 00:00',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black)),
                      const Text(' | ',
                          style: TextStyle(fontSize: 12, color: Colors.black)),
                      Text(
                          (_getStatus(homeWork).isNotEmpty)
                              ? '${_getStatus(homeWork)['title']} ${_haveAiResponse(homeWork)}'
                              : '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: (_getStatus(homeWork).isNotEmpty)
                                ? _getStatus(homeWork)['color']
                                : AppThemes.colors.purple,
                          ))
                    ],
                  )
                ],
              ),
            ],
          ),
          (homeWork.status == Status.OUT_OF_DATE.get ||
                  homeWork.status == Status.NOT_COMPLETED.get)
              ? SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      if (context.mounted) {
                        _provider.setCurrentMainWidget(
                            DoingTest(homework: homeWork));
                        print('HomeWork Id : ${homeWork.id}');
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            AppThemes.colors.purple),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)))),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text("Start"),
                    ),
                  ),
                )
              : SizedBox(
                  width: 100,
                  child: ElevatedButton(
                      onPressed: () {
                        _provider.setCurrentMainWidget(
                            ResultTestWidget(homeWork: homeWork));
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.green),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)))),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text("Details"),
                      )),
                )
        ],
      ),
    );
  }

  Widget _questionItemMobile(HomeWorks homeWork) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1, color: AppThemes.colors.purple),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.only(right: 10, top: 5, bottom: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 2, color: AppThemes.colors.purple),
                    borderRadius: const BorderRadius.all(Radius.circular(100))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Part",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppThemes.colors.purple,
                            fontWeight: FontWeight.w400,
                            fontSize: 8)),
                    Text(_getPartOfTest(homeWork.testOption),
                        style: TextStyle(
                            color: AppThemes.colors.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 14))
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    child: Text(homeWork.name.toString(),
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(fontSize: 17, color: Colors.black)),
                  ),
                  Row(
                    children: [
                      Text(
                          (_getStatus(homeWork).isNotEmpty)
                              ? '${_getStatus(homeWork)['title']} ${_haveAiResponse(homeWork)}'
                              : '',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: (_getStatus(homeWork).isNotEmpty)
                                ? _getStatus(homeWork)['color']
                                : AppThemes.colors.purple,
                          )),
                      const Text('| ',
                          style: TextStyle(fontSize: 12, color: Colors.black)),
                      Text(
                          (homeWork.end.isNotEmpty)
                              ? homeWork.end.toString()
                              : '0000-00-00 00:00',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black)),
                    ],
                  )
                ],
              ),
            ],
          ),
          (homeWork.status == Status.OUT_OF_DATE.get ||
                  homeWork.status == Status.NOT_COMPLETED.get)
              ? SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      if (context.mounted) {
                        _provider.setCurrentMainWidget(
                            DoingTest(homework: homeWork));
                        print('HomeWork Id : ${homeWork.id}');
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            AppThemes.colors.purple),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)))),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text("Start"),
                    ),
                  ),
                )
              : SizedBox(
                  width: 100,
                  child: ElevatedButton(
                      onPressed: () {
                        _provider.setCurrentMainWidget(
                            ResultTestWidget(homeWork: homeWork));
                        print('homework id: ${homeWork.id.toString()}');
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.green),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)))),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("Details"),
                      )),
                )
        ],
      ),
    );
  }

  String _getPartOfTest(int option) {
    switch (option) {
      case 1:
        return 'I';
      case 2:
        return 'II';
      case 3:
        return 'III';
      case 4:
        return 'II&III';
      case 5:
        return 'FULL';
      case 6:
        return 'I&II';
      default:
        return 'NULL';
    }
  }

  String _haveAiResponse(HomeWorks homeWork) {
    return (homeWork.haveAIResponse == Status.TRUE.get) ? '& AI Scored' : '';
  }

  Map<String, dynamic> _getStatus(HomeWorks homeWork) {
    switch (homeWork.status) {
      case 1:
        return {
          'title': 'Submitted',
          'color': const Color.fromARGB(255, 45, 117, 243)
        };
      case 2:
        return {
          'title': 'Corrected',
          'color': const Color.fromARGB(255, 12, 201, 110)
        };
      case 0:
        return {
          'title': 'Not Completed',
          'color': const Color.fromARGB(255, 237, 179, 3)
        };
      case -1:
        return {'title': 'Late', 'color': Colors.orange};
      case -2:
        return {'title': 'Out of date', 'color': Colors.red};
      default:
        return {};
    }
  }

  @override
  void failToGetHomework(AlertInfo alertInfo) {
    if (mounted) {
      _loading?.hide();

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertsDialog.init().showDialog(context, alertInfo, this);
          });
    }
  }

  @override
  void getHomeWorksSuccess(List<HomeWorks> homeWorks) {
    _loading?.hide();
    if (mounted) {
      setState(() {
        _homeworks = homeWorks;
        _filterHomeWorks = homeWorks;
        _choosenClass = _classSelections.first;
        _choosenStatus = _statusSelections.first;
        _classSelections = _getClassSelect(homeWorks);
      });
    }
  }

  int _getFilterStatus(String status) {
    switch (status) {
      case 'Submitted':
        return 1;
      case 'Corrected':
        return 2;
      case 'Not Completed':
        return 0;
      case 'Late':
        return -1;
      case 'Out of date':
        return -2;
      default:
        return -10;
    }
  }

  List<String> _getClassSelect(List<HomeWorks> homeworks) {
    List<String> classNames = [];

    for (HomeWorks homeWork in homeworks) {
      if (homeWork.className != null &&
          homeWork.className.toString().isNotEmpty) {
        classNames.add(homeWork.className.toString());
      }
    }
    classNames.insert(0, 'Alls');
    return LinkedHashSet<String>.from(classNames).toList();
  }

  @override
  void onAlertExit(String keyInfo) {}

  @override
  void onAlertNextStep(String keyInfo) {
    HomeWorkPresenter presenter = HomeWorkPresenter();
    _loading?.show(context);
    presenter.getHomeWorks(this);
  }
}
