import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'package:intl/intl.dart';

class TodosScreen extends StatefulWidget {
  final String token;
  const TodosScreen({super.key, required this.token});

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  List todos = [];
  final titleController = TextEditingController();
  final searchController = TextEditingController();
  bool loading = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchTodos();
    searchController.addListener(() {
      setState(() => searchQuery = searchController.text);
    });
  }

  fetchTodos() async {
    setState(() => loading = true);
    final list = await ApiService.getTodos(widget.token);
    setState(() {
      todos = list;
      loading = false;
    });
  }

  addTodo() async {
    if (titleController.text.isEmpty) return;
    final success = await ApiService.addTodo(widget.token, titleController.text);
    if (success) {
      titleController.clear();
      fetchTodos();
    }
  }

  deleteTodo(String id) async {
    final success = await ApiService.deleteTodo(widget.token, id);
    if (success) {
      setState(() => todos.removeWhere((todo) => todo['_id'] == id));
    }
  }

  toggleTodo(int index) async {
    final todo = todos[index];
    final completed = todo['completed'] ?? false;

    final success = await ApiService.toggleTodo(widget.token, todo['_id'], !completed);
    if (!success) {
      setState(() {
        todos[index]['completed'] = completed;
      });
    }
  }

  editTodoDialog(Map todo) {
    final editController = TextEditingController(text: todo['title']);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit Task',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: editController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final newTitle = editController.text.trim();
                if (newTitle.isEmpty) return;
                Navigator.pop(context);
                final success = await ApiService.updateTodo(widget.token, todo['_id'], newTitle);
                if (success) fetchTodos();
              },
              child: const Text('Update Task', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  showDetails(Map todo) {
    final createdAt = todo['createdAt'] != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(todo['createdAt']).toLocal())
        : 'Unknown';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Task Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${todo['title']}'),
            const SizedBox(height: 8),
            Text('Created At: $createdAt'),
            const SizedBox(height: 8),
            Text('Completed: ${todo['completed'] ?? false ? "Yes" : "No"}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  logout() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final filteredTodos = todos.where((todo) => todo['title'].toString().toLowerCase().contains(searchQuery.toLowerCase())).toList();

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Center(child: const Text('My Tasks', style: TextStyle(fontWeight: FontWeight.bold))),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'logout') logout();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'logout', child: Text('Log Out')),
              ],
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Tasks...',
                      prefixIcon: const Icon(Icons.search),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : filteredTodos.isEmpty
                      ? const Center(
                    child: Text(
                      'No Tasks Yet \nAdd Your First Task Please!!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTodos.length,
                    itemBuilder: (context, index) {
                      final todo = filteredTodos[index];
                      final completed = todo['completed'] ?? false;
                      final createdAt = todo['createdAt'] != null
                          ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(todo['createdAt']).toLocal())
                          : 'Unknown';

                      return AnimatedContainer(
                        key: ValueKey(todo['_id']),
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black26.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            activeColor: Colors.blue,
                            value: completed,
                            onChanged: (val) {
                              setState(() => todo['completed'] = val);
                              toggleTodo(index);
                            },
                          ),
                          title: Text(
                            todo['title'] ?? 'Untitled Task',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              decoration: completed ? TextDecoration.lineThrough : TextDecoration.none,
                              color: completed ? Colors.grey : Colors.black87,
                            ),
                          ),
                          subtitle: Text('Added: $createdAt', style: const TextStyle(fontSize: 12)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  if (value == 'edit') editTodoDialog(todo);
                                  if (value == 'details') showDetails(todo);
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                  const PopupMenuItem(value: 'details', child: Text('Details')),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => deleteTodo(todo['_id'] ?? ''),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            icon: const Icon(Icons.add_task_rounded),
            label: const Text('Add New Task'),
            onPressed: () {
              titleController.clear();
              showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (_) => Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          const Text('Add New Task', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Task Title',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            addTodo();
                          },
                        child: const Text(
                          'Add Task',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                          ],
                      ),
                  ),
              );
            },
        ),
    );
  }
}