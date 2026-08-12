# Vercel'e dağıtım — build 2026-08-12c

## Önce: neden alt klasör var?

Bir önceki dağıtımda dosya adları aynıydı (`/index.pck`, `/index.wasm`), bu
yüzden tarayıcı ve Vercel CDN eski dosyayı önbellekten servis edebiliyordu —
yeni build yüklense bile ekranda ESKİ sürüm görünüyordu (metinlerin
`KICK_PANEL_TITLE` gibi anahtar isimleri olarak çıkması bunun belirtisiydi).

Bu paket bunu imkânsız kılar:
- Tüm oyun dosyaları `/b20260812c/` altında → **yepyeni URL'ler**, hiçbir
  önbellek onları tanımıyor.
- Kökteki küçük `index.html` oraya yönlendiriyor ve
  `no-store` ile servis ediliyor → yönlendirme sayfası asla önbelleklenmez.
- Sonraki sürümde klasör adını değiştir (`b20260901a` gibi), kökteki
  `index.html` içindeki iki yolu güncelle — sorun bir daha çıkmaz.

## Çalışan sürümü doğrulama (5 saniye)

Siteyi aç → **F12** → Console. Şu satır görünmeli:

    === kicked-ball build 2026-08-12c | metin: 55 anahtar (csv) | impetus_acc=4.0 drag_k=0.025 goal_x=34.0 ===

- `metin: 55 (csv)` → her şey normal.
- `metin: 55 (baked)` → CSV pakete girmemiş ama pişirilmiş yedek devrede;
  metinler DOĞRU görünür, yine de `strings.csv.import` düzeltilmeli.
- `metin: 0` → hiçbir kaynak yüklenmedi (bu artık olmamalı; olursa
  `tools/bake_strings.gd` çalıştırılmamış demektir).
- Build numarası farklı çıkıyorsa → ESKİ sürümü görüyorsun, yeni dağıtım
  yayına geçmemiş demektir.

## Seçenek A — Vercel CLI

    npm i -g vercel
    cd <bu klasör>
    vercel deploy --prod

## Seçenek B — GitHub üzerinden

1. Bu klasörün İÇERİĞİNİ (kökte `index.html`, `vercel.json` ve `b20260812c/`
   olacak şekilde) bir repoya koy.
2. vercel.com → Add New → Project → repoyu Import et.
3. Framework Preset: **Other** · Build Command: **(boş)** ·
   Output Directory: **.** · Install Command: **(boş)**
4. Deploy.

Eski bir projeyi güncelliyorsan: dağıtım bittikten sonra sayfayı **hard
refresh** ile aç (Cmd+Shift+R / Ctrl+F5). Alt klasör zaten önbelleği
atlatıyor ama kök sayfa için garanti olsun.

## Yerelde denemek

    cd <bu klasör>
    python3 -m http.server 8000
    # http://localhost:8000/

`file://` ile AÇMA — tarayıcı .wasm/.pck fetch'ini engeller, siyah ekran çıkar.

## Yeniden üretmek

    mkdir -p build/b<YENI-SURUM>
    godot --headless --path <proje> --export-release "Web" build/b<YENI-SURUM>/index.html

Godot 4.5 / 4.5.1 + Web export template'leri kurulu olmalı
(Editor → Manage Export Templates → Download and Install).
Build numarasını `scripts/Main.gd` içindeki `BUILD_ID` sabitinden güncelle.
