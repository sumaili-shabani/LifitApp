import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> items; // Liste des données JSON
  final String label; // Label du champ
  final String displayKey; // Clé à afficher dans la liste
  final String valueKey; // Clé contenant la valeur réelle
  final Function(String?)
  onChanged; // Callback pour récupérer la valeur sélectionnée
  final IconData icon;
  final bool? validatorInput;
  final bool? enabledChamps;
  final String? value; // 🔥 Nouvelle propriété pour valeur sélectionnée

  const CustomDropdown({
    Key? key,
    required this.items,
    required this.label,
    required this.displayKey,
    required this.valueKey,
    required this.onChanged,
    required this.icon,
    this.validatorInput = false,
    this.enabledChamps = true,
    this.value, // 🔥 Ajout de l'attribut value
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      margin: const EdgeInsets.symmetric(vertical: 1),
      width: size.width * .9,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: DropdownButtonFormField<String>(
          value: value, // 🔥 Utilisation de la valeur initiale
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (value) {
            if (validatorInput == true) {
              if (value == null || value.isEmpty) {
                return "Ce champ est requis";
              }
            }
            return null;
          },
          items:
              items.map((item) {
                return DropdownMenuItem<String>(
                  value: item[valueKey].toString(),
                  child: Text(item[displayKey]),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
