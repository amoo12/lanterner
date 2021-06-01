import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
//ignore: must_be_immutable
class CustomRadio extends StatefulWidget {
  CustomRadio(this.genderChanged);
  Function genderChanged;
  @override
  createState() {
    return CustomRadioState();
  }
}

class CustomRadioState extends State<CustomRadio> {
  List<RadioModel> sampleData = [];

  @override
  void initState() {
    super.initState();
    sampleData.add(RadioModel(false, 'Male', 'Male'));
    sampleData.add(RadioModel(false, 'Female', 'Female'));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          //highlightColor: Colors.red,
          // splashColor: Theme.of(context).accentColor,
          onTap: () {
            setState(() {
              if (sampleData[0].isSelected) {
                sampleData[0].isSelected = false;
                widget.genderChanged('');
              } else {
                sampleData.forEach((element) => element.isSelected = false);
                sampleData[0].isSelected = true;
                widget.genderChanged(sampleData[0].text);
              }
            });
          },
          child: RadioItem(sampleData[0]),
        ),
        GestureDetector(
          //highlightColor: Colors.red,
          // splashColor: Theme.of(context).accentColor,
          onTap: () {
            setState(() {
              if (sampleData[1].isSelected) {
                sampleData[1].isSelected = false;
                widget.genderChanged('');
              } else {
                sampleData.forEach((element) => element.isSelected = false);
                sampleData[1].isSelected = true;
                widget.genderChanged(sampleData[1].text);
              }
            });
          },
          child: RadioItem(sampleData[1]),
        ),
      ],
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
        return Colors.pink[300];
      }
    } else {
      if (isBorder) {
        return _item.text == 'Male'
            ? Theme.of(context).accentColor
            : Colors.pink[300];
      } else {
        return Colors.transparent;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: EdgeInsets.all(15.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _item.isSelected ? 110 : 100,
            width: _item.isSelected ? 110 : 100,
            curve: Curves.ease,
            child: Center(
                child: _item.text == 'Male'
                    ? Icon(
                        MdiIcons.genderMale,
                        color: _item.isSelected ? Colors.white : Colors.grey,
                        size: _item.isSelected ? 32 : 24,
                      )
                    : Icon(
                        MdiIcons.genderFemale,
                        color: _item.isSelected ? Colors.white : Colors.grey,
                        size: _item.isSelected ? 32 : 24,
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
              borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
              boxShadow: [
                // BoxShadow(
                // color: _item.isSelected
                //     ? Colors.black
                //     : Colors.black.withOpacity(0),
                // blurRadius: 25.0, // soften the shadow
                // spreadRadius: 5.0, //extend the shadow
                // offset: Offset(
                //   15.0, // Move to right 10  horizontally
                //   15.0, // Move to bottom 10 Vertically
                // ),
                // ),
                BoxShadow(
                  color: _item.isSelected
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.0),
                  spreadRadius: 4,
                  blurRadius: 3,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Text(
              _item.text,
              style: TextStyle(
                color: _item.isSelected ? Colors.white : Colors.grey,
              ),
            ),
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
