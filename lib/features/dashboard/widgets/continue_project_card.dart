import 'package:flutter/material.dart';

import '../../projects/models/project_model.dart';

class ContinueProjectCard extends StatelessWidget {

  final ProjectModel? project;

  final VoidCallback onContinue;

  final VoidCallback onCreate;

  const ContinueProjectCard({

    super.key,

    required this.project,

    required this.onContinue,

    required this.onCreate,

  });

  @override
  Widget build(BuildContext context) {

    //--------------------------------------------------
    // NO PROJECT
    //--------------------------------------------------

    if (project == null) {

      return Card(

        elevation: 0,

        shape: RoundedRectangleBorder(

          borderRadius:
              BorderRadius.circular(20),

        ),

        child: Padding(

          padding:
              const EdgeInsets.all(24),

          child: Column(

            children: [

              const Icon(

                Icons.movie_creation_outlined,

                size: 60,

              ),

              const SizedBox(height: 20),

              const Text(

                "No Recent Project",

                style: TextStyle(

                  fontSize: 20,

                  fontWeight: FontWeight.bold,

                ),

              ),

              const SizedBox(height: 10),

              Text(

                "Create your first AI animation.",

                style: TextStyle(

                  color:
                      Colors.grey.shade600,

                ),

              ),

              const SizedBox(height: 20),

              FilledButton.icon(

                onPressed: onCreate,

                icon:
                    const Icon(Icons.add),

                label:
                    const Text("New Project"),

              ),

            ],

          ),

        ),

      );

    }

    //--------------------------------------------------
    // PROJECT EXISTS
    //--------------------------------------------------

    return Card(

      elevation: 0,

      clipBehavior: Clip.antiAlias,

      shape: RoundedRectangleBorder(

        borderRadius:
            BorderRadius.circular(20),

      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          //--------------------------------------------------
          // THUMBNAIL
          //--------------------------------------------------

          SizedBox(

            height: 220,

            width: double.infinity,

            child: project!.thumbnail.isEmpty

                ? Container(

                    color: Colors.grey.shade200,

                    child: const Center(

                      child: Icon(

                        Icons.movie_creation,

                        size: 60,

                      ),

                    ),

                  )

                : Image.network(

                    project!.thumbnail,

                    fit: BoxFit.cover,

                  ),

          ),

          //--------------------------------------------------
          // CONTENT
          //--------------------------------------------------

          Padding(

            padding:
                const EdgeInsets.all(20),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(

                  project!.title,

                  style:
                      const TextStyle(

                    fontSize: 20,

                    fontWeight:
                        FontWeight.bold,

                  ),

                ),

                const SizedBox(height: 8),

                Text(

                  project!.status,

                  style: TextStyle(

                    color:
                        Colors.grey.shade600,

                  ),

                ),

                const SizedBox(height: 18),

                LinearProgressIndicator(

                  value: project!.progress,

                  minHeight: 8,

                  borderRadius:
                      BorderRadius.circular(8),

                ),

                const SizedBox(height: 12),

                Text(

                  "${(project!.progress * 100).toInt()}% Complete",

                ),

                const SizedBox(height: 20),

                SizedBox(

                  width: double.infinity,

                  child: FilledButton.icon(

                    onPressed: onContinue,

                    icon: const Icon(

                      Icons.play_arrow,

                    ),

                    label: const Text(

                      "Continue Project",

                    ),

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

}