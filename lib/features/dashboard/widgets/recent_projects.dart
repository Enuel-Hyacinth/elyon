import 'package:flutter/material.dart';

import '../../projects/models/project_model.dart';

class RecentProjects extends StatelessWidget {
  final List<ProjectModel> projects;

  final ValueChanged<ProjectModel>? onTap;

  const RecentProjects({
    super.key,
    required this.projects,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              "No recent projects yet.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Projects",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: projects.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: 12),

          itemBuilder: (context, index) {
            final project = projects[index];

            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onTap?.call(project),

              child: Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(18),

                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),

                child: Row(
                  children: [

                    CircleAvatar(
                      radius: 26,
                      backgroundColor:
                          Colors.indigo.shade50,

                      child: const Icon(
                        Icons.movie_creation_outlined,
                        color: Colors.indigo,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          Text(
                            project.title,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            project.status,
                            style: TextStyle(
                              color: _statusColor(
                                project.status,
                              ),
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 8),

                          LinearProgressIndicator(
                            value:
                                project.progress / 100,
                            minHeight: 6,
                            borderRadius:
                                BorderRadius.circular(
                                    12),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Icon(
                      Icons.chevron_right,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );      
  }

  //--------------------------------------------------
  // STATUS COLOR
  //--------------------------------------------------

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "completed":
        return Colors.green;

      case "rendering":
        return Colors.orange;

      case "queued":
        return Colors.blue;

      case "failed":
        return Colors.red;

      case "created":
        return Colors.deepPurple;

      default:
        return Colors.grey;
    }
  }
}