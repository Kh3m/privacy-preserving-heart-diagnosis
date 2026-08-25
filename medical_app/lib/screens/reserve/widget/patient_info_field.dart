import 'dart:developer';

import 'package:flutter/material.dart';
import '../../../constant.dart';

class PatientInfoField extends StatefulWidget {
  final String field;
  final Map fieldValue;
  final String actualValue;
  final bool check;
  final Function onSave;

  const PatientInfoField({
    super.key,
    required this.field,
    required this.check,
    required this.onSave,
    required this.fieldValue,
    required this.actualValue,
  });

  @override
  State<PatientInfoField> createState() => _PatientInfoFieldState();
}

class _PatientInfoFieldState extends State<PatientInfoField> {
  final _focusNode = FocusNode();
  bool _hasFocus = false;
  var _offset = Offset(0, 0);
  final _containerGlobKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
      _offset = _focusNode.offset;
    });
    log("Focus Y: ${_focusNode.offset.dy} ");
    log("Focus X: ${_focusNode.offset.dx} ");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 70,
          width: 50,
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -22,
                child: Text(
                  widget.field,
                  style: const TextStyle(
                    color: mTitleTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: SizedBox(
                  width: 50,
                  child: TextFormField(
                    focusNode: _focusNode,
                    initialValue: widget.actualValue,
                    keyboardType: TextInputType.number,
                    onSaved: ((newValue) =>
                        widget.onSave(widget.field, newValue)),
                    validator: ((value) {
                      if (value!.isEmpty) return "";
                      if (!(widget.fieldValue['possible_values'] == null) &&
                          !widget.fieldValue['possible_values']
                              .toString()
                              .contains(value)) {
                        return "";
                      }

                      return null;
                    }),
                    decoration: InputDecoration(
                      errorStyle: const TextStyle(
                        height: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        // borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      filled: true,
                      hintStyle: TextStyle(color: Colors.grey[800]),
                      fillColor: Colors.transparent,
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.check ? Colors.white : mTitleTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              if (_hasFocus)
                Positioned(
                  left: !(_focusNode.offset.dx > 150) ? -20 : -150,
                  top: !(_focusNode.offset.dy > 350) ? -50 : -85,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black45,
                            offset: Offset.fromDirection(-10, 5),
                            blurRadius: 5,
                            spreadRadius: 1,
                          )
                        ]),
                    child: Container(
                      key: _containerGlobKey,
                      color: Colors.white,
                      child: Text(
                        widget.fieldValue['desc'],
                      ),
                      constraints: const BoxConstraints(
                        maxWidth: 250,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
