import 'package:contact_manager_v4/data/model.dart';
import 'package:contact_manager_v4/screens/ListviewCard.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  final List<Contact> contacts;
  FavoritesPage(this.contacts);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites"),
      ),
      body: ReorderableListView(
        onReorder: _onReorder,
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: List.generate(
          widget.contacts.length,
          (index) {
            return ListViewCard(
              widget.contacts ,
              index,
              Key('$index'),
            );
          },
        ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(
      () {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final Contact item = widget.contacts.removeAt(oldIndex);
        widget.contacts.insert(newIndex, item);
      },
    );
  }
}