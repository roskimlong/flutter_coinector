import 'package:flutter/services.dart' show rootBundle;
import 'dart:async' show Future;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'ListModel.dart';
import 'CardItem.dart';
import 'Merchant.dart';
import 'SearchDemoSearchDelegate.dart';
import 'Tags.dart';
import 'dart:convert';

class AnimatedListSample extends StatefulWidget {
  @override
  _AnimatedListSampleState createState() => _AnimatedListSampleState();
}

class _Page {
  const _Page({this.text, this.icon, this.title});
  final String text;
  final String title;
  final IconData icon;
}

//TODO add takeaway
const List<_Page> _pagesTags = <_Page>[
  _Page(text: 'EAT', icon: Icons.restaurant, title: 'RESTAURANT & TAKE-AWAY'),
  _Page(text: 'BAR', icon: Icons.local_bar, title: 'BAR, CLUB & CAFE'),
  _Page(text: 'MARKET', icon: Icons.shopping_cart, title: 'SUPERMARKET'),
  _Page(text: 'SHOP', icon: Icons.shopping_basket, title: 'SOUVENIR & SERVICE'),
  _Page(text: 'HOTEL', icon: Icons.hotel, title: 'HOTEL, B&B, FLAT'),
  _Page(text: 'ATM', icon: Icons.atm, title: 'TELLER & TRADER'),
  _Page(text: 'SPA', icon: Icons.spa, title: 'WELLNESS & BEAUTY'),
  /*
  _Page(text: 'JUICE'),
  _Page(text: 'SALAD'),
  _Page(text: 'MARKET'),
  _Page(text: 'SWEET'),
  _Page(text: 'SPICEY'),
  _Page(text: 'SALTY'),
  _Page(text: 'COCKTAILS'),
  _Page(text: 'BEER'),
  _Page(text: 'MUSIC'),*/
];

List<_Page> _filteredPages = _pagesTags;

