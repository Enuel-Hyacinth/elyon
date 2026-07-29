import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";

const RUNWAY_API_KEY = Deno.env.get("RUNWAY_API_KEY")!;

export default {
  fetch: withSupabase(
    {
      auth: ["publishable", "secret"],
    },
    async (req) => {
      try {
        //----------------------------------------------------------
        // READ REQUEST
        //----------------------------------------------------------

        const body = await req.json();

        //----------------------------------------------------------
        // CORS HEADERS
        //----------------------------------------------------------

        const headers = {
          "Access-Control-Allow-Origin": "*",
          "Content-Type": "application/json",
        };

        //----------------------------------------------------------
        // ACTION SWITCH
        //----------------------------------------------------------

        switch (body.action) {
          //--------------------------------------------------------
          // GENERATE VIDEO
          //--------------------------------------------------------

          case "generate": {
            const runwayResponse = await fetch(
              "https://api.dev.runwayml.com/v1/image_to_video",
              {
                method: "POST",
                headers: {
                  Authorization: `Bearer ${RUNWAY_API_KEY}`,
                  "Content-Type": "application/json",
                  "X-Runway-Version": "2024-11-06",
                },
                body: JSON.stringify({
                  promptText: body.prompt,
                  duration: Number(body.duration),
                  ratio: body.aspectRatio,
                  resolution: body.resolution,
                }),
              },
            );

            const json = await runwayResponse.json();

            console.log(json);

            if (!runwayResponse.ok) {
              return Response.json(
                {
                  success: false,
                  error: json,
                },
                {
                  status: runwayResponse.status,
                  headers,
                },
              );
            }

            return Response.json(
              {
                success: true,
                jobId: json.id,
                raw: json,
              },
              {
                headers,
              },
            );
          }

          //--------------------------------------------------------
          // ENHANCE PROMPT
          //--------------------------------------------------------

          case "enhance":
            return Response.json(
              {
                prompt:
                  body.prompt +
                  ", cinematic lighting, volumetric fog, ultra realistic, award-winning composition",
              },
              {
                headers,
              },
            );

          //--------------------------------------------------------
          // REWRITE
          //--------------------------------------------------------

          case "rewrite":
            return Response.json(
              {
                prompt: `Rewrite professionally:\n\n${body.prompt}`,
              },
              {
                headers,
              },
            );

          //--------------------------------------------------------
          // SCRIPT
          //--------------------------------------------------------

          case "script":
            return Response.json(
              {
                script: `Narrator:\n\n${body.prompt}`,
              },
              {
                headers,
              },
            );

          //--------------------------------------------------------
          // TITLE
          //--------------------------------------------------------

          case "title":
            return Response.json(
              {
                title: "Untitled AI Project",
              },
              {
                headers,
              },
            );

          //--------------------------------------------------------
          // STORYBOARD
          //--------------------------------------------------------

          case "storyboard":
            return Response.json(
              {
                storyboard: [
                  "Opening Scene",
                  "Conflict",
                  "Climax",
                  "Ending",
                ],
              },
              {
                headers,
              },
            );

          //--------------------------------------------------------
          // THUMBNAIL
          //--------------------------------------------------------

          case "thumbnail":
            return Response.json(
              {
                thumbnail: "",
              },
              {
                headers,
              },
            );

          //--------------------------------------------------------
          // UNKNOWN
          //--------------------------------------------------------

          default:
            return Response.json(
              {
                success: false,
                error: "Unknown action",
              },
              {
                status: 400,
                headers,
              },
            );
        }
      } catch (error) {
        return Response.json(
          {
            success: false,
            error: error instanceof Error ? error.message : String(error),
          },
          {
            status: 500,
            headers: {
              "Access-Control-Allow-Origin": "*",
              "Content-Type": "application/json",
            },
          },
        );
      }
    },
  ),
};