# Kicked-Ball Simulation - Vercel dağıtımı

Kuvvet ve hareket kavram yanılgısı simülasyonunun (Simülasyon 1) web sürümü.
Bu depo, Vercel'e olduğu gibi bağlanıp yayınlanacak biçimde düzenlenmiştir:
**derleme adımı yoktur**, Vercel yalnızca `public/` klasörünü statik olarak
servis eder ve `api/` altındaki fonksiyonu çalıştırır.

Godot projesinin kendisi `godot-src/` altında korunmuştur; hiçbir işlevi
kaldırılmadı, yalnızca web dağıtımı ve isteğe bağlı sunucu kaydı eklendi.

---

## 1. Depo yapısı

    .
    +-- public/          Yayinlanan dosyalar (Godot Web disa aktarimi)
    |   +-- index.html   Turkce kabuk (lang="tr"), uplink anahtari burada
    |   +-- index.js     Godot motor yukleyicisi
    |   +-- index.wasm   Motor (WebAssembly, ~37 MB)
    |   +-- index.pck    Oyun verisi (sahne, script, gorsel, ses, metin)
    |   +-- index*.png   Ikon ve acilis gorseli
    +-- api/
    |   +-- collect.js   ISTEGE BAGLI veri toplama ucu (serverless)
    +-- godot-src/       Godot 4.6 kaynak projesi (duzenlenebilir)
    +-- vercel.json      Cikti klasoru + MIME/basliklar
    +-- build.sh         Kaynaktan public/ uretir
    +-- .gitignore

Vercel'in derleme yapmadığına dikkat edin: `public/` klasörü **depoya
işlenmelidir**. `.gitignore` bunu açıkça korur.

---

## 2. Vercel'e dağıtım

1. Bu klasörü bir GitHub (veya GitLab/Bitbucket) deposuna yükleyin.
2. vercel.com -> **Add New** -> **Project** -> depoyu **Import** edin.
3. Ayarlar (Vercel bunları `vercel.json`dan zaten okur, elle değiştirmeyin):
   - Framework Preset: **Other**
   - Build Command: **boş**
   - Output Directory: **public**
4. **Deploy**. Bir dakika içinde adres hazır olur.

Alternatif olarak yerelden:

    npm i -g vercel
    vercel --prod

### `vercel.json` ne yapıyor?

- `outputDirectory: public` - yayınlanacak klasör.
- `.wasm` -> `application/wasm`. Bazı CDN'ler yanlış tip döndürür ve
  WebAssembly streaming derlemesi bozulur; bu başlık onu garantiye alır.
