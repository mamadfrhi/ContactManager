import 'package:contact_manager_v4/data/model.dart';
import 'package:equatable/equatable.dart';

abstract class ContactsState extends Equatable {
  const ContactsState();
}

class InitialContactsState extends ContactsState {
  @override
  List<Object> get props => [];
}

class LoadingContactsState extends ContactsState {
  @override
  List<Object> get props => null;
}

//Fetched
class LoadedContactsState extends ContactsState {
  final List<Contact> contacts;
  const LoadedContactsState(this.contacts);

  @override
  List<Object> get props => [contacts];
}

//Error
class NetworkErrorState extends ContactsState {
  final String message;
  NetworkErrorState(this.message);

  @override
  List<Object> get props => [message];
}