class _AnimatedListSampleState extends State<AnimatedListSample>
    with SingleTickerProviderStateMixin {
  final SearchDemoSearchDelegate _delegate = SearchDemoSearchDelegate();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<AnimatedListState> _listKeyRestaurant =
      GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _listKeyBar =
      GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _listKeyHotel =
      GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _listKeyATM =
      GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _listKeyShop =
      GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _listKeyMarket =
      GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _listKeyWellness =
      GlobalKey<AnimatedListState>();
  TabController _controller;
  bool _customIndicator = false;
  ListModel<Merchant> _listRestaurant;
  ListModel<Merchant> _listBar;
  ListModel<Merchant> _listMarket;
  ListModel<Merchant> _listShop;
  ListModel<Merchant> _listHotel;
  ListModel<Merchant> _listATM;
  ListModel<Merchant> _listWellness;
  int _selectedItem;
  int _nextItem; // The next item inserted when the user presses the '+' button.
  final dio = new Dio(); // for http requests
  List<Merchant> names = new List<Merchant>(); // names we get from API
  ListModel<Merchant> tempListRestaurant;
  ListModel<Merchant> tempListBar;
  ListModel<Merchant> tempListMarket;
  ListModel<Merchant> tempListShop;
  ListModel<Merchant> tempListHotel;
  ListModel<Merchant> tempListATM;
  ListModel<Merchant> tempListWellness;
  ListModel<Merchant> unfilteredListRestaurant;
  ListModel<Merchant> unfilteredListBar;
  ListModel<Merchant> unfilteredListMarket;
  ListModel<Merchant> unfilteredListShop;
  ListModel<Merchant> unfilteredListHotel;
  ListModel<Merchant> unfilteredListATM;
  ListModel<Merchant> unfilteredListWellness;
  Response response;
  String _title = "Coinector";
  bool isUnfilteredList = false;

  String _searchTerm;

  List<dynamic> placesList;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _getNames(int filterWordIndex, String locationFilter) async {
    if (filterWordIndex == -1) {
      if (isUnfilteredList) return;
      updateListModel(
          unfilteredListRestaurant,
          unfilteredListBar,
          unfilteredListHotel,
          unfilteredListATM,
          unfilteredListMarket,
          unfilteredListShop,
          unfilteredListWellness);
      this.isUnfilteredList = true;
    } else {
      this.isUnfilteredList = false;
    }
/*
    if (response == null)
      response =
          await dio.get('https://realbitcoinclub.firebaseapp.com/places8.json');
  */
    if (placesList == null) {
      String places = await loadAsset();
      placesList = json.decode(places);
    }
    initTempListModel();
    _filteredPages = _pagesTags;

    //RESPONSE.DATA.LENGTH
    for (int i = 0; i < placesList.length; i++) {
      //Merchant m2 = Merchant.fromJson(response.data[i]);
      Merchant m2 = Merchant.fromJson(placesList.elementAt(i));

      _insertIntoTempList(m2, filterWordIndex, locationFilter);
    }

    initUnfilteredLists();

    updateListModel(tempListRestaurant, tempListBar, tempListHotel, tempListATM,
        tempListMarket, tempListShop, tempListWellness);
  }

  void updateListModel(restaurant, bar, hotel, atm, market, shop, wellness) {
    setState(() {
      _listRestaurant = restaurant;
      _listBar = bar;
      _listHotel = hotel;
      _listATM = atm;
      _listMarket = market;
      _listShop = shop;
      _listWellness = wellness;
    });
  }

  void initUnfilteredLists() {
    if (unfilteredListRestaurant == null) {
      unfilteredListRestaurant = tempListRestaurant;
      unfilteredListBar = tempListBar;
      unfilteredListHotel = tempListHotel;
      unfilteredListATM = tempListATM;
      unfilteredListMarket = tempListMarket;
      unfilteredListShop = tempListShop;
      unfilteredListWellness = tempListWellness;
    }
  }

  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/places.json');
  }

  bool _containsFilteredTag(Merchant m, int filterWordIndex) {
    var splittedTags = m.tags.split(',');
    for (int i = 0; i < splittedTags.length; i++) {
      var currentTag = int.parse(splittedTags[i]);
      if (currentTag == filterWordIndex) {
        return true;
      }
    }
    return false;
  }

  bool _containsLocation(Merchant m, String location) {
    if (location == null || location.isEmpty) return false;

    return m.location.toLowerCase().contains(location.toLowerCase());
  }

  void _insertIntoTempList(Merchant m2, int filterWordIndex, String location) {
    if (filterWordIndex != null &&
        filterWordIndex != -1 &&
        !_containsFilteredTag(m2, filterWordIndex) &&
        !_containsLocation(m2, location)) return;

    switch (m2.type) {
      case 0:
        tempListRestaurant.insert(0, m2);
        break;
      case 1:
        tempListRestaurant.insert(0, m2);
        break;
      case 2:
        tempListBar.insert(0, m2);
        break;
      case 3:
        tempListMarket.insert(0, m2);
        break;
      case 4:
        tempListShop.insert(0, m2);
        break;
      case 5:
        tempListHotel.insert(0, m2);
        break;
      case 99:
        tempListATM.insert(0, m2);
        break;
      case 999:
        tempListWellness.insert(0, m2);
        break;
    }
  }

  void initTempListModel() {
    tempListRestaurant = ListModel<Merchant>(
      listKey: _listKeyRestaurant,
      removedItemBuilder: _buildRemovedItem,
    );
    tempListBar = ListModel<Merchant>(
      listKey: _listKeyBar,
      removedItemBuilder: _buildRemovedItem,
    );
    tempListHotel = ListModel<Merchant>(
      listKey: _listKeyHotel,
      removedItemBuilder: _buildRemovedItem,
    );
    tempListATM = ListModel<Merchant>(
      listKey: _listKeyATM,
      removedItemBuilder: _buildRemovedItem,
    );
    tempListMarket = ListModel<Merchant>(
      listKey: _listKeyMarket,
      removedItemBuilder: _buildRemovedItem,
    );
    tempListShop = ListModel<Merchant>(
      listKey: _listKeyShop,
      removedItemBuilder: _buildRemovedItem,
    );
    tempListWellness = ListModel<Merchant>(
      listKey: _listKeyWellness,
      removedItemBuilder: _buildRemovedItem,
    );
  }

  Decoration getIndicator() {
    if (!_customIndicator) return const UnderlineTabIndicator();

    return ShapeDecoration(
      shape: const StadiumBorder(
            side: BorderSide(
              color: Colors.white24,
              width: 2.0,
            ),
          ) +
          const StadiumBorder(
            side: BorderSide(
              color: Colors.transparent,
              width: 4.0,
            ),
          ),
    );
  }
