import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GithubRepository {
  final String name;
  final String description;
  final int stars;
  final String ownerName;
  final String ownerAvatarUrl;

  GithubRepository({
    required this.name,
    required this.description,
    required this.stars,
    required this.ownerName,
    required this.ownerAvatarUrl,
  });

  factory GithubRepository.fromJson(Map<String, dynamic> json) {
    return GithubRepository(
      name: json['name'],
      description: json['description'] ?? 'No description available',
      stars: json['stargazers_count'],
      ownerName: json['owner']['login'],
      ownerAvatarUrl: json['owner']['avatar_url'],
    );
  }
}

Future<List<GithubRepository>> fetchGitHubRepositories() async {
  final response = await http.get(Uri.parse(
      'https://api.github.com/search/repositories?q=created:>2022-04-29&sort=stars&order=desc'));

  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    List<dynamic> repos = data['items'];
    return repos.map((json) => GithubRepository.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load GitHub repositories');
  }
}

class GithubRepositoriesScreen extends StatelessWidget {
  const GithubRepositoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Repositories'),
      ),
      body: FutureBuilder<List<GithubRepository>>(
        future: fetchGitHubRepositories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.blue), // Custom color
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      snapshot.data![index].name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                                'Description: ${snapshot.data![index].description}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child:
                                Text('Stars: ${snapshot.data![index].stars}'),
                          ),
                          Text('Owner: ${snapshot.data![index].ownerName}'),
                        ],
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(snapshot.data![index].ownerAvatarUrl),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: Text('No data found'),
          );
        },
      ),
    );
  }
}
