import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final String? Function(String?) validator;
  final bool suffixIcon;
  final bool? isDense;
  final bool obscureText;
  final TextEditingController controller;
  final bool enabled;
  final bool numeric;
  final TextInputType keyboardType;
  const CustomInputField({
    Key? key,
    required this.labelText,
    required this.hintText,
    required this.validator,
    required this.controller,
    required this.keyboardType,
    this.suffixIcon = false,
    this.isDense,
    this.obscureText = false,
    this.enabled=true,
    this.numeric=false,
  }) : super(key: key);

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  //
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.9,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
      child: Column(
        children: [
          Align(
            alignment: context.locale ==  Locale("en") ?Alignment.centerLeft:Alignment.centerRight,
            child: Text(widget.labelText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          ),
          TextFormField(
            style: TextStyle(
              color: widget.enabled?Colors.black:Colors.grey
            ),
            keyboardType: !widget.numeric?TextInputType.text:TextInputType.number,
            inputFormatters: widget.numeric?[FilteringTextInputFormatter.digitsOnly]:null,
            enabled: widget.enabled,
            controller: widget.controller,
            obscureText: (widget.obscureText && _obscureText),
            decoration: InputDecoration(
              isDense: (widget.isDense != null) ? widget.isDense : false,
              hintText: widget.hintText,
              suffixIcon: widget.suffixIcon ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.remove_red_eye : Icons.visibility_off_outlined,
                  color: Colors.black54,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ): null,
              suffixIconConstraints: (widget.isDense != null) ? const BoxConstraints(
                  maxHeight: 33
              ): null,
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: widget.validator,
          ),
        ],
      ),
    );
  }
}