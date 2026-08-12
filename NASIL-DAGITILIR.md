# Vercel'e dağıtım — bu klasör

Bu klasör Godot 4.5 "Web (nothreads)" dışa aktarımının ÇIKTISIDIR; hazır.
`variant/thread_support = false` olduğu için **COOP/COEP başlıklarına gerek
yoktur** — her statik sunucuda çalışır. `vercel.json` yalnızca doğru MIME
tipini (`.wasm`, `.pck`) ve önbellek sürelerini ayarlar.

## Seçenek A — Vercel CLI (en hızlı)

    npm i -g vercel
    cd build
    vercel deploy --prod

## Seçenek B — GitHub üzerinden

1. Bu klasörün İÇERİĞİNİ (index.html kökte olacak şekilde) bir repoya koy.
2. vercel.com → Add New → Project → repoyu Import et.
3. Framework Preset: **Other**
   Build Command: **(boş bırak)**
   Output Directory: **.**
   Install Command: **(boş bırak)**
4. Deploy.

## Yerelde denemek

    cd build
    python3 -m http.server 8000
    # http://localhost:8000/index.html

`file://` ile AÇMA — tarayıcı .wasm/.pck fetch'ini engeller, siyah ekran görürsün.

## Yeniden üretmek

    godot --headless --path <proje> --export-release "Web" build/index.html

(Godot 4.5 ve Web export template'leri kurulu olmalı: Editor → Manage Export
Templates → Download and Install.)
