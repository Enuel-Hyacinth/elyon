import 'package:supabase_flutter/supabase_flutter.dart';

import 'ai_service.dart';
import 'models/runway_job.dart';

class RunwayService implements AIService {
  RunwayService();

  final SupabaseClient _supabase =
      Supabase.instance.client;

  //--------------------------------------------------
  // EDGE FUNCTION
  //--------------------------------------------------

  static const String _functionName =
      "generate-video";

  //--------------------------------------------------
  // PRIVATE INVOKER
  //--------------------------------------------------

  Future<Map<String, dynamic>> _invoke(
    Map<String, dynamic> body,
  ) async {

    final response =
        await _supabase.functions.invoke(

      _functionName,

      body: body,

    );

    if (response.data == null) {

      throw Exception(
        "No response returned from Runway.",
      );

    }

    if (response.data is! Map<String, dynamic>) {

      throw Exception(
        "Invalid response received.",
      );

    }

    return response.data
        as Map<String, dynamic>;

  }

  //--------------------------------------------------
  // PROMPT ENHANCEMENT
  //--------------------------------------------------

  @override
  Future<String> enhancePrompt(
    String prompt,
  ) async {

    final result =
        await _invoke({

      "action": "enhance",

      "prompt": prompt,

    });

    return result["prompt"];

  }

  //--------------------------------------------------
  // REWRITE PROMPT
  //--------------------------------------------------

  @override
  Future<String> rewritePrompt(
    String prompt,
  ) async {

    final result =
        await _invoke({

      "action": "rewrite",

      "prompt": prompt,

    });

    return result["prompt"];

  }

  //--------------------------------------------------
  // STORYBOARD
  //--------------------------------------------------

  @override
  Future<List<String>>
      generateStoryboard(
    String prompt,
  ) async {

    final result =
        await _invoke({

      "action": "storyboard",

      "prompt": prompt,

    });

    return List<String>.from(

      result["storyboard"],

    );

  }

  //--------------------------------------------------
  // SCRIPT
  //--------------------------------------------------

  @override
  Future<String> generateScript(
    String prompt,
  ) async {

    final result =
        await _invoke({

      "action": "script",

      "prompt": prompt,

    });

    return result["script"];

  }

  //--------------------------------------------------
  // TITLE
  //--------------------------------------------------

  @override
  Future<String> generateTitle(
    String prompt,
  ) async {

    final result =
        await _invoke({

      "action": "title",

      "prompt": prompt,

    });

    return result["title"];

  }

  //--------------------------------------------------
  // THUMBNAIL
  //--------------------------------------------------

  @override
  Future<String>
      generateThumbnail(
    String prompt,
  ) async {

    final result =
        await _invoke({

      "action": "thumbnail",

      "prompt": prompt,

    });

    return result["thumbnail"];

  }

 //--------------------------------------------------
// VIDEO GENERATION
//--------------------------------------------------

@override
Future<String> generateMovie({
  required String prompt,
  required String style,
  required String language,
  required String voice,
  required String resolution,
  required String aspectRatio,
  required String duration,
}) async {
  final result = await _invoke({
    "action": "generate",
    "prompt": prompt,
    "style": style,
    "language": language,
    "voice": voice,
    "resolution": resolution,
    "aspectRatio": aspectRatio,
    "duration": duration,
  });

  print("Runway response: $result");

  return result["jobId"];
}
//--------------------------------------------------
// GET JOB
//--------------------------------------------------

@override
Future<RunwayJob> getJob(

  String jobId,

) async {

  final result = await _invoke({

    "action": "status",

    "jobId": jobId,

  });

  return RunwayJob.fromMap(result);

}

//--------------------------------------------------
// GET VIDEO URL
//--------------------------------------------------

@override
Future<String> getVideoUrl(

  String jobId,

) async {

  final job = await getJob(jobId);

  return job.videoUrl ?? "";

}

}