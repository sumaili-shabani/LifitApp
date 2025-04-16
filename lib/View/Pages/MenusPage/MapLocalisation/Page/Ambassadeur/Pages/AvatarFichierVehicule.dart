import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Model/VehiculeModel.dart';
import 'package:file_picker/file_picker.dart';

class AvatarFichierVehicule extends StatefulWidget {
  final VoitureModel vehicule;
  final Function(VoitureModel taxi) onClicFunction;

  const AvatarFichierVehicule({
    super.key,
    required this.vehicule,
    required this.onClicFunction,
  });

  @override
  State<AvatarFichierVehicule> createState() => _AvatarFichierVehiculeState();
}

class _AvatarFichierVehiculeState extends State<AvatarFichierVehicule> {
  File? _selectedFile;
  bool _isUploading = false;
  // ignore: unused_field
  String? _fileUrl;
  // ignore: unused_field
  final ImagePicker _picker = ImagePicker();
  bool isImage = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        isImage = result.files.single.extension != 'pdf';
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sélectionnez d'abord un fichier")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String apiUrl = '${CallApi.baseUrl}/update_mobile_fichier_vehicule';
      int? userId = await CallApi.getUserId();
      if (userId == null) throw Exception("ID utilisateur introuvable");

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll(await CallApi.getHeaders());
      request.files.add(
        await http.MultipartFile.fromPath("image", _selectedFile!.path),
      );
      request.fields["data"] = jsonEncode({
        "id": widget.vehicule.id!.toString(),
      });

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var decodedData = jsonDecode(responseData);

        setState(() {
          _fileUrl = decodedData['file_url'].toString();
          _selectedFile = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Fichier mis à jour avec succès")),
        );
        widget.onClicFunction(widget.vehicule);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur d'upload")));
      }
    } catch (e) {
      print("Erreur: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Échec de l'upload")));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.40,
      width: MediaQuery.of(context).size.width,
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
          Text(
            "Modifier son document",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),

          // Affichage de l'image ou du fichier PDF
          isImage
              ? CircleAvatar(
                radius: 60,
                backgroundColor: Colors.transparent,
                backgroundImage:
                    _selectedFile != null
                        ? FileImage(_selectedFile!) as ImageProvider
                        : NetworkImage(
                          "${CallApi.fileUrl}/taxi/${widget.vehicule.imageVehicule.toString()}",
                        ),
              )
              : _selectedFile != null
              ? Icon(Icons.picture_as_pdf, size: 60, color: Colors.red)
              : Icon(Icons.file_present, size: 60, color: Colors.grey),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickFile,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.upload_file, color: Colors.white),
                ),
              ),
              SizedBox(width: 10),
              InkWell(
                onTap: _uploadFile,
                child: CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 20,
                  child:
                      _isUploading
                          ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                          : Icon(Icons.cloud_upload, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
