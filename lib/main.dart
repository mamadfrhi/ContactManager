import 'package:contact_manager_v4/bloc/bloc.dart';
import 'package:contact_manager_v4/data/repo.dart';
import 'package:contact_manager_v4/screens/ContactsPage.dart';
import 'package:contact_manager_v4/screens/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    RepoContact _repo = RepoContact();
    return MaterialApp(
        title: 'Contacts Manager',
        debugShowCheckedModeBanner: false,
        theme: _theme(),
        home: BlocProvider(
          create: (context) => ContactsBloc(_repo),
          child: ContactsPage(),
        ));
  }

  ThemeData _theme() {
    return ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(textTheme: TextTheme(title: AppBarTextStyle)),
        textTheme: TextTheme(title: TitleTextStyle, body1: Body1TextStyle));
  }
}
