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
    final snapshots = await collectionReference.get();
    // Convert each document into a Todo object
    return snapshots.docs.map((doc) => Todo.fromDocument(doc)).toList();
  }

  Future<void> add({required String title}) async {
    // Create a new todo object.
    final todo = Todo(title: title);
    // Set the state to loading.
    state = const AsyncValue.loading();
    // Set the state to success after the todo is added.
    state = await AsyncValue.guard(() async {
      // Add the todo to the collection.
      await collectionReference.add(todo.toJson());
      // Fetch the data.
      return await fetchData();
    });
  }

  Future<void> toggle({required String id}) async {
    final todo = state.value!.firstWhere((todo) => todo.id == id);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Update todo.isCompleted to the opposite of the current value.
      final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
      // Update the document in Firestore.
      await collectionReference.doc(id).update(updatedTodo.toJson());
      // Fetch and return the new list of todos.
      return await fetchData();
    });
  }

  Future<void> delete({required String id}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Delete the document.
      await collectionReference.doc(id).delete();
      // Return the updated data.
      return await fetchData();
    });
  }
}
