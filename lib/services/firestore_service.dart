import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pertemuan6/models/todo.dart';

class FirestoreService {
  final CollectionReference _todosCollection = FirebaseFirestore.instance
      .collection('todos');

  //Create todo

  Future<void> addTodo(String taskName) async {
    final newTodo = Todo(id: '', task: taskName, isDone: false);

    await _todosCollection.add(newTodo.toMap());
  }

  // read todo

  Stream<List<Todo>> getTodos() {
    return _todosCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
          snapshot.docs.map((doc) => Todo.fromFirestore(doc)).toList(),
    );
  }

  // update todo

  Future<void> updateTodoStatus(String id, bool currentStatus) async {
    await _todosCollection.doc(id).update({'isDone': !currentStatus});
  }

  // delete todo

  Future<void> deleteTodo(String id) async {
    await _todosCollection.doc(id).delete();
  }
}