import 'package:flutter/material.dart';

class DashboardStatistics extends StatelessWidget {

  final int total;

  final int completed;

  final int rendering;

  final int draft;

  const DashboardStatistics({

    super.key,

    required this.total,

    required this.completed,

    required this.rendering,

    required this.draft,

  });

  @override
  Widget build(BuildContext context) {

    return GridView.count(

      crossAxisCount: 2,

      shrinkWrap: true,

      physics:
          const NeverScrollableScrollPhysics(),

      crossAxisSpacing: 12,

      mainAxisSpacing: 12,

      childAspectRatio: 1.55,

      children: [

        _card(

          context,

          "Projects",

          total.toString(),

          Icons.folder_open,

          Colors.blue,

        ),

        _card(

          context,

          "Completed",

          completed.toString(),

          Icons.check_circle,

          Colors.green,

        ),

        _card(

          context,

          "Rendering",

          rendering.toString(),

          Icons.movie_creation,

          Colors.orange,

        ),

        _card(

          context,

          "Drafts",

          draft.toString(),

          Icons.edit,

          Colors.deepPurple,

        ),

      ],

    );

  }

  Widget _card(

    BuildContext context,

    String title,

    String value,

    IconData icon,

    Color color,

  ) {

    return Card(

      elevation: 0,

      shape: RoundedRectangleBorder(

        borderRadius:
            BorderRadius.circular(18),

      ),

      child: Padding(

        padding:
            const EdgeInsets.all(18),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            CircleAvatar(

              radius: 18,

              backgroundColor:
                  color.withOpacity(.12),

              child: Icon(

                icon,

                color: color,

              ),

            ),

            const Spacer(),

            Text(

              value,

              style:
                  const TextStyle(

                fontSize: 24,

                fontWeight:
                    FontWeight.bold,

              ),

            ),

            const SizedBox(height: 4),

            Text(

              title,

              style: TextStyle(

                color:
                    Colors.grey.shade600,

              ),

            ),

          ],

        ),

      ),

    );

  }

}