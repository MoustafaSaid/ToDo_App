import 'package:sqflite/sqflite.dart';
import 'package:todo/models/task.dart';

class DBHelper {

  static Database? db;
  static const int version = 1;
  static const String tableName = 'tasks';

  static Future<void> initDb() async {
    if (db != null) {
      return;
    } else {
      try {
        String path = '${await getDatabasesPath()}task.db';
        db = await openDatabase(
            path, version: version, onCreate: (Database db, int version) async {
          await db.execute(
              'CREATE TABLE $tableName ('
                  'id INTEGER PRIMARY KEY AUTOINCREMENT, '
                  'title STRING , note TEXT ,date STRING, startTime STRING ,'
                  'endTime STRING , remind INTEGER , '
                  'repeat STRING, color INTEGER, '
                  'isCompleted INTEGER)');
        });
      } catch (e) {
        print(e);
      }
    }
  }
  static Future<int> insert(Task? task)async{
    return await db!.insert(tableName, task!.toJson());
  }
  static Future<int> delete(Task task)async{
    return await db!.delete(tableName, where: 'id=?',whereArgs: [task.id]);

  }
  static Future<int> deleteAll()async{
    return await db!.delete(tableName);

  }



  static Future<List<Map<String,dynamic>>> query()async{
    return await db!.query(tableName,);
  }

  static Future<int> upDate(int id)async{
    return await db!.rawUpdate('''Update tasks SET isCompleted=? WHERE id=?''',[1,id]);
  }
}




