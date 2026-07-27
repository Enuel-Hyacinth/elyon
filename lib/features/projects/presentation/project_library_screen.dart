import 'package:flutter/material.dart';

import '../models/project_model.dart';
import '../services/project_service.dart';
import '../widgets/project_card.dart';
import 'project_details_screen.dart';

class ProjectLibraryScreen extends StatefulWidget {
  const ProjectLibraryScreen({super.key});

  @override
  State<ProjectLibraryScreen> createState() =>
      _ProjectLibraryScreenState();
}

class _ProjectLibraryScreenState
    extends State<ProjectLibraryScreen> {

  final ProjectService _projectService =
      ProjectService();

  late Future<List<ProjectModel>> _projectsFuture;

  String _searchQuery = "";

  String _selectedIntent = "All";

  bool _sortNewest = true;

  @override
  void initState() {
    super.initState();

    _projectsFuture =
        _projectService.getProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Project Library"),
        centerTitle: true,
      ),

      body: Column(
        children: [

          //-----------------------------------
          // SEARCH BOX
          //-----------------------------------

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search projects...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          //-----------------------------------
          // PROJECT FILTER
          //-----------------------------------

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [

                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedIntent,
                    decoration: InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    items: const [

                      DropdownMenuItem(
                        value: "All",
                        child: Text("All"),
                      ),

                      DropdownMenuItem(
                        value: "animation",
                        child: Text("Animation"),
                      ),

                      DropdownMenuItem(
                        value: "story",
                        child: Text("Story"),
                      ),

                      DropdownMenuItem(
                        value: "marketing",
                        child: Text("Marketing"),
                      ),

                      DropdownMenuItem(
                        value: "education",
                        child: Text("Education"),
                      ),

                      DropdownMenuItem(
                        value: "music",
                        child: Text("Music"),
                      ),

                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedIntent = value!;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 12),

                IconButton(
                  tooltip: _sortNewest
                      ? "Newest First"
                      : "Oldest First",
                  icon: Icon(
                    _sortNewest
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                  ),
                  onPressed: () {
                    setState(() {
                      _sortNewest = !_sortNewest;
                    });
                  },
                ),

              ],
            ),
          ),

          const SizedBox(height: 16),

          //-----------------------------------
          // PROJECT LIST
          //-----------------------------------

          Expanded(
            child: FutureBuilder<List<ProjectModel>>(
              future: _projectsFuture,

              builder: (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                    ),
                  );
                }

                List<ProjectModel> projects =
                    snapshot.data ?? [];

                //-----------------------------------
                // SEARCH + FILTER
                //-----------------------------------

                projects = projects.where((project) {

                  final matchesSearch =
                      project.title
                          .toLowerCase()
                          .contains(
                            _searchQuery.toLowerCase(),
                          );

                  final matchesIntent =
                      _selectedIntent == "All" ||
                      project.intent == _selectedIntent;

                  return matchesSearch &&
                      matchesIntent;

                }).toList();

                //-----------------------------------
                // SORT
                //-----------------------------------

                projects.sort((a, b) {

                  if (_sortNewest) {
                    return b.createdAt.compareTo(
                      a.createdAt,
                    );
                  }

                  return a.createdAt.compareTo(
                    b.createdAt,
                  );

                });

                //-----------------------------------
                // EMPTY STATE
                //-----------------------------------

                if (projects.isEmpty) {
                  return const Center(
                    child: Text(
                      "No projects found.",
                    ),
                  );
                }

                //-----------------------------------
                // PROJECT LIST
                //-----------------------------------

                return ListView.builder(
                  padding: const EdgeInsets.all(16),

                  itemCount: projects.length,

                  itemBuilder: (context, index) {

                    final project =
                        projects[index];

                    return ProjectCard(
                      project: project,

                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProjectDetailsScreen(
                              project: project,
                            ),
                          ),
                        );

                      },

                      onDelete: () async {

                        final confirm =
                            await showDialog<bool>(
                          context: context,

                          builder: (_) =>
                              AlertDialog(
                            title: const Text(
                              "Delete Project",
                            ),

                            content: const Text(
                              "Are you sure you want to delete this project?",
                            ),

                            actions: [

                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(
                                  context,
                                  false,
                                ),
                                child: const Text(
                                  "Cancel",
                                ),
                              ),

                              FilledButton(
                                onPressed: () =>
                                    Navigator.pop(
                                  context,
                                  true,
                                ),
                                child: const Text(
                                  "Delete",
                                ),
                              ),

                            ],
                          ),
                        );

                        if (confirm == true) {

                          await _projectService
                              .deleteProject(
                            project.id,
                          );

                          setState(() {
                            _projectsFuture =
                                _projectService
                                    .getProjects();
                          });

                        }

                      },
                    );

                  },
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}