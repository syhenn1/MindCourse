import 'package:flutter/material.dart';
import '/models/subject.dart';

class EntryForm extends StatefulWidget {
  final Subject subject;

  EntryForm(this.subject, {super.key});

  @override
  EntryFormState createState() => EntryFormState(subject);
}

class EntryFormState extends State<EntryForm> {
  Subject subject;
  EntryFormState(this.subject);

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ignore: unnecessary_null_comparison
        title: subject == null ? Text('Tambah Data') : Text('Ubah Data'),
        leading: Icon(Icons.keyboard_arrow_left),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            // Nama
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: nameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                onChanged: (value) {
                  // Handle change if needed
                },
              ),
            ),
            // No HP
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Nomor HP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                onChanged: (value) {
                  // Handle change if needed
                },
              ),
            ),
            // Tombol
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                children: <Widget>[
                  // Tombol simpan
                  Expanded(
                    child: ElevatedButton(
                      child: Text('Simpan', textScaleFactor: 1.5),
                      onPressed: () {
                      },
                    ),
                  ),
                  Container(width: 5.0),
                  // Tombol batal
                  Expanded(
                    child: ElevatedButton(
                      child: Text('Batal', textScaleFactor: 1.5),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
