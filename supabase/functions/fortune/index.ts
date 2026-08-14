// Fortune proxy — keeps the OpenAI key server-side.
// Deploy: supabase functions deploy fortune --no-verify-jwt
// Secrets: supabase secrets set OPENAI_API_KEY=... AUTH_SECRET_TOKEN=...
//
// The app sends the same chat-completions payload it previously sent to
// OpenAI directly, authenticated with AUTH_SECRET_TOKEN (see assets/.env).

const OPENAI_URL = "https://api.openai.com/v1/chat/completions";
const ALLOWED_MODELS = new Set(["gpt-4o-mini"]);
const MAX_TOKENS_CAP = 1200;

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const auth = req.headers.get("Authorization") ?? "";
  const token = Deno.env.get("AUTH_SECRET_TOKEN");
  if (!token || auth !== `Bearer ${token}`) {
    return new Response("Unauthorized", { status: 401 });
  }

  let body: {
    model?: string;
    messages?: unknown;
    temperature?: number;
    max_tokens?: number;
  };
  try {
    body = await req.json();
  } catch {
    return new Response("Invalid JSON", { status: 400 });
  }

  if (!Array.isArray(body.messages) || body.messages.length === 0) {
    return new Response("messages required", { status: 400 });
  }

  const upstream = await fetch(OPENAI_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${Deno.env.get("OPENAI_API_KEY")}`,
    },
    body: JSON.stringify({
      model: ALLOWED_MODELS.has(body.model ?? "") ? body.model : "gpt-4o-mini",
      messages: body.messages,
      temperature: Math.min(Math.max(body.temperature ?? 0.7, 0), 1),
      max_tokens: Math.min(body.max_tokens ?? 1000, MAX_TOKENS_CAP),
    }),
  });

  return new Response(upstream.body, {
    status: upstream.status,
    headers: { "Content-Type": "application/json" },
  });
});
