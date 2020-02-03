import 'package:contact_manager_v4/data/model.dart';

class RepoContact {
  List<Contact> contactRepo = [];

  void removeById(String id) {
    this.contactRepo.removeWhere((ctc) {
      return ctc.id == id;
    });
  }

  void add(Contact ctc) {
    this.contactRepo.add(ctc);
  }

  void addAtFirst(Contact ctc) {
    this.contactRepo.insert(0, ctc);
  }

  void setFavorite(int contactIndex, bool isFavoriteValue) {
    this.contactRepo[contactIndex].isFavorite = isFavoriteValue;
  }
}
