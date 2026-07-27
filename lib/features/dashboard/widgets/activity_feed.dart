import 'package:flutter/material.dart';

import '../../projects/models/project_model.dart';

class ActivityFeed extends StatelessWidget {

  final List<ProjectModel> projects;

  const ActivityFeed({

    super.key,

    required this.projects,

  });

  @override
  Widget build(BuildContext context) {

    if (projects.isEmpty) {

      return Card(

        elevation: 0,

        shape: RoundedRectangleBorder(

          borderRadius:
              BorderRadius.circular(18),

        ),

        child: const Padding(

          padding: EdgeInsets.all(24),

          child: Center(

            child: Text(

              "No recent activity",

            ),

          ),

        ),

      );

    }

    return Card(

      elevation: 0,

      shape: RoundedRectangleBorder(

        borderRadius:
            BorderRadius.circular(18),

      ),

      child: ListView.separated(

        shrinkWrap: true,

        physics:
            const NeverScrollableScrollPhysics(),

        itemCount: projects.length,

        separatorBuilder: (_, __) =>
            const Divider(height: 1),

        itemBuilder: (context, index) {

          final project =
              projects[index];

          return ListTile(

            leading: CircleAvatar(

              child: Icon(

                _icon(project.status),

              ),

            ),

            title: Text(

              project.title,

              maxLines: 1,

              overflow:
                  TextOverflow.ellipsis,

            ),

            subtitle: Text(

              project.status,

            ),

            trailing: Text(

              "${(project.progress * 100).toInt()}%",

            ),

          );

        },

      ),

    );

  }

  IconData _icon(String status) {

    switch (status) {

      case "Completed":

        return Icons.check_circle;

      case "Rendering":

        return Icons.movie_creation;

      case "Queued":

        return Icons.schedule;

      case "Failed":

        return Icons.error;

      default:

        return Icons.folder;

    }

  }

}