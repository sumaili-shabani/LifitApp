import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  final String courseCode = "CR12345";
  final String amount = "15.00 USD";
  final String appName = "SwiftRide";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reçu")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Printing.layoutPdf(
              onLayout: (PdfPageFormat format) async {
                final pdf = pw.Document();

                final qrData = 'Course: $courseCode | Montant: $amount';

                pdf.addPage(
                  pw.Page(
                    build: (pw.Context context) {
                      return pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            appName,
                            style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text("Reçu de course"),
                          pw.Divider(),
                          pw.Text("Code de la course : $courseCode"),
                          pw.Text("Montant payé : $amount"),
                          pw.SizedBox(height: 20),
                          pw.Center(
                            child: pw.Container(
                              width: 150,
                              height: 150,
                              child: pw.BarcodeWidget(
                                barcode: pw.Barcode.qrCode(),
                                data: qrData,
                                width: 150,
                                height: 150,
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text("Merci d'avoir utilisé SwiftRide."),
                        ],
                      );
                    },
                  ),
                );

                return pdf.save();
              },
            );
          },
          child: Text("Imprimer le reçu"),
        ),
      ),
    );
    
  }
}