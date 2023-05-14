import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// 自動生成される2つのファイル（ファイル名にする）
part 'todo.freezed.dart';
part 'todo.g.dart';

// クラスの作成
@freezed
class Todo with _$Todo {
  // コンストラクタ（メソッドやカスタムゲッター、カスタムフィールドを追加可能にする）
  const Todo._();
  // データの内容
  factory Todo({
    String? id,
    required String title,
    @Default(false) bool isCompleted,
  }) = _Todo;

  // タスクを追加する際に、入力内容がなかった場合に入れるデータとして使います
  factory Todo.empty() => Todo(title: '');

  //
  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  // Map型に変換して型を合わせます
  factory Todo.fromDocument(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Todo.fromJson(data).copyWith(id: doc.id);
  }
}
