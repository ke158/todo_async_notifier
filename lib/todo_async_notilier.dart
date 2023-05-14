import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_async_notifier/todo.dart';

final fireStoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final collectionReferenceProvider = Provider<CollectionReference>(
    (ref) => ref.read(fireStoreProvider).collection('todoList'));

final todoAsyncNotifierProvider =
    AsyncNotifierProvider<TodoAsyncNotifier, List<Todo>>(TodoAsyncNotifier.new);

class TodoAsyncNotifier extends AsyncNotifier<List<Todo>> {
  CollectionReference get collectionReference =>
      ref.read(collectionReferenceProvider);

  @override
  FutureOr<List<Todo>> build() async {
    return await fetchData();
  }

  Future<List<Todo>> fetchData() async {
    final snaps = await collectionReference.get();
    return snaps.docs.map((doc) => Todo.fromDocument(doc)).toList();
  }

  Future<void> add({required String title}) async {
    final todo = Todo(title: title);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await collectionReference.doc().set(todo.toJson());
      return await fetchData();
    });
  }

  Future<void> toggle({required String id}) async {
    final todo = state.value!.firstWhere((todo) => todo.id == id);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await collectionReference
          .doc(id)
          .update(todo.copyWith(isCompleted: !todo.isCompleted).toJson());
      return await fetchData();
    });
  }

  Future<void> delete({required String id}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await collectionReference.doc(id).delete();
      return await fetchData();
    });
  }
}
