import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lost_pet/screens/profile_screen.dart';
import 'package:lost_pet/utilities/colors.dart';
import 'package:lost_pet/utilities/global_variables.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  late FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: barColor,
          title: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: "Search...",
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (String value) {},
            textInputAction: TextInputAction.search,
            onSubmitted: (String value) {
              setState(() {
                isSearching = value.isNotEmpty;
              });
              FocusScope.of(context).unfocus();
            },
            onEditingComplete: () {},
          ),
          actions: [
            AspectRatio(
              aspectRatio: 1,
              child: InkWell(
                onTap: () {
                  setState(() {
                    isSearching = _searchController.text.isNotEmpty;
                  });
                  FocusScope.of(context).unfocus();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 44, 110),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.search),
                ),
              ),
            ),
          ],
          bottom: isSearching
              ? null
              : const TabBar(
                  tabs: [
                    Tab(
                      text: "Lost Pets",
                    ),
                    Tab(
                      text: "Found Pets",
                    ),
                  ],
                ),
        ),
        body: isSearching
            ? Center(
                child: Container(
                  width: webScreenSize.toDouble(),
                  child: FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .where(
                          'username',
                          isGreaterThanOrEqualTo: _searchController.text,
                        )
                        .get(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                snapshot.data.docs[index]
                                    .data()['profileImage'],
                              ),
                            ),
                            title: Text(
                              snapshot.data.docs[index].data()['username'],
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                  uid: snapshot.data.docs[index].data()['uid'],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              )
            : Center(
                child: Container(
                  width: webScreenSize.toDouble(),
                  child: TabBarView(
                    children: [
                      buildFutureBuilderGrid(
                        FirebaseFirestore.instance
                            .collection("posts")
                            .where("type", isEqualTo: "lost")
                            .orderBy("datePosted", descending: true)
                            .get(),
                      ),
                      buildFutureBuilderGrid(
                        FirebaseFirestore.instance
                            .collection("posts")
                            .where("type", isEqualTo: "found")
                            .orderBy("datePosted", descending: true)
                            .get(),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  FutureBuilder<QuerySnapshot<Map<String, dynamic>>> buildFutureBuilderGrid(
    Future<QuerySnapshot<Map<String, dynamic>>>? future,
  ) {
    return FutureBuilder(
      future: future,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: barColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: Image.network(
                            snapshot.data.docs[index].data()['postUrl'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        // products is out demo list
                        snapshot.data.docs[index].data()['username'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      snapshot.data.docs[index].data()['description'] == ''
                          ? "No description"
                          : snapshot.data.docs[index].data()['description'],
                      style: const TextStyle(
                        color: secondaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: true,
                    )
                  ],
                ),
              );
            },
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2.5,
              mainAxisSpacing: 2.5,
              childAspectRatio: 1,
            ),
          ),
        );
      },
    );
  }
}
