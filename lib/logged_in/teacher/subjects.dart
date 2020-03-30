import 'package:attendanceapp/classes/firestore.dart';
import 'package:attendanceapp/shared/formatting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Subjects extends StatefulWidget {
  @override
  _SubjectsState createState() => _SubjectsState();
}

class _SubjectsState extends State<Subjects> {
  List<String> subjects = [];
  bool add = false;
  final _formKey = GlobalKey<FormState>();
  String subject = ' ';
  String error = ' ';
  TeacherSubjectsAndBatches _tSAB;
  FirebaseUser user;

  Future setup(FirebaseUser userCurrent) async{
    user = userCurrent;
    _tSAB = TeacherSubjectsAndBatches(user);
    subjects = await _tSAB.getSubjects();
    if(subjects == null){
      subjects = ["Couldn't get subjects, try logging in again"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: setup(Provider.of<FirebaseUser>(context)),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return subjects.isEmpty ? LoadingData() : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Card(
                child: add == false ? addSubjectButton() : addSubjectForm(),
              ),
              SizedBox(height: 10,),
              subjects[0] == 'Empty' ? Text('You Need To Add Subjects', style: TextStyle(color: Colors.red),) : Expanded(
                child: ListView.builder(
                  itemCount: subjects.length,
                  itemBuilder: (context, index){
                    return Card(
                      child: ListTile(
                        onTap: () async{
                          Navigator.of(context).pushNamed('/batches', arguments: subjects[index]);
                        },
                        title: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text('${subjects[index]}'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget addSubjectButton()
  {
    return ListTile(
      onTap: (){
        setState(() {
          add = true;
        });
      },
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[Icon(Icons.add),SizedBox(width: 10,) ,Text('Add A Subject')],
      ),
    );
  }

  Widget addSubjectForm()
  {
    return Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 2),
              child: TextFormField(
                decoration: textInputFormatting.copyWith(hintText: 'Add Subject Name'),
                validator: (val) => val.isEmpty ? 'Subject Name Can\'t Be Empty' : null,
                onChanged: (val) => subject = val,
              ),
            ),
            IconButton(
              onPressed: () async{
                if(_formKey.currentState.validate())
                {
                  if(subjects.contains(subject))
                  {
                    setState(() {
                      error = "Subject Already Present";
                    });
                  }
                  else
                  {
                    dynamic result = await _tSAB.addSubject(subject);
                    if(result ==  null)
                    {
                      setState(() {
                        error = "Something Went Wrong, Couldn't Add Subject";
                      });
                    }
                    else
                    {
                      await setup(user);
                      setState((){
                        error = ' ';
                        add = false;
                      });
                    }
                  }
                }
              },
              icon: Icon(Icons.add_box),
            ),
            Text('$error', style: TextStyle(color: Colors.red),)
          ],
        )
    );
  }
}






