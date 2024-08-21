import 'package:flutter/material.dart';
import 'firestore_service.dart';

class StudentManagementScreen extends StatefulWidget {
  @override
  _StudentManagementScreenState createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  String? _selectedStudentId;

  void _addStudent() {
    final name = _nameController.text;
    final age = int.tryParse(_ageController.text) ?? 0;

    if (name.isNotEmpty && age > 0) {
      _firestoreService.addStudent(name, age);
      _nameController.clear();
      _ageController.clear();
    }
  }

  void _updateStudent() {
    final name = _nameController.text;
    final age = int.tryParse(_ageController.text) ?? 0;

    if (_selectedStudentId != null && name.isNotEmpty && age > 0) {
      _firestoreService.updateStudent(_selectedStudentId!, name, age);
      _nameController.clear();
      _ageController.clear();
      setState(() {
        _selectedStudentId = null;
      });
    }
  }

  void _deleteStudent(String id) {
    _firestoreService.deleteStudent(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Management System'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Age'),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _selectedStudentId == null ? _addStudent : _updateStudent,
                    child: Text(_selectedStudentId == null ? 'Add Student' : 'Update Student'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(labelText: 'Search by Name'),
                onChanged: (value) => setState(() {}),
              ),
              SizedBox(height: 16),
              StreamBuilder<List<Student>>(
                stream: _searchController.text.isEmpty
                    ? _firestoreService.getStudents()
                    : _firestoreService.searchStudents(_searchController.text),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No students found.'));
                  }
                  final students = snapshot.data!;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Age')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: students.map((student) {
                        return DataRow(
                          cells: [
                            DataCell(Text(student.id)),
                            DataCell(Text(student.name)),
                            DataCell(Text(student.age.toString())),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      setState(() {
                                        _selectedStudentId = student.id;
                                        _nameController.text = student.name;
                                        _ageController.text = student.age.toString();
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => _deleteStudent(student.id),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
