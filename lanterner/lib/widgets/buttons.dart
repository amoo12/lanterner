import 'package:flutter/material.dart';

// reuseable button widget, for main buttons
class ButtonWidget extends StatelessWidget {
  final BuildContext context;
  final String text;
  final int
      buttonType; //default type: accentColor button with text, type 2: reverse
  final Function onPressed;

  const ButtonWidget({
    this.context,
    this.text,
    this.onPressed,
    this.buttonType,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      
        style: ElevatedButton.styleFrom(
          
          padding: EdgeInsets.symmetric(vertical: 15),
          primary:
              buttonType == 2 ? Colors.white : Theme.of(context).accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            // side: buttonType == 2
            //   // ? BorderSide(color: Theme.of(context).accentColor, width: 1)
            //   //     : BorderSide.none
            // ),
          ),
        ),
        child: Text(text,
            style: buttonType == 2
                ? Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(color: Theme.of(context).primaryColor)
                : Theme.of(context).textTheme.button
            // .copyWith(color: Theme.of(context).primaryColor),
            ),
        onPressed: onPressed);
  }
}
