import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataBase{

  final FirebaseUser user;
  UserDataBase(this.user);

  final CollectionReference _userData = Firestore.instance.collection('users');

  Future<String> newUserData(String firstName, String lastName, String type) async{
    try{
      Map<String, dynamic> data = {
        'fistName' : firstName,
        'lastName' : lastName,
        'type' : type,
        'uid' : user.uid,
      };
      await _userData.document(user.email).setData(data);
      return 'Success';
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }

  Future userType() async{
    DocumentSnapshot data;
    await _userData.document(user.email).get().then((DocumentSnapshot ds){
      data = ds;
    });
    return data.data['type'];
  }
}

class StudentsList{
  final CollectionReference _userData = Firestore.instance.collection('users');
  Future<List<String>> getAllStudents() async{
    try{
      List<String> students = [];
      QuerySnapshot qs = await _userData.getDocuments();
      qs.documents.forEach((DocumentSnapshot ds){
        if(ds.data['type'] == 'Student'){ students.add(ds.documentID); }
      });
      return students.isEmpty ? [] : students;
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }
}

class TeacherSubjectsAndBatches{

  final FirebaseUser user;
  TeacherSubjectsAndBatches(this.user);

  final CollectionReference _teachers = Firestore.instance.collection('/teachers-data');

  Future<String> addSubject(String subject) async{
    try{
      //Creating an map with subjects as keys and weather to show it or not as an boolean value
      await _teachers.document(user.email).setData({subject : true}, merge: true);
      return 'Success';
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }

  Future<String> addBatch(String subject, String batch) async{
    try{
      await _teachers.document(user.email).collection(subject).document(batch).setData({}, merge: true);
      return 'Success';
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }

  Future<String> addStudent(String subject, String batch, String studentEmail) async{
    try{
      await _teachers.document(user.email).collection(subject).document(batch).setData({studentEmail : true}, merge: true);
      CollectionReference _students = Firestore.instance.collection('/students-data');
      await _students.document(studentEmail).setData({
        DateTime.now().millisecondsSinceEpoch.toString() : {
          'teacherEmail' : user.email,
          'subject' : subject,
          'batch' : batch,
        }
      }, merge: true);
      return 'Success';
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }

  Future<String> addAttendance(String subject, String batch, String studentEmail, String dateTime, bool attendance) async{
    try{
      await _teachers.document(user.email).collection(subject).document(batch).collection('attendance').document(studentEmail).setData({dateTime : attendance}, merge: true);
      return 'Success';
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }

  Future<List<String>> getSubjects() async {
    try {
      List<String> subjects = [];
      await _teachers.document(user.email).get().then((DocumentSnapshot ds){
        if(ds.exists){
          subjects.addAll(ds.data.keys);
        }
        else{
          subjects = ['Empty'];
        }
      });
      return subjects.isEmpty? ['Empty'] : subjects;
    }
    catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<List<String>> getBatches(String subject) async{
    try{
      List<String> batches = [];
      QuerySnapshot qs = await _teachers.document(user.email).collection(subject).getDocuments();
      qs.documents.forEach((DocumentSnapshot ds) => batches.add(ds.documentID));
      return batches.isEmpty || batches == null ? ['Empty'] : batches;
    }

    catch(e){
      print(e.toString());
      return null;
    }
  }

  Future<List<String>> getStudents(String subject, String batch) async{
    try{
      List<String> students = [];
      await _teachers.document(user.email).collection(subject).document(batch).get().then((DocumentSnapshot ds){
        if(ds.exists){
          students.addAll(ds.data.keys);
        }
        else{
          students = ["Empty"];
        }
      });
      return students.isEmpty ? ['Empty'] : students;
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }
}

class StudentEnrollmentAndAttendance{
  final FirebaseUser user;
  StudentEnrollmentAndAttendance(this.user);
  
  final CollectionReference _students = Firestore.instance.collection('students-data');
  
  Future<Map> enrollmentList() async{
    try{
      Map enrollmentDetails = {};
      await _students.document(user.email).get().then((DocumentSnapshot ds){
        if(ds.exists){
          enrollmentDetails = ds.data;
        }
        else{
          enrollmentDetails = {'empty' : {'subject' : "You are not enrolled in any subject", 'batch' : '-_-', 'teacherEmail' : 'Try contacting your teachers'}};
        }
      });
      return enrollmentDetails.isEmpty ? {'empty' : {'subject' : "You are not enrolled in any subject", 'batch' : '-_-', 'teacherEmail' : 'Try contacting your teachers'}} : enrollmentDetails;
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }

  Future<Map> getAttendance(String subject, String batch, String studentEmail, String dateTime, bool attendance) async{
    try{
      Map attendanceList = {};
      CollectionReference teachers = Firestore.instance.collection('teachers-data');
      await teachers.document(user.email).collection(subject).document(batch).collection('attendance').document(studentEmail).get().then((DocumentSnapshot ds){
        if(ds.exists){
          attendanceList = ds.data;
        }
      });
      return attendanceList.isEmpty ? {'error' : 'No attendances found'} : attendanceList;
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }
}