/*
  _handleEmptySearchBar() {
    _searchTerm = _typeAheadController.text;
    if (_typeAheadController.text.length <= 2 && !isUnfilteredList) {
      _getNames(-1);
    } else {}
  }*/

  _handleTabSelection() {
    setState(() {
      _title = _filteredPages[_controller.index].title;
    });
  }

  //TextEditingController _typeAheadController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    //_typeAheadController.addListener(_handleEmptySearchBar);
    _delegate.buildHistory();
    _controller = TabController(vsync: this, length: _filteredPages.length);
    _controller.addListener(_handleTabSelection);
    initListModel();
    _nextItem = 3;
    _getNames(-1, null);
  }

  void initListModel() {
    _listRestaurant = ListModel<Merchant>(
      listKey: _listKeyRestaurant,
      removedItemBuilder: _buildRemovedItem,
    );
    _listBar = ListModel<Merchant>(
      listKey: _listKeyBar,
      removedItemBuilder: _buildRemovedItem,
    );
    _listHotel = ListModel<Merchant>(
      listKey: _listKeyHotel,
      removedItemBuilder: _buildRemovedItem,
    );
    _listATM = ListModel<Merchant>(
      listKey: _listKeyATM,
      removedItemBuilder: _buildRemovedItem,
    );
    _listMarket = ListModel<Merchant>(
      listKey: _listKeyMarket,
      removedItemBuilder: _buildRemovedItem,
    );
    _listShop = ListModel<Merchant>(
      listKey: _listKeyShop,
      removedItemBuilder: _buildRemovedItem,
    );
    _listWellness = ListModel<Merchant>(
      listKey: _listKeyWellness,
      removedItemBuilder: _buildRemovedItem,
    );
  }

  // Used to build list items that haven't been removed.
  Widget _buildItemRestaurant(
      BuildContext context, int index, Animation<double> animation) {
    return _buildItem(index, animation, _listRestaurant);
  }

  CardItem _buildItem(
      int index, Animation<double> animation, ListModel<Merchant> listModel) {
    try {
      if (listModel != null &&
          listModel[index] != null &&
          listModel.length > 0) {
        return CardItem(
          animation: animation,
          item: listModel[index],
        );
      }
    } catch (e) {
      //not catching RangeErrors caused issues with filterbar
      return null;
    }
    return null;
  }

  Widget _buildItemBar(
      BuildContext context, int index, Animation<double> animation) {
    return _buildItem(index, animation, _listBar);
  }

  Widget _buildItemHotel(
      BuildContext context, int index, Animation<double> animation) {
    return _buildItem(index, animation, _listHotel);
  }

  Widget _buildItemATM(
      BuildContext context, int index, Animation<double> animation) {
    return _buildItem(index, animation, _listATM);
  }

  Widget _buildItemWellness(
      BuildContext context, int index, Animation<double> animation) {
    return _buildItem(index, animation, _listWellness);
  }

  Widget _buildItemMarket(
      BuildContext context, int index, Animation<double> animation) {
    return _buildItem(index, animation, _listMarket);
  }

  Widget _buildItemShop(
      BuildContext context, int index, Animation<double> animation) {
    return _buildItem(index, animation, _listShop);
  }

  // Used to build an item after it has been removed from the list. This method is
  // needed because a removed item remains  visible until its animation has
  // completed (even though it's gone as far this ListModel is concerned).
  // The widget will be used by the [AnimatedListState.removeItem] method's
  // [AnimatedListRemovedItemBuilder] parameter.
  Widget _buildRemovedItem(
      Merchant item, BuildContext context, Animation<double> animation) {
    return CardItem(
      animation: animation,
      item: item,
      selected: false,
      // No gesture detector here: we don't want removed items to be interactive.
    );
  }

  // Insert the "next item" into the list model.
  void _insert() {
    //final int index =
    //_selectedItem == null ? _list.length : _list.indexOf(_selectedItem);
    //_list.insert(index, _nextItem++);
  }

  // Remove the selected item from the list model.
  void _remove() {
    if (_selectedItem != null) {
      //_list.removeAt(_list.indexOf(_selectedItem));
      setState(() {
        _selectedItem = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // Define the default Brightness and Colors
        brightness: Brightness.dark,
        primaryColor: Colors.blueGrey[900],
        accentColor: Colors.white,

        // Define the default Font Family
        fontFamily: 'Montserrat',

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          title: TextStyle(
              fontSize: 24.0,
              fontStyle: FontStyle.normal,
              color: Colors.grey[900]),
          body1: TextStyle(
              fontSize: 18.0, fontFamily: 'Hind', color: Colors.white),
          body2: TextStyle(
              fontSize: 14.0, fontFamily: 'Hind', color: Colors.white70),
        ),
      ),
      home: Scaffold(
          drawer: Drawer(
            child: Column(
              children: <Widget>[
                const UserAccountsDrawerHeader(
                  accountName: Text('Peter Widget'),
                  accountEmail: Text('peter.widget@example.com'),
                  /*currentAccountPicture: CircleAvatar(
                    backgroundImage: AssetImage(
                      'people/square/peter.png',
                      package: 'flutter_gallery_assets',
                    ),
                  ),*/
                  margin: EdgeInsets.zero,
                ),
                /*MediaQuery.removePadding(
                  context: context,
                  // DrawerHeader consumes top MediaQuery padding.
                  removeTop: true,
                  child: const ListTile(
                    leading: Icon(Icons.payment),
                    title: Text('Placeholder'),
                  ),
                ),*/
              ],
            ),
          ),
          key: _scaffoldKey,
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  elevation: 1.5,
                  forceElevated: true,
                  leading: IconButton(
                    tooltip: 'Navigation',
                    icon: AnimatedIcon(
                      icon: AnimatedIcons.menu_arrow,
                      color: Colors.white,
                      progress: _delegate.transitionAnimation,
                    ),
                    onPressed: () {
                      _scaffoldKey.currentState.openDrawer();
                    },
                  ),
                  //title: Text(_title),
                  bottom: TabBar(
                    controller: _controller,
                    isScrollable: true,
                    indicator: getIndicator(),
                    tabs: _filteredPages.map<Tab>((_Page page) {
                      return Tab(icon: Icon(page.icon), text: page.text);
                    }).toList(),
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        final String selected = await showSearch<String>(
                          context: context,
                          delegate: _delegate,
                        );

                        if (_searchTerm != null && _searchTerm.isNotEmpty) {
                          _getNames(-1, null);
                          _searchTerm = null;
                        }

                        if (selected !=
                            null /*&& selected != _lastIntegerSelected*/) {
                          var index = _getTagIndex(selected);
                          _getNames(index, selected);

                          setState(() {
                            _searchTerm = selected;
                          });
                        }
                      },
                      tooltip: 'search',
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: _remove,
                      tooltip: 'settings',
                    ),
                  ],
                  title: Text(_searchTerm != null
                      ? _searchTerm
                      : _pagesTags[_controller.index].title),
                  //expandedHeight: 300.0, GOOD SPACE FOR ADS LATER
                  floating: true,
                  snap: true,
                  pinned: false,
                  /*flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text("KATEGORIE"/* TODO titlerein _pagesTags[_controller.index].title*/,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        )),
                    background: Image.network(
                        "https://realbitcoinclub.firebaseapp.com/img/app/trbc.gif",
                        fit: BoxFit.cover,
                      ) //TODO restaurants image w/ text
                  ),*/
                ),
              ];
            },
            body: TabBarView(controller: _controller, children: [
              //_pagesTags.map<Widget>((_Page page) {
              // if (page.text == "RESTAURANT") {
              buildTabContainer(_listKeyRestaurant, _listRestaurant,
                  _buildItemRestaurant, _pagesTags[0].title),
              buildTabContainer(
                  _listKeyBar, _listBar, _buildItemBar, _pagesTags[1].title),
              buildTabContainer(_listKeyMarket, _listMarket, _buildItemMarket,
                  _pagesTags[2].title),
              buildTabContainer(
                  _listKeyShop, _listShop, _buildItemShop, _pagesTags[3].title),
              buildTabContainer(_listKeyHotel, _listHotel, _buildItemHotel,
                  _pagesTags[4].title),
              buildTabContainer(
                  _listKeyATM, _listATM, _buildItemATM, _pagesTags[5].title),
              buildTabContainer(_listKeyWellness, _listWellness,
                  _buildItemWellness, _pagesTags[6].title),
            ]),
          )),
    );
  }

  Widget buildTabContainer(var listKey, var list, var builderMethod, var cat) {
    return (list != null && list.length > 0)
        ? AnimatedList(
            /*padding: const EdgeInsets.only(
              top: 0.0,
            ),*/
            key: listKey,
            initialItemCount: list.length,
            itemBuilder: builderMethod,
          )
        : Padding(
            padding: EdgeInsets.all(15.0),
            child: _searchTerm == null
                ? Text('Loading...')
                : Column(
                    children: <Widget>[
                      Text(cat.toString().toUpperCase()),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'You filtered for $_searchTerm, but there are no matching results in this category!',
                        style: TextStyle(fontWeight: FontWeight.w300),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Hit the search icon to retrieve unfiltered results or filter for a different word.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ));
  }
}

int _getTagIndex(String searchTerm) {
  Tags.tagText.contains(searchTerm);
  int i = 0;
  for (; i < Tags.tagText.length; i++) {
    if (Tags.tagText.elementAt(i) == searchTerm) {
      break;
    }
  }

  return i;
}

void main() {
  runApp(AnimatedListSample());
}
