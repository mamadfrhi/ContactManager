import 'package:contact_manager_v4/bloc/bloc.dart';
import 'package:contact_manager_v4/data/model.dart';
import 'package:contact_manager_v4/data/storage.dart';
import 'package:contact_manager_v4/screens/FavoritesPage.dart';
import 'package:contact_manager_v4/screens/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'AddDelPage.dart';

class ContactsPage extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
        appBar: new AppBar(
          title: Text("Contacts"),
        ),
        body: BlocListener<ContactsBloc, ContactsState>(
          listener: (context, state) {
            if (state is NetworkErrorState) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
              BlocProvider.of<ContactsBloc>(ctx).add(GetContacts());
            }
          },
          child: BlocBuilder<ContactsBloc, ContactsState>(
            builder: (context, state) {
              switch (state.runtimeType) {
                case InitialContactsState:
                  BlocProvider.of<ContactsBloc>(ctx).add(GetContacts());
                  return Container();
                case LoadingContactsState:
                  //Load
                  return _buildLoading(ctx);
                case LoadedContactsState:
                  //Loaded
                  final _ctcs = (state as LoadedContactsState).contacts;
                  return _buildContactList(ctx, _ctcs);
              }
              return Container();
            },
          ),
        ),
        floatingActionButton: _getFAB(ctx));
  }

  //Viewbuilder functions
  Widget _getFAB(BuildContext ctx) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 30),
      backgroundColor: Colors.blue,
      visible: true,
      curve: Curves.bounceIn,
      children: [
        // FAB 1
        SpeedDialChild(
            child: Icon(Icons.add),
            backgroundColor: Colors.blueAccent,
            onTap: () {
              _navigateToAddPage(ctx);
            },
            labelBackgroundColor: Color(0xFF801E48)),
        // FAB 2
        SpeedDialChild(
            child: Icon(Icons.favorite),
            backgroundColor: Colors.red,
            onTap: () {
              _navigateToFavorites(ctx);
            })
      ],
    );
  }

  Widget _buildLoading(BuildContext ctx) {
    return Center(
        child: new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
      ],
    ));
  }

  //listview
  Widget _buildContactList(BuildContext ctx, List<Contact> contactList) {
    return ListView.builder(
      itemCount: contactList.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == contactList.length) {
          return _loadMoreBtn(context);
        } else {
          return Slidable(
            child: _card(contactList[index]),
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            actions: _leftSlider(context, contactList, index),
            secondaryActions: _rightSlider(contactList, index, context),
          );
        }
      },
    );
  }

  List<Widget> _rightSlider(
      List<Contact> contactList, int index, BuildContext context) {
    return <Widget>[
      IconSlideAction(
        caption: contactList[index].isFavorite ? 'Delete Favorite' : 'Favorite',
        color:
            contactList[index].isFavorite ? Colors.blueGrey : Colors.redAccent,
        icon: contactList[index].isFavorite
            ? Icons.favorite_border
            : Icons.favorite,
        onTap: () => _addToFavorite(context, contactList[index].id, index,
            !(contactList[index].isFavorite)),
      ),
    ];
  }

  List<Widget> _leftSlider(
      BuildContext context, List<Contact> contactList, int index) {
    return <Widget>[
      //Edit
      IconSlideAction(
        caption: 'Edit',
        color: Colors.blue,
        icon: Icons.edit,
        onTap: () => _update(context, contactList[index]),
      ),
      //Delete
      IconSlideAction(
        caption: 'Delete',
        color: Colors.red,
        icon: Icons.delete,
        onTap: () => _delete(context, contactList[index].id),
      ),
    ];
  }

  Padding _loadMoreBtn(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 70),
      child: Container(
        color: Colors.greenAccent,
        child: FlatButton(
          child: Text(
            "Load More",
            style: MediumTextStyle,
          ),
          onPressed: () => _loadMoreContacts(context),
        ),
      ),
    );
  }

  Widget _card(Contact ctc) {
    return ListTile(
      leading: Icon(Icons.contacts),
      title: Text(ctc.firstname + ' ' + ctc.lastname),
      subtitle: Text(ctc.phoneNo),
      trailing: (ctc.isFavorite)
          ? Icon(
              Icons.favorite,
              color: Colors.red,
            )
          : null,
    );
  }

  //CRUD functions
  void _delete(BuildContext ctx, String contactID) {
    BlocProvider.of<ContactsBloc>(ctx).add(DeleteContact(contactID));
  }

  void _update(context, Contact contact) async {
    final updatedCtc = await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AddDelContactPage(PageType.EditPage, contact)));
    BlocProvider.of<ContactsBloc>(context).add(UpdateContact(updatedCtc));
  }

  void _loadMoreContacts(BuildContext ctx) {
    BlocProvider.of<ContactsBloc>(ctx).add(LoadMoreContacts());
  }

  void _addToFavorite(BuildContext ctx, String ctcID, int index, bool value) {
    BlocProvider.of<ContactsBloc>(ctx).add(AddToFavorite(ctcID, index, value));
  }

  //Navigation functions
  void _navigateToAddPage(context) async {
    final ctc = await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AddDelContactPage(PageType.AddPage, null)));
    BlocProvider.of<ContactsBloc>(context).add(AddContact(ctc));
  }

  void _navigateToFavorites(BuildContext ctx) async {
    final favoriteIds = await StorageApi.instance.getFavorites();
    //Show Error
    if (favoriteIds == null || favoriteIds.length == 0) {
      BlocProvider.of<ContactsBloc>(ctx)
          .add(ShowError("There isn't any favorite contact!"));
      return;
    }
    final contacts = await StorageApi.instance.fetchFromStorage();
    List<Contact> favoriteContacts = [];

    favoriteIds.forEach((favoriteId) {
      Contact finded = contacts.singleWhere((ctc) => ctc.id == favoriteId,
          orElse: () => null);
      if (finded != null) {
        favoriteContacts.add(finded);
      }
    });
    Navigator.of(ctx).push(
        MaterialPageRoute(builder: (_) => FavoritesPage(favoriteContacts)));
  }
}
