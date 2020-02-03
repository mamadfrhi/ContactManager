import 'package:contact_manager_v4/data/model.dart';
import 'package:equatable/equatable.dart';

abstract class ContactsEvent extends Equatable {
  const ContactsEvent();
}

class GetContacts extends ContactsEvent {
  @override
  List<Object> get props => null;
}

class DeleteContact extends ContactsEvent {
  final String id;
  const DeleteContact(this.id);
  @override
  List<Object> get props => [id];
}

class AddContact extends ContactsEvent {
  final Contact ctc;
  const AddContact(this.ctc);
  @override
  List<Object> get props => [ctc];
}

class UpdateContact extends ContactsEvent {
  final Contact ctc;
  const UpdateContact(this.ctc);

  @override
  List<Object> get props => [ctc];
}

class LoadMoreContacts extends ContactsEvent {
  @override
  List<Object> get props => null;
}

class AddToFavorite extends ContactsEvent {
  final String contactID;
  final int contactIndex;
  final bool value;
  AddToFavorite(this.contactID, this.contactIndex, this.value);

  @override
  List<Object> get props => [contactID];
}

class ShowError extends ContactsEvent {
  final String msg;
  ShowError(this.msg);
  @override
  List<Object> get props => [msg];

}
