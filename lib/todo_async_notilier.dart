import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_async_notifier/todo.dart';

final fireStoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final collectionReferenceProvider = Provider<CollectionReference>(
    (ref) => ref.read(fireStoreProvider).collection('todoList'));

// AsyncNotifierProviderを定義。
final todoAsyncNotifierProvider =
    AsyncNotifierProvider<TodoAsyncNotifier, List<Todo>>(TodoAsyncNotifier.new);

class TodoAsyncNotifier extends AsyncNotifier<List<Todo>> {
  //refを渡さなくても読み取りが可能
  // CollectionReferenceの取得
  CollectionReference get collectionReference =>
      ref.read(collectionReferenceProvider);

  // build メソッドをオーバーライドして FutureOr を返す
  @override
  FutureOr<List<Todo>> build() async {
    // 初期データの読み込み
    return await fetchData();
  }

  // データの取得メソッド
  Future<List<Todo>> fetchData() async {
    final snapshots = await collectionReference.get();
    return snapshots.docs.map((doc) => Todo.fromDocument(doc)).toList();
  }

  // データの追加メソッド
  Future<void> add({required String title}) async {
    // Todoの作成
    final todo = Todo(title: title);
    // stateをローディング状態にする
    state = const AsyncValue.loading();
    // 例外の発生時は AsyncErrorを返す(try~catchを省くことができます)
    state = await AsyncValue.guard(() async {
      await collectionReference.add(todo.toJson());
      return await fetchData();
    });
  }

  // チェックボタンの更新メソッド
  Future<void> toggle({required String id}) async {
    final todo = state.value!.firstWhere((todo) => todo.id == id);
    // stateをローディング状態にする
    state = const AsyncValue.loading();
    // 例外の発生時は AsyncErrorを返す(try~catchを省くことができます)
    state = await AsyncValue.guard(() async {
      final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
      await collectionReference.doc(id).update(updatedTodo.toJson());
      return await fetchData();
    });
  }

  // データの削除メソッド
  Future<void> delete({required String id}) async {
    state = const AsyncValue.loading();
    // 例外の発生時は AsyncErrorを返す(try~catchを省くことができます)
    state = await AsyncValue.guard(() async {
      await collectionReference.doc(id).delete();
      return await fetchData();
    });
  }
}
