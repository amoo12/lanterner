import 'package:flutter/material.dart';
import 'package:lanterner/models/user.dart';

languageIndictor(Language language, [Color color]) {
  List<double> sizes = [16, 12, 8, 4, 0];
  return Container(
    child: Column(
      children: [
        Text(
          '${language.code}'.toUpperCase(),
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: color),
        ),
        Container(
          width: 20,
          padding: language.isNative
              ? EdgeInsets.all(0)
              : EdgeInsets.only(
                  right: sizes[int.parse(language.level ?? 5) - 1]),
          constraints: BoxConstraints(
              minWidth: 20, maxWidth: 20, minHeight: 4, maxHeight: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.grey,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: language.isNative ? Colors.green : Colors.blue[900],
            ),
          ),
        )
      ],
    ),
  );
}
