import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lifti_app/Api/ConfigurationApp.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Model/CourseInfoPassagerModel.dart';

class CommentaireCourse extends StatefulWidget {
  final CourseInfoPassagerModel course;
  final Function(CourseInfoPassagerModel) onSubmitComment; // Callback function
  const CommentaireCourse({
    super.key,
    required this.course,
    required this.onSubmitComment,
  });

  @override
  State<CommentaireCourse> createState() => _CommentaireCourseState();
}

class _CommentaireCourseState extends State<CommentaireCourse> {
  double rating = 3.0; // Note par défaut
  TextEditingController commentController = TextEditingController();
  bool isLoading = false;

  List<String> commentSuggestions = [
    "Chauffeur très courtois et professionnel.",
    "Trajet agréable, voiture propre et confortable.",
    "Bonne conduite, je recommande.",
    "Ponctuel et efficace, merci !",
    "Chauffeur sympa, mais la conduite peut être améliorée.",
    "Expérience moyenne, quelques retards.",
  ];

  @override
  void initState() {
    super.initState();
    commentController.text = widget.course.commentaires! ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height:
          MediaQuery.of(context).size.height *
          0.85, // Augmenté à 85% pour plus de visibilité
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
          Center(
            child: Text(
              "Évaluez votre chauffeur",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 16),

          // ⭐ Système de notation
          Center(
            child: RatingBar.builder(
              initialRating: rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder:
                  (context, _) => Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (newRating) {
                rating = newRating;
              },
            ),
          ),
          SizedBox(height: 16),

          // 📌 Suggestions de commentaires avec icônes
          Wrap(
            spacing: 8.0,
            children:
                commentSuggestions.map((suggestion) {
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.comment, size: 16, color: Colors.blue),
                        SizedBox(width: 4),
                        Flexible(child: Text(suggestion)),
                      ],
                    ),
                    selected: false,
                    onSelected: (selected) {
                      commentController.text = suggestion;
                    },
                  );
                }).toList(),
          ),
          SizedBox(height: 16),

          // ✍️ Champ de commentaire
          TextField(
            controller: commentController,
            decoration: InputDecoration(
              labelText: "Laissez un commentaire...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.edit, color: Colors.grey),
            ),
            maxLines: 2,
          ),
          SizedBox(height: 16),

          // ✅ Bouton d'envoi
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  isLoading
                      ? null
                      : () async {
                        String comment = commentController.text.trim();
                        if (comment.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Veuillez saisir un commentaire avant d'envoyer.",
                              ),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          isLoading = true;
                        });

                        Map<String, dynamic> svData = {
                          'id': widget.course.id,
                          'rating': rating,
                          'commentaires': comment.toString(),
                        };

                        final response = await CallApi.postData(
                          "passager_update_avis_course",
                          svData,
                        );
                        var message = response['message'];
                        print("message $message");
                        if (message != "") {
                          setState(() {
                            isLoading = false;
                          });

                          showSnackBar(context, message, 'success');
                          widget.onSubmitComment(widget.course);
                        }
                      },
              icon:
                  isLoading
                      ? Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                      : Icon(Icons.send, color: Colors.white),
              label: Text(
                isLoading ? "Envoie..." : "Envoyer",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ConfigurationApp.successColor,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
