import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Contact extends Equatable {
  
  set isFavorite(bool value) {
    if (value != null) {
      this._isFavorite = value;
    }
  }
  bool get isFavorite {
    return _isFavorite;
  }
  bool _isFavorite;

  final String id;
  final String firstname;
  final String lastname;
  final String email;
  final String gender;
  final String dateOfBirth;
  final String phoneNo;
  Contact(
      {@required this.id,
      @required this.firstname,
      @required this.lastname,
      @required this.email,
      @required this.gender,
      @required this.dateOfBirth,
      @required this.phoneNo,});

  @override
  List<Object> get props =>
      [id, firstname, lastname, gender, dateOfBirth, phoneNo, isFavorite];
}
