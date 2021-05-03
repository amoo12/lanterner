import 'package:flutter/material.dart';

class TextFormFieldWidget extends StatefulWidget {
  final TextInputType textInputType;
  final String hintText;
  final String lableText;
  final Widget prefixIcon;
  // final String defaultText;
  final FocusNode focusNode;
  final bool obscureText;
  final TextEditingController controller;
  final Function functionValidate;
  final String parametersValidate;
  final String validatorMessage;
  final TextInputAction actionKeyboard;
  final Function onSubmitField;
  final Function onFieldTap;
  final Function onSaved;

  const TextFormFieldWidget(
      {this.hintText,
      this.lableText,
      this.focusNode,
      this.textInputType,
      // this.defaultText,
      this.obscureText = false,
      this.controller,
      this.functionValidate,
      this.validatorMessage,
      this.parametersValidate,
      this.actionKeyboard = TextInputAction.next,
      this.onSubmitField,
      this.onSaved,
      this.onFieldTap,
      this.prefixIcon});

  @override
  _TextFormFieldWidgetState createState() => _TextFormFieldWidgetState();
}

class _TextFormFieldWidgetState extends State<TextFormFieldWidget> {
  double bottomPaddingToError = 12;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      // .copyWith(
      // primaryColor: primaryColor,
      // ),
      child: TextFormField(
        cursorColor: Colors.white,
        obscureText: widget.obscureText,
        // keyboardType: widget.textInputType,
        // textInputAction: widget.actionKeyboard,
        // focusNode: widget.focusNode,
        style: TextStyle(color: Colors.white),
        // initialValue: widget.defaultText,
        decoration: InputDecoration(
          labelText: widget.lableText,
          labelStyle: TextStyle(color: Colors.white),
          focusColor: Colors.white,
          focusedBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        ),
        controller: widget.controller,
        validator: (value) {
          if (widget.functionValidate != null) {
            String resultValidate = widget.functionValidate(
                value.trim(), widget.parametersValidate);
            commonValidation(value, widget.validatorMessage);
            if (resultValidate != null) {
              return resultValidate;
            }
          } else {
            return commonValidation(value, widget.validatorMessage);
          }
        },
        onFieldSubmitted: (value) {
          if (widget.onSubmitField != null) widget.onSubmitField();
        },
        onTap: () {
          if (widget.onFieldTap != null) widget.onFieldTap();
        },
        onSaved: (value) {
          if (widget.onSaved != null) widget.onSaved(value.trim());
        },
      ),
    );
  }
}

String commonValidation(String value, String messageError) {
  var required = requiredValidator(value, messageError);
  if (required != null) {
    return required;
  }
  return null;
}

String requiredValidator(value, messageError) {
  if (value.isEmpty) {
    return messageError;
  }
  return null;
}

void changeFocus(
    BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}
