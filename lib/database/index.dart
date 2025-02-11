
import 'package:hive/hive.dart';

class DataService {
  static final String _boxName = 'my_data';

  static Box _dataBox = Hive.box(_boxName);

  static Future<void> addData(Map<String, dynamic> data) async {
    await _dataBox.add(data);
  }

  static List<Map<String, dynamic>> getData() {
    List<Map<String, dynamic>> dataList = [];
    for (var i = 0; i < _dataBox.length; i++) {
      dataList.add(_dataBox.getAt(i) as Map<String, dynamic>);
    }
    return dataList;
  }
}
