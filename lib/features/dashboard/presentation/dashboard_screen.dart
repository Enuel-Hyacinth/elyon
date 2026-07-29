import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/dashboard_controller.dart';

import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_statistics.dart';
import '../widgets/activity_feed.dart';

import '../widgets/credit_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/continue_project_card.dart';
import '../widgets/recent_projects.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {

    
  
  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              title: const Text("eLyon"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: controller.refresh,
                ),
              ],
            ),

            body: RefreshIndicator(
              onRefresh: () async {
                await controller.refresh();
              },
              child: controller.loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : SingleChildScrollView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          DashboardHeader(
                            userName: controller.userName,
                          ),

                          const SizedBox(height: 24),

                          CreditCard(

  credits: controller.credits,

  plan: controller.plan,

  onUpgrade: () {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(

        content: Text(
          "Subscriptions coming soon.",
        ),

      ),

    );

  },

),

                          const SizedBox(height: 24),

                              DashboardStatistics(

                          total:
                              controller.totalProjects,

                          completed:
                              controller.completedProjects,

                          rendering:
                              controller.renderingProjects,

                          draft:
                              controller.draftProjects,

                          ),

                          

                          QuickActions(
                            onAnimation: () {
                              Navigator.pushNamed(
                                context,
                                "/generate",
                              );
                            },

                            onImage: () {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Image Studio coming soon.",
                                  ),
                                ),
                              );
                            },

                            onVoice: () {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Voice Studio coming soon.",
                                  ),
                                ),
                              );
                            },

                            onDirector: () {
                              Navigator.pushNamed(
                                context,
                                "/ai-director",
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          ContinueProjectCard(
                            project: controller.continueProject,

                            onContinue: () {
                              controller.selectProject(
                                controller.continueProject!,
                              );

                              Navigator.pushNamed(
                                context,
                                 "/studio",
                                );
                              },

                            onCreate: () {
                              controller.clearSelection();
                                Navigator.pushNamed(
                                context,
                                "/studio",
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          RecentProjects(
                            projects: controller.recentProjects,

                            onTap: (project) {
                              Navigator.pushNamed(
                                context,
                                "/studio",
                              );
                            },
                          ),


                          const SizedBox(height: 28),

                            const Text(
                              "Recent Activity",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          const SizedBox(height: 16),

                            ActivityFeed(

                             projects:
                              controller.recentProjects,

                            ),
                        ],
                      ),
                    ),
            ),
          );
        },
      );    
  }
}