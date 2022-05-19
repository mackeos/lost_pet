import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lost_pet/utilities/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue[900],
            title: TextFormField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Search...",
                prefixIcon: Icon(Icons.search),
              ),
              /* onChanged: (String value) {
                setState(() {
                  isSearching = value.isNotEmpty;
                });
              }, */
              onFieldSubmitted: (value) {
                setState(() {
                  isSearching = value.isNotEmpty;
                });
              },
            ),
            bottom: const TabBar(
              tabs: [
                Tab(
                  text: "Users",
                ),
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
              ? TabBarView(
                  children: [
                    FutureBuilder(
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
                                      .data()['profile_image'],
                                ),
                              ),
                              title: Text(
                                snapshot.data.docs[index].data()['username'],
                              ),
                              onTap: () {},
                            );
                          },
                        );
                      },
                    ),
                    FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection("posts")
                          .where("type", isEqualTo: "lost")
                          .orderBy("datePosted", descending: true)
                          .get(),
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
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[900],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: SizedBox(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              snapshot.data.docs[index]
                                                  .data()['postUrl'],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2),
                                      child: Text(
                                        // products is out demo list
                                        snapshot.data.docs[index]
                                            .data()['username'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      snapshot.data.docs[index]
                                          .data()['description'],
                                      style: TextStyle(color: Colors.grey[300]),
                                    )
                                  ],
                                ),
                              );
                            },
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.75,
                            ),
                          ),
                        );
                      },
                    ),
                    FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection("posts")
                          .where("type", isEqualTo: "lost")
                          .orderBy("datePosted", descending: true)
                          .get(),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        print(snapshot.data.docs.length);
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
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[900],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: SizedBox(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              snapshot.data.docs[index]
                                                  .data()['postUrl'],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2),
                                      child: Text(
                                        // products is out demo list
                                        snapshot.data.docs[index]
                                            .data()['username'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      snapshot.data.docs[index]
                                          .data()['description'],
                                      style: TextStyle(color: Colors.grey[300]),
                                    )
                                  ],
                                ),
                              );
                            },
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.75,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                )
              : Container(),
        ),
      ),
    );
  }
}
