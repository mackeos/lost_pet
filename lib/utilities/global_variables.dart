import 'package:flutter/material.dart';
import 'package:lost_pet/screens/add_post_screen.dart';
import 'package:lost_pet/screens/feed_screen.dart';
import 'package:lost_pet/screens/profile_screen.dart';
import 'package:lost_pet/screens/search_screen.dart';

const webScreenSize = 600;

const homeScreenPages = [
  FeedScreen(),
  SearchScreen(),
  AddPostScreen(),
  Center(
    child: Text('Chat'),
  ),
  ProfileScreen(),
];
