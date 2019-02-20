import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_colorpicker/material_picker.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:ymwy_number/sign.dart';
import 'package:ymwy_number/ymwy_sp.dart';

Future main() async {
  runApp(MaterialApp(
    theme: ThemeData(
      backgroundColor: Colors.white,
    ),
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

const NUMBERS = [
  '0',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '一',
  '二',
  '三',
  '四',
  '五',
  '六',
  '七',
  '八',
  '九',
  '十',
  '千',
  '万'
];
var NUMBERS_MAP = NUMBERS.asMap();

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  Signature _signatureCanvas;

  TabController _tabController;
  var _tabIndex = 0;
  var _currentOrientation = Orientation.portrait;

  // create some value
  Color _pickerColor;
  Color _currentColor;
  Color _currentTextColor = Colors.white;
  ValueChanged<Color> onColorChanged;

  Color _penColor = Colors.black;

// bind some values with [ValueChanged<Color>] callback
  void changeThemeColor(Color color) {
    setState(() => _pickerColor = color);
    saveThemeColor(color);
  }

  void changePenColor(Color color) {
    setState(() => _penColor = color);
    savePenColor(color);
    _signatureCanvas.updatePenColor(penColor: _penColor);
  }

  void _whenTabChange() {
    if (_tabIndex != _tabController.index) {
      _tabIndex = _tabController.index;
      _signatureCanvas.clear();
      setState(() {});
    }
  }

  @override
  void initState() {
    _initData();
    _tabController = TabController(length: NUMBERS.length, vsync: this);
    super.initState();
    _tabController.animateTo(_tabIndex);
    _tabController.addListener(_whenTabChange);
  }

  Future _initData() async {
    _currentColor = await getThemeColor(defaultColor: Colors.blue);
    _penColor = await getPenColor(defaultColor: Colors.black);
    setState(() {});
    Future.delayed(Duration(seconds: 1),(){
      _changeStatusBarColor();
    });
    _signatureCanvas.updatePenColor(penColor: _penColor);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabController.removeListener(_whenTabChange);
    super.dispose();
  }

  Widget _createPageView(BuildContext ctx) {
    double _fontSize = (_currentOrientation == Orientation.portrait
            ? MediaQuery.of(ctx).size.width
            : MediaQuery.of(ctx).size.height) /
        4.0;
    Widget _pageView = TabBarView(
      children: NUMBERS_MAP.values
          .map(
            (value) => Container(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        value,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: _fontSize,
                        ),
                      ),
                    ],
                  ),
                ),
          )
          .toList(),
      controller: _tabController,
    );
    return _pageView;
  }

  void _fabClick() async {
    var result = await showModalBottomSheet(
      context: context,
      builder: (ctx) => Center(
            child: Wrap(
              children: NUMBERS_MAP.keys
                  .map(
                    (val) => FlatButton(
                          color: _tabIndex == val ? Colors.green : Colors.white,
                          onPressed: () {
                            Navigator.of(context).pop(val);
                          },
                          child: Text(
                            NUMBERS_MAP[val],
                            style: TextStyle(
                              fontSize: 23.0,
                              color: _tabIndex == val
                                  ? Colors.white
                                  : Colors.blueGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  )
                  .toList(),
            ),
          ),
    );
    if (result != null && result != _tabIndex) {
      setState(() {
        _tabIndex = result;
        _signatureCanvas.clear();
        _tabController.animateTo(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _currentOrientation = MediaQuery.of(context).orientation;
    if (_signatureCanvas == null) {
      _signatureCanvas = Signature(
        backgroundColor: Colors.transparent,
        penStrokeWidth: 6.0,
        penColor: _penColor,
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _currentColor,
        title: GestureDetector(
          onLongPress: _showColorPick,
          child: Text(
            "雨檬识字",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _currentTextColor,
            ),
          ),
        ),
        leading: Opacity(
          opacity: _tabIndex == 0 ? 0 : 1,
          child: IconButton(
              iconSize: 36.0,
              color: _currentTextColor,
              icon: Icon(Icons.keyboard_arrow_left),
              onPressed: () {
                if (_tabIndex == 0) return;
                _tabController.animateTo(_tabIndex - 1);
              }),
        ),
        actions: <Widget>[
          Opacity(
            opacity: _tabIndex == NUMBERS.length - 1 ? 0 : 1,
            child: IconButton(
                iconSize: 36.0,
                color: _currentTextColor,
                icon: Icon(Icons.keyboard_arrow_right),
                onPressed: () {
                  if (_tabIndex == NUMBERS.length - 1) return;
                  _tabController.animateTo(_tabIndex + 1);
                }),
          ),
        ],
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _currentColor,
        elevation: 1.0,
        onPressed: _fabClick,
        child: Icon(
          Icons.airplanemode_active,
          color: _currentTextColor,
          size: 36.0,
        ),
      ),
      body: _currentOrientation == Orientation.portrait
          ? Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    _signatureCanvas,
                  ],
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 4.0,
                  child: _createPageView(context),
                ),
                Positioned(
                  child: _buildBottomLayout(),
                  bottom: 0.0,
                  right: 0.0,
                  left: 0.0,
                ),
              ],
            )
          : Stack(
              children: <Widget>[
                Positioned(
                  child: Column(
                    children: <Widget>[
                      _signatureCanvas,
                    ],
                  ),
                  left: 0.0,
                  right: 0.0,
                  top: 0.0,
                  bottom: 0.0,
                ),
                Positioned(
                  left: 0.0,
                  top: 0.0,
                  right: MediaQuery.of(context).size.width * 3 / 4.0,
                  bottom: 40.0,
                  child: _createPageView(context),
                ),
                Positioned(
                  child: _buildBottomLayout(),
                  bottom: 0.0,
                  right: 0.0,
                  left: 0.0,
                ),
              ],
            ),
    );
  }

  Container _buildBottomLayout() {
    return Container(
      color: _currentColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          GestureDetector(
            onLongPress: _choosePenColor,
            child: IconButton(
              icon: const Icon(Icons.cake),
              iconSize: 36.0,
              color: _currentTextColor,
              onPressed: () {
                setState(() {
                  return _signatureCanvas.clear();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPick() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('自定义颜色'),
              content: SingleChildScrollView(
//          child: ColorPicker(
//            pickerColor: pickerColor,
//            onColorChanged: changeColor,
//            enableLabel: true,
//            pickerAreaHeightPercent: 0.8,
//          ),
                // Use Material color picker
                child: MaterialPicker(
                  pickerColor: _pickerColor,
                  onColorChanged: changeThemeColor,
                  enableLabel: true, // only on portrait mode
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('选好了'),
                  onPressed: () {
                    _currentColor = _pickerColor;
                    Navigator.of(context).pop();
                    _changeStatusBarColor();
                  },
                ),
              ],
            ));
  }

  Future _changeStatusBarColor() async {
    Color color = Color.fromARGB(
        0xEF, _currentColor.red, _currentColor.green, _currentColor.blue);
    bool _lightColor = color.computeLuminance() < 0.5;
    _currentTextColor = _lightColor ? Colors.white : Colors.black;
    setState(() {});
    await FlutterStatusbarcolor.setStatusBarColor(color);
    await FlutterStatusbarcolor.setStatusBarWhiteForeground(!_lightColor);
  }

  void _choosePenColor() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('选择喜欢的画笔颜色'),
              content: SingleChildScrollView(
                child: BlockPicker(
                  pickerColor: _penColor,
                  onColorChanged: changePenColor,
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('选好啦'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }
}
