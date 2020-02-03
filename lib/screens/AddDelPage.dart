import 'package:contact_manager_v4/data/model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:uuid/uuid.dart';

enum TextFieldType { FirstName, LastName, PhoneNo, Email }
enum PageType { EditPage, AddPage }

class AddDelContactPage extends StatefulWidget {
  final PageType pageType;
  final Contact contact;
  AddDelContactPage(this.pageType, this.contact);

  @override
  State<StatefulWidget> createState() {
    return _AddContactPageState();
  }
}

class _AddContactPageState extends State<AddDelContactPage> {
  Contact _contact;
  bool isEditPage;
  String firstName;
  String lastName;
  String dropdownValue = 'Male';
  DateTime birthDate;
  String phoneNumber;
  String email;
  BuildContext globalCtx;

  var firstNameTEC = TextEditingController();
  var lastNameTEC = TextEditingController();
  var phoneNoNameTEC = TextEditingController();
  var emailTEC = TextEditingController();
  int birthDateTimeStamp;
  String orgId;

  @override
  void initState() {
    super.initState();
    isEditPage = (widget.pageType == PageType.EditPage);
    _contact = widget.contact;
    if (this.isEditPage) {
      //If it's editing page
      int db = int.parse(_contact.dateOfBirth);
      birthDateTimeStamp = db;
      firstNameTEC.text = _contact.firstname;
      lastNameTEC.text = _contact.lastname;
      phoneNoNameTEC.text = _contact.phoneNo;
      emailTEC.text = _contact.email;
      dropdownValue = _contact.gender;
      orgId = _contact.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: new Text(this.isEditPage ? 'Edit' : 'Add new contact'),
        ),
        body: Builder(
          builder: (ctx) {
            globalCtx = ctx;
            return _buildInitState();
          },
        ));
  }

  //Main Widget
  Widget _buildInitState() {
    return new Container(
      alignment: Alignment.center,
        child: new SingleChildScrollView(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          //FirstName
          inputField("Mohammad", TextFieldType.FirstName, firstNameTEC),
          SizedBox(height: 10),
          //LastName
          inputField("Farrahi", TextFieldType.LastName, lastNameTEC),
          SizedBox(height: 10),
          //PhoneNo
          inputField("09398709058", TextFieldType.PhoneNo, phoneNoNameTEC),
          SizedBox(height: 10),
          //Email
          inputField("mamad.frhi@gmail.com", TextFieldType.Email, emailTEC),
          SizedBox(height: 10),
          //Date of Birth
          dropDownWidget(),
          SizedBox(height: 10),
          //Date Picker
          dateTimePicker(),
          SizedBox(height: 10),
          RaisedButton(
            child: Text("Save"),
            onPressed: () => saveBtnPressed(),
          )
        ],
      ),
    ));
  }

  //Widget Functions
  Widget inputField(String hint, TextFieldType tft, TextEditingController tec) {
    return new Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: TextField(
        controller: tec,
        inputFormatters: (tft == TextFieldType.PhoneNo)
            ? <TextInputFormatter>[
                LengthLimitingTextInputFormatter(12),
                WhitelistingTextInputFormatter.digitsOnly,
                BlacklistingTextInputFormatter.singleLineFormatter,
              ]
            : null,
        onChanged: (val) {
          if (tft == TextFieldType.FirstName) {
            this.firstName = val;
          } else if (tft == TextFieldType.LastName) {
            this.lastName = val;
          } else if (tft == TextFieldType.Email) {
            this.email = val;
          } else {
            //PhoneNo
            this.phoneNumber = val;
          }
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: "$hint",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget dropDownWidget() {
    return new DropdownButton<String>(
      value: dropdownValue,
      icon: Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.white),
      underline: Container(
        height: 2,
        color: Colors.white,
      ),
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: <String>['Male', 'Female']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget dateTimePicker() {
    return new RaisedButton(
      onPressed: () {
        DatePicker.showDatePicker(context,
            showTitleActions: true,
            minTime: DateTime(2000, 1, 1),
            maxTime: DateTime(2022, 12, 31), onConfirm: (date) {
          this.birthDate = date;
        }, currentTime: DateTime.now(), locale: LocaleType.en);
      },
      child: Text(
        'Enter Date Of Birth ',
      ),
    );
  }

  //Logical Functions
  void saveBtnPressed() {
    final validatedContact = validate(globalCtx);
    if (validatedContact != null) {
      Navigator.of(globalCtx).pop(validatedContact);
    }
  }

  Contact validate(BuildContext ctx) {
    final id = Uuid().v4().toString();
    if (this.isEditPage) {
      //is Edit page
      if (firstNameTEC.text == "" ||
          lastNameTEC.text == "" ||
          phoneNoNameTEC.text == "" ||
          emailTEC.text == "") {
        final snackBar = SnackBar(content: Text('Please fill all fields.'));
        Scaffold.of(ctx).showSnackBar(snackBar);
        return null;
      } else {
        int _birthDateTimeStamp;
        if (this.birthDate != null) {
          _birthDateTimeStamp = this.birthDate.millisecondsSinceEpoch;
        } else {
          _birthDateTimeStamp = this.birthDateTimeStamp;
        }
        final newCtc = Contact(
            id: orgId,
            firstname: this.firstNameTEC.text,
            lastname: this.lastNameTEC.text,
            email: this.emailTEC.text,
            gender: this.dropdownValue,
            dateOfBirth: _birthDateTimeStamp.toString(),
            phoneNo: this.phoneNoNameTEC.text);
        newCtc.isFavorite = false;
        return newCtc;
      }
    } else {
      //is Add page
      if (firstName == null ||
          lastName == null ||
          phoneNumber == null ||
          birthDate == null ||
          email == null) {
        final snackBar = SnackBar(content: Text('Plese fill all fields.'));
        Scaffold.of(ctx).showSnackBar(snackBar);
        return null;
      } else {
        int _dateOfBirhtTimeStamp = this.birthDate.millisecondsSinceEpoch;
        final newCtc = Contact(
            id: id,
            firstname: this.firstNameTEC.text,
            lastname: this.lastNameTEC.text,
            email: this.emailTEC.text,
            gender: this.dropdownValue,
            dateOfBirth: _dateOfBirhtTimeStamp.toString(),
            phoneNo: this.phoneNoNameTEC.text);
        newCtc.isFavorite = false;
        return newCtc;
      }
    }
  }
}
