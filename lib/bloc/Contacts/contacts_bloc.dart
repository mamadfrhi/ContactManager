import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:contact_manager_v4/bloc/Contacts/contacts_event.dart';
import 'package:contact_manager_v4/bloc/Contacts/contacts_state.dart';
import 'package:contact_manager_v4/data/JsonParser.dart';
import 'package:contact_manager_v4/data/api.dart';
import 'package:contact_manager_v4/data/repo.dart';
import 'package:contact_manager_v4/data/storage.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final RepoContact _repo;
  ContactsBloc(this._repo);
  int present = 10;

  @override
  ContactsState get initialState => InitialContactsState();

  @override
  Stream<ContactsState> mapEventToState(
    ContactsEvent event,
  ) async* {
    yield LoadingContactsState();
    switch (event.runtimeType) {
      //Get
      case GetContacts:
        try {
          final reponse = await API.instance.fetchContacts();
          final contacts = await ParseJson().parseContacts(reponse);
          _repo.contactRepo = contacts;
          StorageApi.instance.saveInStorage(reponse);
          final range = contacts.getRange(0, present).toList();
          yield LoadedContactsState(range);
        } on NetworkError {
          yield NetworkErrorState("Are you connected to the Internet?");
        }
        break;
      //Load More
      case LoadMoreContacts:
        present = present + 5;
        if (present >= _repo.contactRepo.length) {
          yield LoadedContactsState(_repo.contactRepo);
        } else {
          final range = _repo.contactRepo.getRange(0, present).toList();
          yield LoadedContactsState(range);
        }
        break;
      //Delete
      case DeleteContact:
        try {
          final _event = (event as DeleteContact);
          final _id = _event.id;
          final response = await API.instance.deleteContact(_id);
          if (response == true) {
            yield InitialContactsState();
          } else {
            yield NetworkErrorState("Deleting contact failed.");
          }
        } on NetworkError {
          yield NetworkErrorState("Deleting contact failed.");
        }
        break;
      //Add
      case AddContact:
        try {
          final _event = (event as AddContact);
          final response = await API.instance.addContact(_event.ctc);
          if (response == true) {
            yield InitialContactsState();
          } else {
            yield NetworkErrorState("Adding contact failed.");
          }
        } on NetworkError {
          yield NetworkErrorState("Adding contact failed.");
        }
        break;

      //Update
      case UpdateContact:
        try {
          final _event = (event as UpdateContact);
          final response = await API.instance.updateContact(_event.ctc);
          if (response == true) {
            yield InitialContactsState();
          } else {
            yield NetworkErrorState("Updating contact failed.");
          }
        } on NetworkError {
          yield NetworkErrorState("Updating contact failed.");
        }
        break;
      //Add Favorite
      case AddToFavorite:
        final _event = (event as AddToFavorite);
        await StorageApi.instance.saveFavorite(_event.contactID);
        _repo.setFavorite(_event.contactIndex, _event.value);
        final contacts = _repo.contactRepo.getRange(0, present).toList();
        yield LoadedContactsState(contacts);
        break;
      //Error
      case ShowError:
        final _errMsg = (event as ShowError).msg;
        yield NetworkErrorState(_errMsg);
        break;
    }
  }
}