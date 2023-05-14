import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_async_notifier/firebase_options.dart';
import 'package:todo_async_notifier/todo.dart';
import 'package:todo_async_notifier/todo_async_notilier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();
    final asyncValue = ref.watch(todoAsyncNotifierProvider);
    final notifier = ref.watch(todoAsyncNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("sample"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    maxLength: 20,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    notifier.add(title: controller.text);
                  },
                  icon: const Icon(Icons.play_arrow),
                )
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Text("TODO"),
            ),
            asyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text('Error: $error')),
              data: (data) => data.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: ((BuildContext context, int index) {
                          final todo = data[index];
                          return Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: todo.isCompleted,
                                      onChanged: (_) async =>
                                          notifier.toggle(id: todo.id!),
                                    ),
                                    Text(
                                      todo.title,
                                      style: TextStyle(
                                        color: todo.isCompleted
                                            ? Colors.grey
                                            : Colors.black,
                                        decoration: todo.isCompleted
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () async =>
                                    await notifier.delete(id: todo.id!),
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          );
                        }),
                      ),
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
