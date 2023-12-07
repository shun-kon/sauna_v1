// メモリスト画面用Widget
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'addlist.dart';
import 'editlist.dart';

class MemoListPage extends StatefulWidget {
  const MemoListPage({super.key});

  @override
  _MemoListPageState createState() => _MemoListPageState();
}

class _MemoListPageState extends State<MemoListPage> {
  // メモデータ
  List<String> memoList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  // アプリ起動時に保存したデータを読み込む
  void init() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      memoList = prefs.getStringList("memoList")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBarを表示し、タイトルも設定
      appBar: AppBar(
        title: const Text("サウナ手帳"),
      ),
      // データを元にListViewを作成
      body: ListView.builder(
        itemCount: memoList.length,
        itemBuilder: (context, index) {
          // インデックスに対応するメモを取得する
          return Slidable(
            // 右方向にリストアイテムをスライドした場合の設定
            startActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (context) async {
                    final prefs = await SharedPreferences.getInstance();
                    // "push"で新規画面に遷移
                    // メモ編集画面から渡される値を受け取る
                    final editText = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => MemoEditPage(memoList[index])),
                    );
                    if (editText != null) {
                      // キャンセルした場合は、newListText が null となるため注意
                      setState(() {
                        // リスト追加
                        memoList[index] = editText;
                      });
                    }
                    prefs.setStringList("memoList", memoList);
                  },
                  backgroundColor: Colors.blue,
                  icon: Icons.edit,
                ),
              ],
            ),
            child: Card(
              child: ListTile(
                title: Text(memoList[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  iconSize: 20,
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    setState(() {
                      memoList.removeAt(index);
                      prefs.setStringList("memoList", memoList);
                    });
                  },
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          // "push"で新規画面に遷移
          // メモ追加画面から渡される値を受け取る
          final newListText = 
          await Navigator.of(context).push(
            MaterialPageRoute(
               // 遷移先の画面としてメモ追加画面),
              builder: (context) => const MemoAddPage(),
            ),
          );
          /*if (newListText != null) {
            // キャンセルした場合は、newListText が null となるため注意
            setState(() {
              // リスト追加
              memoList.add(newListText);
            });
          }*/
          prefs.setStringList("memoList", memoList);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
