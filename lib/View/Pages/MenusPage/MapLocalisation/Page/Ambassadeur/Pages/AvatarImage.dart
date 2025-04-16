import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Model/ConducteurModel.dart';

class AvatarImage extends StatefulWidget {
  final ConducteurModel user;
  final Function onClicFunction;
  const AvatarImage({super.key, required this.user, required this.onClicFunction});

  @override
  State<AvatarImage> createState() => _AvatarImageState();
}

class _AvatarImageState extends State<AvatarImage> {
  /*
  *
  *============================
  * Pour upload de l'image
  *============================
  *
  */
  File? _imageFile;
  bool _isUploading = false;
  // ignore: unused_field
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Sélectionnez d'abord une image")));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String apiUrl =
          '${CallApi.baseUrl}/chauffeur_mobile_edit_photo_user'; // Changez l'URL de votre API
      int? userId = await CallApi.getUserId();
      if (userId == null) {
        throw Exception("ID utilisateur introuvable");
      }

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll(await CallApi.getHeaders());
      request.files.add(
        await http.MultipartFile.fromPath("image", _imageFile!.path),
      );
      request.fields["data"] = jsonEncode({"id": widget.user.id.toString()});

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var decodedData = jsonDecode(responseData);

        setState(() {
          _imageUrl = decodedData['image_url'].toString();
          _imageFile = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image mise à jour avec succès")),
        );
        //actualisation de la fonction user
        widget.onClicFunction();
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

  /*
  *
  *============================
  * Fin Pour upload de l'image
  *============================
  *
  */

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height:
          MediaQuery.of(context).size.height *
          0.35, // Augmenté à 85% pour plus de visibilité
      width: MediaQuery.of(context).size.width * 1,
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
            "Modifier sa photo",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          // uploader fichieer
          CircleAvatar(
            radius: 60,
            backgroundImage:
                _imageFile != null
                    ? FileImage(File(_imageFile!.path)) as ImageProvider
                    : NetworkImage("${CallApi.fileUrl}/images/${widget.user.avatar}"),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
              ),
              SizedBox(width: 10),
              InkWell(
                onTap: _uploadImage,
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
                          : Icon(Icons.upload, color: Colors.white),
                ),
              ),
            ],
          ),

          // fin upload fichier
        ],
      ),
    );
  }
}
