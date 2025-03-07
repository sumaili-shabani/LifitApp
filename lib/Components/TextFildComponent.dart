import 'package:flutter/material.dart';

class TextFildComponent extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool passwordInvisible;
  final TextEditingController controller;
  final bool? validatorInput;
  final int? maxLines;
  final String labeltext;
  final bool? keyboardTypeNumber;
  final bool? enabledChamps;

  const TextFildComponent({
    super.key,
    required this.labeltext,
    required this.hint,
    required this.icon,
    required this.controller,
    this.passwordInvisible = false,
    this.validatorInput = false,
    this.keyboardTypeNumber = false,
    this.enabledChamps = true,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      margin: const EdgeInsets.symmetric(vertical: 1),
      width: size.width * .9,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: TextFormField(
          obscureText: passwordInvisible,
          enabled: enabledChamps,
          keyboardType:
              keyboardTypeNumber == true
                  ? TextInputType.number
                  : TextInputType.text,
          controller: controller,
          maxLines: maxLines ?? 1,
          decoration: InputDecoration(
            // border: const UnderlineInputBorder(),
            hintText: hint,
            label: Text(labeltext),
            prefixIcon: Icon(icon),
          ),
          validator: (value) {
            if (validatorInput == true) {
              if (value!.isEmpty) {
                return "Ce champs est requis";
              } else {
                return null;
              }
            } else {
              return null;
            }
          },
        ),
      ),
    );
  }
}
