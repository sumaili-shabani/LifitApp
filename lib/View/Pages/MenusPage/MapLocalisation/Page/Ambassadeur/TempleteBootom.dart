import 'package:flutter/material.dart';
import 'package:lifti_app/Model/ConducteurModel.dart';

class TempleteBootom extends StatefulWidget {
  final ConducteurModel user;
  final Function onClicFunction;
  const TempleteBootom({super.key, required this.user,
    required this.onClicFunction,
  });

  @override
  State<TempleteBootom> createState() => _TempleteBootomState();
}

class _TempleteBootomState extends State<TempleteBootom> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height:
          MediaQuery.of(context).size.height *
          0.75, // Augmenté à 75% pour plus de visibilité
      width: MediaQuery.of(context).size.width * 1,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 5),
            // ajout card statistique
            //fin card statistique
        
            // Liste de revenu
            //Fin liste de revenu
          ],
        ),
      ),
    );
    
  }
}