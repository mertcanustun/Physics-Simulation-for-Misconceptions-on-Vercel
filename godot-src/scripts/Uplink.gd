class_name Uplink
## OPSIYONEL sunucu kopyasi (Vercel serverless fonksiyonu: /api/collect).
##
## NE ISE YARAR: DataLog (deneme ozeti CSV) ve Telemetry (etkilesim JSONL)
## verisi her zaman oncelikle TARAYICIDA saklanir (IndexedDB). Katilimcinin
## cihazi silinirse / tarayici verisi temizlenirse o veri kaybolur. Bu sinif,
## AYNI veriyi bir de sunucuya gonderir; boylece ikinci bir kopya olusur.
##
## TAMAMEN "ATES ET VE UNUT": internet yoksa, endpoint kapaliysa veya sunucu
## hata dondururse simulasyon HIC ETKILENMEZ (hata yutulur, kullaniciya bir sey
## gosterilmez). Masaustu surumunde hicbir sey yapmaz.
##
## KAPATMAK ICIN: public/index.html icindeki  window.__KB_UPLINK = false;
## satirini kullanin (kod degistirmeye gerek yok) veya Vercel'de
## DATA_WEBHOOK_URL ortam degiskenini bos birakin (fonksiyon veriyi hicbir yere
## yazmaz, 200 doner).
##
## GIZLILIK: sadece yonetici o kod icin veri toplamayi ACTIYSA cagrilir
## (DataLog / Telemetry ile ayni kural). Isim/kimlik gonderilmez, yalnizca
## anonim katilimci kodu.

const ENDPOINT := "/api/collect"

## kind: "attempt" (tek deneme ozeti) veya "events" (telemetri olay yigini).
static func post(kind: String, payload: Variant) -> void:
	if not OS.has_feature("web"):
		return
	var body := JSON.stringify({"kind": kind, "sent_at_ms": Time.get_unix_time_from_system() * 1000.0, "data": payload})
	var js := """
	(function(body){
		try {
			if (typeof window !== 'undefined' && window.__KB_UPLINK === false) { return; }
			fetch(%s, {
				method: 'POST',
				headers: {'Content-Type': 'application/json'},
				body: body,
				keepalive: true
			}).catch(function(){});
		} catch (e) {}
	})(%s);
	""" % [JSON.stringify(ENDPOINT), JSON.stringify(body)]
	JavaScriptBridge.eval(js, true)
