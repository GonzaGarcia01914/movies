// index.js (Cloud Functions v2)
const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");

const TMDB_V3_KEY = defineSecret("TMDB_V3_KEY");

exports.tmdbProxy = onRequest(
    {
        region: "us-central1",
        // CORS sencillo (si quieres algo más cerrado, pon tu dominio)
        cors: ["*"],
        secrets: [TMDB_V3_KEY],
    },
    async (req, res) => {
        // Preflight (por si tu front hace OPTIONS)
        if (req.method === "OPTIONS") return res.status(204).send("");

        try {
            const apiKey = TMDB_V3_KEY.value(); // ← aquí está tu key
            if (!apiKey) {
                console.error("Missing secret TMDB_V3_KEY");
                return res.status(500).json({ error: "Secret TMDB_V3_KEY not set" });
            }

            const path = req.path || "/";
            const url = new URL(`https://api.themoviedb.org/3${path}`);

            for (const [k, v] of Object.entries(req.query || {})) {
                if (typeof v === "string") url.searchParams.set(k, v);
            }
            url.searchParams.set("api_key", apiKey);

            console.log("→ TMDb request:", url.toString());
            const r = await fetch(url, { headers: { Accept: "application/json" } });
            const bodyText = await r.text();

            console.log("← TMDb response:", r.status);
            if (!r.ok) console.error("TMDb error body:", bodyText?.slice(0, 600));

            res.set("Content-Type", r.headers.get("content-type") || "application/json; charset=utf-8");
            const retryAfter = r.headers.get("retry-after");
            if (retryAfter) res.set("Retry-After", retryAfter);

            return res.status(r.status).send(bodyText);
        } catch (e) {
            console.error("Proxy fatal error:", e);
            return res.status(502).json({
                error: "Upstream/Network error",
                name: e?.name,
                message: e?.message,
                cause: e?.cause?.code || e?.code || null,
            });
        }
    }
);