- `.pck` -> `application/octet-stream`.
- `Cross-Origin-Opener-Policy: same-origin` +
  `Cross-Origin-Embedder-Policy: require-corp`. Mevcut build **thread'siz**
  (`variant/thread_support=false`) olduğu için ZORUNLU değil, ama zararsız
  (tüm varlıklar aynı origin'de) ve ileride `thread_support=true` yapılırsa
  SharedArrayBuffer için şart. Şimdiden konuldu ki sürüm değişiminde "sayfa
  neden açılmıyor" aranmasın.
- `index.wasm` / `index.pck` için uzun önbellek, `index.html` için önbelleksiz:
  yeni dağıtımda katılımcı eski sürümü görmez.

---

## 3. Veri toplama

Kural değişmedi: **yalnızca yönetici o kod için veri toplamayı açtıysa** kayıt
yapılır; aksi hâlde simülasyon "deneme modu"nda çalışır ve hiçbir şey yazılmaz.

### 3.1. Tarayıcı kaydı (asıl kayıt, her zaman açık)

Web sürümünde Godot'un `user://` alanı tarayıcının kalıcı IndexedDB deposudur.

- `session_log.csv` - deneme başına 1 özet satır (DataLog)
- `events_log.jsonl` - etkileşim olayları: hover, dwell, işaretleme sırası,
  mouse yolu, tıklamalar (Telemetry)

Yönetici kısayolları (katılımcı cihazında, simülasyon açıkken):

| Tuş | İşlev |
|-----|-------|
| F8  | Etkileşim verisini (JSONL) indir |
| F9  | Veri durumu: kaç kayıt, nereye yazılıyor, son kayıtlar |
| F10 | Deneme özeti CSV'sini indir |
| F11 | Tam ekran aç/kapa |

Bu veriler o tarayıcıya bağlıdır: tarayıcı verisi temizlenirse veya cihaz
silinirse kaybolur. İkinci kopya için aşağıdaki bölüm eklendi.

### 3.2. Sunucu kopyası (isteğe bağlı, kapalı gelir)

Her resmi deneme özeti ve telemetri olayları, aynı anda `/api/collect`
adresine de gönderilir (25 olayda bir yığın hâlinde; deneme bitiminde ve
oturum kapanışında ayrıca boşaltılır). Gönderim **ateş et ve unut**tur:
internet yoksa, uç kapalıysa veya sunucu hata dönerse simülasyon hiç
etkilenmez, yerel kayıt yine yazılır.

Varsayılan olarak `api/collect.js` hiçbir yere yazmaz ve `{"stored": false}`
döner. Kalıcı depolama için Vercel'de iki ortam değişkeni tanımlayın
(Project -> Settings -> Environment Variables):

| Değişken | Zorunlu | Açıklama |
|----------|---------|----------|
| `DATA_WEBHOOK_URL`   | evet | Verinin POST edileceği adres: Google Apps Script (Sheets'e yazar), Supabase, Airtable veya kendi sunucunuz |
| `DATA_WEBHOOK_TOKEN` | hayır | Varsa isteğe `Authorization: Bearer <token>` başlığı eklenir |

Uca giden gövde:

    { "kind": "attempt" | "events",
      "count": <adet>,
      "received_at": "<ISO 8601>",
      "data": { ... } | [ ... ] }

`kind = "attempt"` içeriği DataLog CSV satırının alan alan JSON karşılığıdır
(aynı sütun adları), `kind = "events"` ise JSONL satırlarının dizisidir.
İkisi `session_id`/`sid` + `participant_code`/`code` + `attempt` üzerinden
birleştirilebilir.

Sunucu kopyasını tamamen kapatmak isterseniz kod değiştirmeye gerek yok:
`godot-src/web/shell.html` içindeki satırı

    window.__KB_UPLINK = false;

yapıp yeniden build alın; ya da `DATA_WEBHOOK_URL`i tanımsız bırakın (istek
gider ama hiçbir yere yazılmaz).

Gizlilik: isim, e-posta gibi kimlik bilgisi gönderilmez; yalnızca anonim
katılımcı kodu, grup etiketi ve etkileşim verisi taşınır.

---

## 4. Kaynakta değişiklik yapıp yeniden yayınlama

Sayısal ayarlar `godot-src/config/sim_config.tres` (Godot Inspector'dan, kod
yazmadan), metinler `godot-src/localization/strings.csv` (Excel/Sheets ile)
üzerinden düzenlenir. Ayrıntı: `godot-src/GELISTIRME-REHBERI.md`.

Değişiklikten sonra:

    GODOT=/yol/Godot_v4.6-stable_linux.x86_64 ./build.sh
    git add public godot-src && git commit -m "..." && git push

`build.sh` sırasıyla: içe aktarma -> metinleri pişirme -> başsız duman testi
-> `public/` klasörüne Web dışa aktarımı yapar. Duman testi başarısız olursa
build durur, bozuk sürüm yayına gitmez.

Yeni dağıtım yaptığınızda `godot-src/scripts/Main.gd` içindeki `BUILD_ID`
sabitini güncelleyin: tarayıcı konsolunda (F12) hangi sürümün çalıştığı tek
bakışta görünür.

    === kicked-ball build 2026-08-12c | metin: 55 anahtar (csv) | ... ===

`metin: 55 anahtar (csv)` satırı metinlerin doğru katmandan geldiğini
doğrular. `0` veya `-1` görürseniz CSV pakete girmemiş demektir.

---

## 5. Bu dağıtımda yapılan değişiklikler

- Godot projesi Godot 4.6 ile **Web (thread'siz)** olarak dışa aktarıldı;
  çıktı `public/` klasöründe, `vercel.json` ile başlıklar ayarlandı.
- Türkçe HTML kabuğu eklendi (`godot-src/web/shell.html`): `lang="tr"`,
  Türkçe hata/JavaScript uyarıları, arama motorlarına kapalı (`noindex`).
- İsteğe bağlı sunucu kaydı: `api/collect.js` + `godot-src/scripts/Uplink.gd`;
  DataLog ve Telemetry'ye bağlandı. Yerel kayıt hâlâ asıl kayıttır.
- Tüm kaynak, doküman ve arayüz metinlerindeki ASCII olmayan semboller
  (oklar, kutu çizgileri, onay işaretleri, orta nokta, uzun tire, üst simge
  vb.) ASCII karşılıklarıyla değiştirildi. Türkçe harfler korundu.
- Fizik, arayüz akışı, telemetri alanları, kod kütüphanesi ve yönetici paneli
  **değiştirilmedi**. Başsız duman testi (`tools/smoke_test.gd`) ve tarayıcı
  testi bu sürümde geçti.
