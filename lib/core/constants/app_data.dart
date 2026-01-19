import 'package:flutter/material.dart';

final List<String> kCategories = [
  'Netflix',
  'Upwork',
  'Starbucks',
  'Paypal',
  'Youtube',
  'Transfer',
];

final Map<String, Widget> kCategoryAvatars = {
  'Netflix': const CircleAvatar(
    radius: 14,
    backgroundColor: Colors.black,
    child: Text(
      'N',
      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
    ),
  ),
  'Upwork': CircleAvatar(
    radius: 14,
    backgroundColor: Colors.green[600],
    child: const Icon(Icons.work, color: Colors.white, size: 18),
  ),
  'Starbucks': const CircleAvatar(
    radius: 14,
    backgroundColor: Color(0xff006241),
    child: Icon(Icons.coffee, color: Colors.white, size: 18),
  ),
  'Paypal': CircleAvatar(
    radius: 14,
    backgroundColor: Colors.blue.shade700,
    child: const Icon(Icons.paypal, color: Colors.white, size: 18),
  ),
  'Youtube': const CircleAvatar(
    radius: 14,
    backgroundColor: Colors.red,
    child: Icon(Icons.play_arrow, color: Colors.white, size: 18),
  ),
  'Transfer': const CircleAvatar(
    radius: 14,
    backgroundColor: Colors.grey,
    child: Icon(Icons.swap_horiz, color: Colors.white, size: 18),
  ),
};
