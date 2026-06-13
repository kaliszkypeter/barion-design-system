export const config = { runtime: "edge" };

export default async function handler(req) {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  const body = await req.text();
  let payload;
  try {
    payload = JSON.parse(body);
  } catch {
    return new Response("Bad Request", { status: 400 });
  }

  // Figma sends the passcode in the payload, not as an HMAC header.
  // Validate it against the secret stored in Vercel env vars.
  const secret = process.env.FIGMA_WEBHOOK_SECRET;
  if (!secret || payload.passcode !== secret) {
    return new Response("Unauthorized", { status: 401 });
  }

  const ghPat = process.env.GH_PAT;
  if (!ghPat) {
    return new Response("Server misconfigured", { status: 500 });
  }

  const dispatchRes = await fetch(
    "https://api.github.com/repos/kaliszkypeter/barion-design-system/dispatches",
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${ghPat}`,
        Accept: "application/vnd.github+json",
        "Content-Type": "application/json",
        "X-GitHub-Api-Version": "2022-11-28",
      },
      body: JSON.stringify({
        event_type: "figma-library-publish",
        client_payload: {
          figma_event: payload.event_type,
          file_key: payload.file_key,
          timestamp: payload.timestamp ?? new Date().toISOString(),
          description: payload.description ?? "",
          triggered_by: payload.triggered_by?.name ?? "unknown",
        },
      }),
    }
  );

  if (!dispatchRes.ok) {
    const err = await dispatchRes.text();
    console.error("GitHub dispatch failed:", err);
    return new Response("Failed to dispatch", { status: 502 });
  }

  return new Response("OK", { status: 200 });
}
