# Kicked-Ball Simulation — Vercel dağıtımı

Bu depo doğrudan yayına hazırdır; derleme adımı YOKTUR.

## Vercel ayarları
Framework Preset: **Other** · Build Command: **boş** · Output Directory: **.**

## Güncelleme (yeni sürüm çıktığında)
1. Yeni build'in TÜM dosyalarını bu klasöre kopyala, üzerine yaz.
   index.html · index.js · index.wasm · index.pck · index.png · worklet'ler
   Bu dörtlü (html/js/wasm/pck) AYNI export'tan gelmeli — karışık sürüm bozuk sayfa demektir.
2. Commit + push. Vercel otomatik deploy eder (Deployments sekmesinden "Ready" bekle).
3. Sayfayı Ctrl+Shift+R ile aç.

## Neden önbellek başlıkları var?
Godot dosya adları her sürümde aynı kalıyor (index.wasm, index.pck). Bu yüzden
tarayıcı/CDN eski kopyayı saklayıp "güncellenmedi" izlenimi veriyordu.
vercel.json içindeki `Cache-Control: no-cache, must-revalidate` sayesinde
tarayıcı her açılışta dosyanın değişip değişmediğini sunucuya soruyor —
dosya aynıysa yine hızlı, değiştiyse yenisini indiriyor.

## Yayının güncel olduğunu doğrulama
Simülasyona gir; metinler "POPUP_INTRO_TITLE" gibi anahtar değil, düzgün Türkçe
görünmeli. Şüphede kalırsan tarayıcı konsolunda:
    await (await fetch('/index.pck')).blob()
boyut 340500 bayt ise bu sürüm yayındadır.

F8 = etkileşim verisi (JSONL) · F9 = veri durumu · F10 = CSV · F11 = tam ekran
Yönetici kodu: Y-ADM-996
