import 'package:auto_direction/auto_direction.dart';
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
  final bool expands;
  final bool bottomBorder;
  final bool autofocus;
  final bool isMultiline;
  final double scrollPadding;
  final int maxlines;

  const TextFormFieldWidget({
    this.hintText,
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
    this.prefixIcon,
    this.expands = false,
    this.autofocus = false,
    this.bottomBorder = true,
    this.isMultiline = false,
    this.maxlines = 1,
    this.scrollPadding,
  });

  @override
  _TextFormFieldWidgetState createState() => _TextFormFieldWidgetState();
}

class _TextFormFieldWidgetState extends State<TextFormFieldWidget> {
  double bottomPaddingToError = 12;

  String text = "";

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      // .copyWith(
      // primaryColor: primaryColor,
      // ),
      child: AutoDirection(
        text: text,
        child: TextFormField(
          cursorColor: Colors.white,
          obscureText: widget.obscureText,
          expands: widget.expands,
          keyboardType: widget.isMultiline ? TextInputType.multiline : null,
          scrollPadding: EdgeInsets.only(
              bottom: widget.scrollPadding != null ? widget.scrollPadding : 20),
          maxLines: widget.isMultiline ? null : widget.maxlines,
          // maxLines: null,
          autofocus: widget.autofocus,

          // keyboardType: widget.textInputType,
          // textInputAction: widget.actionKeyboard,
          // focusNode: widget.focusNode,
          style: TextStyle(color: Colors.white),
          // initialValue: widget.defaultText,
          decoration: InputDecoration(
            labelText: widget.lableText,
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Colors.grey),
            labelStyle: TextStyle(color: Colors.white),
            focusColor: Colors.white,
            focusedBorder: widget.bottomBorder
                ? UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white))
                : InputBorder.none,
            enabledBorder: widget.bottomBorder
                ? UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white))
                : InputBorder.none,
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
              return '';
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
          onChanged: (value) {
            setState(() {
              text = value;
            });
          },
        ),
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
