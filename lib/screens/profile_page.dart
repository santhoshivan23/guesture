
import 'package:flutter/material.dart';
import 'package:guesture/models/g_user.dart';
import 'package:guesture/providers/auth.dart';
import 'package:guesture/widgets/guesture_avatar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    final gUser = Provider.of<GUser>(context);
    GlobalKey<ScaffoldState> homekey =
        ModalRoute.of(context).settings.arguments;
    final nameController = TextEditingController(text: gUser.displayName);
    final _formkey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.deepPurple.withOpacity(0.5)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: GuestureAvatar(
                  gUser.photoUrl, gUser.displayName, gUser.email, 50),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: ListTile(
                title: Text(
                  gUser.displayName == null ? 'NA' : gUser.displayName,
                  textAlign: TextAlign.center,
                ),
                subtitle: Text(
                  gUser.email,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: Text(
                    'Update Display Name',
                    style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Form(
                      key: _formkey,
                      child: TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(),
                        validator: (name) {
                          if (name.isEmpty) return "Name cannot be empty!";
                          if (name.length < 5) return "name is too short!";
                          if (name == gUser.displayName)
                            return "Enter a different name!";
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            RaisedButton.icon(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: Colors.orange,
              icon: Icon(
                MdiIcons.update,
                color: Colors.white,
              ),
              label: Text(
                'Update',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                if (_formkey.currentState.validate()) {
                  Navigator.of(context).pop();
                  homekey.currentState.showSnackBar(
                    SnackBar(
                      content: Padding(
                        padding: const EdgeInsets.only(bottom: 50.0),
                        child: Text(
                          'Display name has been changed. Log out and sign in again to reflect the changes.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                  await Auth().updateDisplayName(nameController.text);
                }
                return;
              },
            ),
          ],
        ),
      ),
    );
  }
}
