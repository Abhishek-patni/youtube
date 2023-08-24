import 'package:flutter/material.dart';

class DropdownButtonExample extends StatefulWidget {
  const DropdownButtonExample({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _DropdownButtonExampleState();
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  static const format = <String>[
    'mp4',
    'mp3',
  ];
  static const quality = <String>[
    '144p',
    '240p',
    '360p',
    '480p',
  ];

  final List<DropdownMenuItem<String>> _dropDownMenuItemsFormat = format
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        ),
      )
      .toList();

  final List<DropdownMenuItem<String>> _dropDownMenuItemsQuality = quality
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        ),
      )
      .toList();

  String? _formatSelectedVal;
  String? _qualitySelectedVal;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text('Format'),
          trailing: DropdownButton(
            value: _formatSelectedVal,
            hint: Text('Choose'),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() => _formatSelectedVal = newValue);
                if (newValue == "mp4") {
                  print("hello World");
                }
                else if(newValue=="mp3"){
                  print("ok now we serious");
                }
                else{
                  print("Enter valid value");
                }
              }
            },
            items: _dropDownMenuItemsFormat,
          ),
        ),
        ListTile(
          title: Text('Quality'),
          trailing: DropdownButton(
            value: _qualitySelectedVal,
            hint: Text('Choose'),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() => _qualitySelectedVal = newValue);
                if (newValue == "144p") {
                  print("hello World");
                }
                else if(newValue=="240p"){
                  print("ok now we serious");
                }
                else if(newValue=="360p"){
                  print("ok now we serious");
                }
                else if(newValue=="480p"){
                  print("we full");
                }
                else{
                  print("Choose a valid value");
                }
              }
            },
            items: _dropDownMenuItemsQuality,
          ),
        ),
      ],
    );
  }
}
