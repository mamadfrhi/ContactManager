import 'dart:convert';

import 'package:contact_manager_v4/data/storage.dart';

import 'model.dart';

class ParseJson {
  Future<List<Contact>> parseContacts(String json) async {
    final _decoded = jsonDecode(json);
    final _allContacts = _decoded['data'];
    List<Contact> _contacts = [];
    //Get Favorites
    List<String> favoriteIDs = [];
    favoriteIDs = await StorageApi.instance.getFavorites();
    //Parse Contacts
    _allContacts.forEach((contact) {
      final id = contact['id'].toString();
      final firstname = contact['first_name'];
      final lastname = contact['last_name'];
      final email = contact['email'];
      final gender = contact['gender'];
      final dateOfBirth = contact['date_of_birth'];
      final phoneNo = contact['phone_no'];
      final aContact = Contact(
        id: id,
        firstname: firstname,
        lastname: lastname,
        email: email,
        gender: gender,
        dateOfBirth: dateOfBirth,
        phoneNo: phoneNo,
      );
      aContact.isFavorite =
          (favoriteIDs != null && favoriteIDs.contains(id) ? true : false);
      if (aContact != null) {
        _contacts.add(aContact);
      }
    });
    _contacts.sort((a, b) {
      return a.firstname.toLowerCase().compareTo(b.firstname.toLowerCase());
    });
    return _contacts;
  }

  List<String> parseFavoriteIDs(String json) {
    if (json == null) {
      return null;
    }
    final _decoded = jsonDecode(json);
    final _allContacts = _decoded['data'];
    List<String> ids = [];
    _allContacts.forEach((contactID) {
      ids.add(contactID);
    });
    return ids;
  }
}
