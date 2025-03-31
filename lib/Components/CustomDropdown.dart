import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final List<Map<String, dynamic>> items; // Liste des données JSON
  final String label; // Label du champ
  final String displayKey; // Clé à afficher dans la liste
  final String valueKey; // Clé contenant la valeur réelle
  final Function(dynamic)
  onChanged; // Callback pour récupérer la valeur sélectionnée
  final IconData icon;
  final bool? validatorInput;
  final bool? enabledChamps;
  final dynamic value; // Valeur initiale sélectionnée (int ou String)

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
    this.value,
  }) : super(key: key);

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  dynamic selectedValue; // Valeur actuellement sélectionnée (int ou String)

  @override
  void initState() {
    super.initState();
    selectedValue = widget.value; // Initialisation de la valeur sélectionnée
  }

  @override
  void didUpdateWidget(covariant CustomDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Mettre à jour la sélection si la valeur initiale a changé
    if (widget.value != oldWidget.value) {
      setState(() {
        selectedValue = widget.value;
      });
    }

    // Réinitialiser la sélection si la liste des items change
    if (oldWidget.items != widget.items &&
        !widget.items.any((item) => item[widget.valueKey] == selectedValue)) {
      setState(() {
        selectedValue = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      margin: const EdgeInsets.symmetric(vertical: 1),
      width: size.width * .9,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: DropdownButtonFormField<dynamic>(
          value: selectedValue,
          decoration: InputDecoration(
            prefixIcon: Icon(widget.icon),
            labelText: widget.label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (value) {
            if (widget.validatorInput == true &&
                (value == null || value.toString().isEmpty)) {
              return "Ce champ est requis";
            }
            return null;
          },
          items:
              widget.items.map((item) {
                return DropdownMenuItem<dynamic>(
                  value:
                      item[widget
                          .valueKey], // 🔥 Garde le type d'origine (int ou String)
                  child: Text(
                    item[widget.displayKey].toString(),
                  ), // Toujours afficher en String
                );
              }).toList(),
          onChanged:
              widget.enabledChamps == false
                  ? null
                  : (value) {
                    setState(() {
                      selectedValue = value; // Mise à jour locale
                    });
                    widget.onChanged(value); // Retourne la valeur sélectionnée
                  },
        ),
      ),
    );
  }
}
