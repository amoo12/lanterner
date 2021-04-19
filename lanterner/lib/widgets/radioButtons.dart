import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CustomRadio extends StatefulWidget {
  CustomRadio(this.gender);
  String gender;
  @override
  createState() {
    return CustomRadioState();
  }
}

class CustomRadioState extends State<CustomRadio> {
  List<RadioModel> sampleData = List<RadioModel>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sampleData.add(RadioModel(false, 'Male', 'Male'));
    sampleData.add(RadioModel(false, 'Female', 'Female'));
    // sampleData.add( RadioModel(false, 'C', 'April 16'));
    // sampleData.add( RadioModel(false, 'D', 'April 15'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          // ListView.builder(
          //   scrollDirection: Axis.horizontal,
          //   itemCount: sampleData.length,
          //   itemBuilder: (BuildContext context, int index) {
          //     return
          Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            //highlightColor: Colors.red,
            splashColor: Colors.blueAccent,
            onTap: () {
              setState(() {
                sampleData.forEach((element) => element.isSelected = false);
                sampleData[0].isSelected = true;
                widget.gender = sampleData[0].text;
              });
            },
            child: RadioItem(sampleData[0]),
          ),
          InkWell(
            //highlightColor: Colors.red,
            splashColor: Colors.blueAccent,
            onTap: () {
              setState(() {
                sampleData.forEach((element) => element.isSelected = false);
                sampleData[1].isSelected = true;
                widget.gender = sampleData[1].text;
              });
            },
            child: RadioItem(sampleData[1]),
          ),
        ],
      ),
      // },
      // ),
    );
  }
}

class RadioItem extends StatelessWidget {
  final RadioModel _item;
  RadioItem(this._item);

  Color genderColor(RadioModel _item, BuildContext context,
      {isBorder = false}) {
    if (_item.isSelected) {
      if (_item.text == 'Male') {
        return Theme.of(context).accentColor;
      } else {
        return Colors.pinkAccent[400];
      }
    } else {
      return isBorder ? Colors.grey : Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _item.isSelected ? 110 : 100,
            width: _item.isSelected ? 110 : 100,
            curve: Curves.easeInOut,
            child: Center(
                child: _item.text == 'Male'
                    ? Icon(
                        MdiIcons.genderMale,
                        color: _item.isSelected ? Colors.white : Colors.grey,
                      )
                    : Icon(
                        MdiIcons.genderFemale,
                        color: _item.isSelected ? Colors.white : Colors.grey,
                      )
                // Text(_item.buttonText,
                //     style: TextStyle(
                //         color: _item.isSelected ? Colors.white : Colors.grey,
                //         //fontWeight: FontWeight.bold,
                //         fontSize: 18.0)
                //         ),
                ),
            decoration: BoxDecoration(
              color: genderColor(_item, context),
              border: Border.all(
                  width: 1.0,
                  color: genderColor(_item, context, isBorder: true)),
              borderRadius: const BorderRadius.all(const Radius.circular(2.0)),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Text(_item.text),
          )
        ],
      ),
    );
  }
}

class RadioModel {
  bool isSelected;
  final String buttonText;
  final String text;

  RadioModel(this.isSelected, this.buttonText, this.text);
}
