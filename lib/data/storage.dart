import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'JsonParser.dart';
import 'model.dart';

class StorageApi {
  static StorageApi instance = StorageApi();

  final String key = 'contactList';

  Future saveInStorage(String contacts) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(key, json.encode(contacts));
  }

  Future saveFavorite(String favoriteContactID) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String> ids = await getFavorites();

    if (ids == null) {
      ids = [favoriteContactID];
    } else {
      final index = ids.indexWhere((ctcID) => (ctcID == favoriteContactID));

      if (index == null || index == -1) {
        ids.add(favoriteContactID);
      } else {
        ids.removeAt(index);
      }
    }
    Map<String, dynamic> favorites = {'data': ids};
      final encoded = json.encode(favorites);
      sp.setString("favorites", encoded);
  }

  Future<List<Contact>> fetchFromStorage() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    // sp.remove('favorites');
    final contacts = sp.getString(key);
    if (contacts == null) {
      return null;
    } else {
      final contactsJson = json.decode(contacts);
      final contactsList = ParseJson().parseContacts(contactsJson);
      return contactsList;
    }
  }

  Future<List<String>> getFavorites() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final faves = sp.getString("favorites");
    final ids = ParseJson().parseFavoriteIDs(faves);
    return ids;
  }
}
