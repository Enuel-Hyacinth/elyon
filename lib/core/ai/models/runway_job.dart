class RunwayJob {
  final String id;

  final String status;

  final String? videoUrl;

  final String? thumbnailUrl;

  const RunwayJob({
    required this.id,
    required this.status,
    this.videoUrl,
    this.thumbnailUrl,
  });

  //--------------------------------------------------
  // FROM MAP
  //--------------------------------------------------

  factory RunwayJob.fromMap(
    Map<String, dynamic> map,
  ) {
    return RunwayJob(
      id: map["id"] ?? "",
      status: map["status"] ?? "PENDING",
      videoUrl: map["videoUrl"],
      thumbnailUrl: map["thumbnailUrl"],
    );
  }

  //--------------------------------------------------
  // TO MAP
  //--------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "status": status,
      "videoUrl": videoUrl,
      "thumbnailUrl": thumbnailUrl,
    };
  }

  //--------------------------------------------------
  // HELPERS
  //--------------------------------------------------

  bool get isCompleted =>
      status.toUpperCase() == "SUCCEEDED";

  bool get isFailed =>
      status.toUpperCase() == "FAILED";

  bool get isRunning =>
      status.toUpperCase() == "RUNNING";

  bool get isPending =>
      status.toUpperCase() == "PENDING";
}