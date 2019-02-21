import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ymwy_number/ymwy_data.dart';

const SP_KEY_THEME_COLOR = "SP_KEY_THEME_COLOR";
const SP_KEY_PEN_COLOR = "SP_KEY_PEN_COLOR";
const SP_KEY_TEXT = "SP_KEY_TEXT";

Future saveThemeColor(Color color) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setInt(SP_KEY_THEME_COLOR, color.value);
}

Future savePenColor(Color color) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setInt(SP_KEY_PEN_COLOR, color.value);
}

Future saveText(List<String> texts) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setStringList(SP_KEY_TEXT, texts);
}

Future<List<String>> getText({List<String> defaultList = YMWY_NUMBERS}) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  var result = sharedPreferences.getStringList(SP_KEY_TEXT);
  return result ?? defaultList;
}

Future<Color> getThemeColor({Color defaultColor = Colors.red}) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  var result = sharedPreferences.get(SP_KEY_THEME_COLOR);
  return Color(int.tryParse("$result") ?? defaultColor.value);
}

Future<Color> getPenColor({Color defaultColor = Colors.black}) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  var result = sharedPreferences.get(SP_KEY_PEN_COLOR);
  return Color(int.tryParse("$result") ?? defaultColor.value);
}
