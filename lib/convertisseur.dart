import 'package:flutter/material.dart';

class Convertisseur extends StatefulWidget {
  const Convertisseur({super.key});

  @override
  State<Convertisseur> createState() => _ConvertisseurState();
}

class _ConvertisseurState extends State<Convertisseur> {
  double resultat = 0.0;
  double tauxChange = 655.957;
  TextEditingController montantController = TextEditingController();
  void convertir() {
    setState(() {
      double montant = double.tryParse(montantController.text) ?? 0.0;

      resultat = montant * tauxChange;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convertisseur de devises'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 16.0,
          children: [
            TextField(
              controller: montantController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Montant en Euros',
              ),
              keyboardType: TextInputType.number,
            ),
            Text(
              "Résultat en FCFA:${resultat.toStringAsFixed(2)}",
            ),
            ElevatedButton(onPressed: convertir, child: Text("Convertir")),
          ],
        ),
      ),
    );
  }
}
