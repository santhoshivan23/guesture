// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:guesture/models/g_user.dart';
// import 'package:guesture/providers/auth.dart';
// import 'package:guesture/providers/guesture_db.dart';
// import 'package:provider/provider.dart';

// class ManageStandard extends StatefulWidget {
//   static const routeName = '/manage-standard';
  
//   @override
//   _ManageStandardState createState() => _ManageStandardState();
// }

// class _ManageStandardState extends State<ManageStandard> {
//   final _stdUserController = TextEditingController();
//   final _pwdController = TextEditingController();
//   final _form = GlobalKey<FormState>();

//   Future<void> _addStandard(String uid) async {
//     if (!_form.currentState.validate()) return;
//     final response = await Auth()
//         .signUpStandardUser(_stdUserController.text, _pwdController.text, uid);
//     if (response == -1) {
//       showDialog(
//           context: context,
//           builder: (c) => AlertDialog(
//                 title: Text('Limit Exhausted!'),
//                 content: Text(
//                     'You have reached the maximum limit of adding 2 standard users.'),
//               ));
//     } else if (response == 0) {
//       showDialog(
//           context: context,
//           builder: (c) => AlertDialog(
//                 title: Text('Unable to add user'),
//                 content: Text('The Email ID is already in use'),
//               ));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
  
//     final gUser = ModalRoute.of(context).settings.arguments as GUser;
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Manage Standard Users'),
//         centerTitle: true,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(colors: [Colors.deepPurple, Colors.deepPurple.withOpacity(0.5)]),
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//               child: Column(
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Container(
//                 padding: EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.green.withOpacity(1),
//                       Colors.green.withOpacity(0.7),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//                 child: Text(
//                   'Standard users have restricted access to viewing and managing events. They can a reserve and check-in guests but can neither view the Finance screen nor remove a guest. You can add atmost 2 standard users. Standard users cannot be removed after creation.',
//                   textAlign: TextAlign.center,
//                   style:
//                       TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Form(
//                 key: _form,
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(5.0),
//                       child: TextFormField(
//                         keyboardType: TextInputType.emailAddress,
//                         decoration: InputDecoration(
//                           hintText: 'Enter email',
//                         ),
//                         controller: _stdUserController,
//                         validator: (email) {
//                           if (!email.contains('.com') || !email.contains('@'))
//                             return 'Enter a valid email';
//                           return null;
//                         },
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(5.0),
//                       child: TextFormField(
//                         keyboardType: TextInputType.visiblePassword,
//                         decoration: InputDecoration(
//                           hintText: 'Enter password',
//                         ),
//                         controller: _pwdController,
//                         validator: (pwd) {
//                           if (pwd.length < 5)
//                             return "Password is too short. It should be atleast 5 characters long";
//                           return null;
//                         },
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: RaisedButton(
//                         color: Colors.indigoAccent,
//                         onPressed: () => _addStandard(gUser.uid),
//                         child: Text(
//                           'Add Standard User',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     ),
//                     StandardUsersList(gUser: gUser,),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class StandardUsersList extends StatelessWidget {
//   final GUser gUser;
//   StandardUsersList({this.gUser});
//   @override
//   Widget build(BuildContext context) {
//     final String uid = gUser.uid;
//     return StreamBuilder(
//       stream: Firestore.instance
//           .collection('users')
//           .where('parent_uid', isEqualTo: uid)
//           .snapshots(),
//       builder: (ctx, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting)
//           return CircularProgressIndicator();
//         return ListView.builder(
//           shrinkWrap: true,
//           itemCount: snapshot.data.documents.length,
//           itemBuilder: (c, i) => UserTile(snapshot.data.documents[i]['email']),
//         );
//       },
//     );
//   }
// }

// class UserTile extends StatelessWidget {
//   final String email;

//   UserTile(this.email);
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: CircleAvatar(child: Text(email[0])),
//       title: Text(email),
//       dense: true,
//     );
//   }
// }
