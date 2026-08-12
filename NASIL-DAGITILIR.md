# Vercel dağıtımı — Kicked-Ball Simulation (build 2026-08-12c)

Bu klasör **dağıtımın kendisidir**. Godot'a, derlemeye, `npm install`'a gerek
yok — olduğu gibi yayına verilir.

---

## Seçenek A — Vercel CLI (en hızlı, önerilen)

    npm i -g vercel
    cd vercel-deploy
    vercel deploy --prod

İlk çalıştırmada soracağı sorular: proje adı serbest, **"In which directory is
your code located?" → `./`**, framework algılama sorarsa **Other**.

## Seçenek B — GitHub üzerinden

1. Bu klasörün **içeriğini** bir GitHub deposuna koy — `index.html` deponun
   KÖKÜNDE olacak şekilde.
2. vercel.com → Add New → Project → depoyu Import et.
3. Ayarlar:
   - Framework Preset: **Other**
   - Build Command: **boş bırak**
   - Output Directory: **`.`** (tek nokta)
   - Install Command: **boş bırak**
4. Deploy.

> **DİKKAT — en sık yapılan hata:** bu klasörü Godot projesinin İÇİNE koyup
> öyle push'lamak. Godot projesinin `.gitignore`'unda `/build/` satırı var;
> klasör adı `build` olursa git onu hiç göndermez ve Vercel boş/eski bir site
> yayınlar. Bu klasörün adı bilerek `vercel-deploy` — `build` olarak yeniden
> adlandırma.

---

## Çalışan sürümü doğrulama (5 saniye)

Site açıldığında **F12 → Console** sekmesinde şu satır olmalı:

    === kicked-ball build 2026-08-12c | metin: 55 anahtar (csv) | impetus_acc=4.0 drag_k=0.025 goal_x=34.0 ===

| Gördüğün | Anlamı |
|---|---|
| `metin: 55 (csv)` | her şey normal |
| `metin: 55 (baked)` | metinler DOĞRU görünür (yedek katman devrede), yine de `strings.csv.import` düzeltilmeli |
| `metin: 0` | hiçbir metin kaynağı yok — `tools/bake_strings.gd` çalıştırılmamış |
| başka bir build numarası | eski sürüm servis ediliyor, yeni dağıtım yayına geçmemiş |

Konsolu açmadan da bakabilirsin: sayfa kaynağında (`Ctrl+U`)
`<meta name="build" content="2026-08-12c">` satırı var.

---

## Neden dosya adlarında sürüm var?

Oyun dosyaları `app-20260812c.wasm / .pck / .js` diye adlandırıldı. Bunlar
"sonsuza kadar önbelleklenebilir" (immutable) olarak işaretli — hızlı açılır.
`index.html` ise **hiç önbelleklenmez** (`no-store`), yani tarayıcı her ziyarette
onu yeniden indirir ve hangi sürüm dosyalarını yükleyeceğini oradan öğrenir.

Sonuç: yeni sürüm dağıttığında dosya adları değişir, eski önbellek eşleşmez,
öğrenci hiçbir zaman eski sürümü görmez. (Daha önce her dağıtımda dosya adları
aynı — `index.pck` — olduğu için tarayıcı eski paketi servis edebiliyordu.)

**Yeni sürüm çıkarırken:** dosya adındaki tarihi değiştir, yoksa aynı sorun geri
gelir. Aşağıdaki komut bunu zaten yapıyor.

---

## Yeniden üretmek (projede değişiklik yaptıktan sonra)

    # 1) metinleri değiştirdiysen önce pişir
    godot --headless --path <proje> --script tools/bake_strings.gd

    # 2) sürümlü adla dışa aktar
    godot --headless --path <proje> --export-release "Web" cikti/app-<YENİTARİH>.html

    # 3) giriş sayfasını oluştur (içerik aynı, sadece adı index.html)
    cp cikti/app-<YENİTARİH>.html cikti/index.html

    # 4) vercel.json'ı bu klasörden kopyala

`scripts/Main.gd` içindeki `BUILD_ID` sabitini de güncelle ki konsoldaki satır
doğru sürümü göstersin.

---

## Yerelde denemek

    cd vercel-deploy
    python3 -m http.server 8000
    # http://localhost:8000/

`file://` ile açma — tarayıcı `.wasm`/`.pck` indirmesini engeller, siyah ekran çıkar.

---

## Teknik notlar

- Godot 4.5.1, Web **nothreads** varyantı → COOP/COEP başlıklarına ihtiyaç yok,
  her statik sunucuda çalışır.
- `vercel.json` yalnızca MIME tiplerini ve önbellek sürelerini ayarlar.
- `.wasm` 38 MB'tır ama sunucu sıkıştırmasıyla telde ~9 MB'a iner; ilk açılış
  birkaç saniye sürer, sonraki açılışlar önbellekten anında gelir.
- Bu paket, gzip sıkıştırması ve yukarıdaki başlıklar açıkken gerçek bir
  tarayıcıda uçtan uca test edildi: giriş kodu, soru ekranı, doğru cevap → GOL.
