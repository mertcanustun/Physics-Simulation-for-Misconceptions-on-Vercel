// ---------------------------------------------------------------------------
// /api/collect - OPSIYONEL veri toplama ucu (Vercel Serverless Function)
// ---------------------------------------------------------------------------
// Simulasyon verisi HER ZAMAN once katilimcinin tarayicisinda saklanir
// (IndexedDB) ve yonetici F10 / F8 ile CSV / JSONL olarak indirir. Bu fonksiyon
// ISTEGE BAGLI ikinci bir kopya olusturur: cihaz silinse bile veri kalir.
//
// KURULUM (Vercel -> Project -> Settings -> Environment Variables):
//   DATA_WEBHOOK_URL   Verinin POST edilecegi adres. Ornekler:
//                        - Google Apps Script web app (Sheets'e yazar)
//                        - Airtable / Supabase / kendi sunucunuz
//                        - webhook.site (yalnizca deneme icin)
//   DATA_WEBHOOK_TOKEN (istege bagli) Varsa istege
//                        "Authorization: Bearer <token>" basligi eklenir.
//
// DATA_WEBHOOK_URL TANIMLI DEGILSE: fonksiyon 200 ve {"stored": false} doner,
// hicbir yere yazmaz. Simulasyon bundan etkilenmez; her sey eskisi gibi calisir.
//
// Gelen govde:
//   { "kind": "attempt" | "events", "sent_at_ms": <number>, "data": ... }
//     kind = "attempt" -> data: tek bir deneme ozeti (DataLog CSV satirinin
//                         alan alan JSON karsiligi)
//     kind = "events"  -> data: telemetri olaylari dizisi (JSONL satirlari)
//
// GIZLILIK: yalnizca yonetici o kod icin veri toplamayi actiysa istek gelir.
// Isim, e-posta, IP gibi kimlik bilgisi TASINMAZ; yalnizca anonim katilimci
// kodu ve etkilesim verisi gonderilir.
// ---------------------------------------------------------------------------

const MAX_BODY_BYTES = 1024 * 1024; // 1 MB - kotu niyetli buyuk govdeye karsi

module.exports = async function handler(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");
  res.setHeader("Cache-Control", "no-store");

  if (req.method === "OPTIONS") {
    res.status(204).end();
    return;
  }
  if (req.method !== "POST") {
    res.status(405).json({ ok: false, error: "yalnizca POST" });
    return;
  }

  let body = req.body;
  if (typeof body === "string") {
    if (body.length > MAX_BODY_BYTES) {
      res.status(413).json({ ok: false, error: "govde cok buyuk" });
      return;
    }
    try {
      body = JSON.parse(body);
    } catch (e) {
      res.status(400).json({ ok: false, error: "gecersiz JSON" });
      return;
    }
  }
  if (!body || typeof body !== "object") {
    res.status(400).json({ ok: false, error: "bos govde" });
    return;
  }

  const kind = body.kind === "attempt" || body.kind === "events" ? body.kind : "unknown";
  const count = Array.isArray(body.data) ? body.data.length : 1;

  const target = process.env.DATA_WEBHOOK_URL;
  if (!target) {
    // Depolama saglayicisi henuz tanimlanmadi: veriyi sessizce dusur ama
    // istemciye basarili don ki simulasyon hicbir sekilde etkilenmesin.
    res.status(200).json({ ok: true, stored: false, kind, count });
    return;
  }

  const headers = { "Content-Type": "application/json" };
  if (process.env.DATA_WEBHOOK_TOKEN) {
    headers.Authorization = "Bearer " + process.env.DATA_WEBHOOK_TOKEN;
  }

  try {
    const upstream = await fetch(target, {
      method: "POST",
      headers,
      body: JSON.stringify({
        kind,
        count,
        received_at: new Date().toISOString(),
        sent_at_ms: body.sent_at_ms || null,
        data: body.data,
      }),
    });
    res.status(200).json({ ok: true, stored: upstream.ok, kind, count, upstream: upstream.status });
  } catch (e) {
    // Yukari akis erisilemezse bile istemciye hata dondurmuyoruz: yerel kayit
    // asil kayittir, katilimci deneyimi bozulmamalidir.
    res.status(200).json({ ok: true, stored: false, kind, count, error: "upstream erisilemedi" });
  }
};
