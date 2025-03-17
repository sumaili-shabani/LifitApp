import 'package:flutter/material.dart';
import 'package:lifti_app/Api/ConfigurationApp.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:http/http.dart' as http;

class TargetListScreen extends StatefulWidget {
  const TargetListScreen({super.key});

  @override
  State<TargetListScreen> createState() => _TargetListScreenState();
}

class _TargetListScreenState extends State<TargetListScreen> {
  List<dynamic> targets = [];
  bool isLoading = true;
  int idRole = 0;

  List<dynamic> filteredTargets = [];
  TextEditingController searchController = TextEditingController();

  Future<void> fetchData() async {
    int? roleId = await CallApi.getUserRole();
    int? userId = await CallApi.getUserId();

    final response = await http.get(
      Uri.parse(
        '${CallApi.baseUrl.toString()}/user_mobile_info/${userId.toString()}',
      ),
      headers: await CallApi.getHeaders(),
    );

    List<dynamic> infoData = await CallApi.fetchListData(
      'fetch_target_by_role/${roleId.toString()}',
    );

    // print(infoData);

    if (response.statusCode == 200) {
      // final data = jsonDecode(response.body)['data'];
      // print(data);
      setState(() {
        idRole = roleId!;
        targets = infoData;
        filteredTargets = infoData;
        isLoading = false;
      });
    } else {
      throw Exception('Erreur de chargement des données');
    }
  }

  void filterTargets(String query) {
    setState(() {
      filteredTargets =
          targets
              .where(
                (target) =>
                    target["nomTarget"].toString().toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    target["role_name"].toString().toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
       
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            onChanged: filterTargets,
            decoration: InputDecoration(
              hintText: "Rechercher un target...",
              prefixIcon: Icon(Icons.search),
              fillColor: theme.hoverColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        isLoading
            ? Center(child: CircularProgressIndicator())
            : Expanded(
              child: ListView.builder(
                itemCount: filteredTargets.length,
                itemBuilder: (context, index) {
                  var target = filteredTargets[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.flag, color: ConfigurationApp.successColor, size: 40),
                      title: Text(
                        target["nomTarget"],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "${target["periodeDebitTarget"]} - ${target["periodeFinTarget"]}",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.directions_car,
                                size: 16,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "Exigence: ${target["nombreCourse"]} ${target["uniteTarget"]}",
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "${target["prixTarget"]} ${target["devise"]}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Pour: ${target["role_name"]}"),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Icon(
                        target["statutTarget"] == 1
                            ? Icons.check_circle
                            : Icons.cancel,
                        color:
                            target["statutTarget"] == 1
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
      ],
    );
  }
}
