# Kicked-Ball Simulation — web sürümü (hazır build)

Bu klasör TARAYICIDA ÇALIŞAN hazır sürümdür. Derlemeye gerek yok.

## Yerelde denemek
Dosyaya çift tıklamak ÇALIŞMAZ (tarayıcı güvenlik kuralı). Bir sunucu gerekir:

    cd bu-klasor
    python3 -m http.server 8000

Sonra tarayıcıda: http://localhost:8000

## Vercel'e yüklemek (sunum için en hızlısı)
1. https://vercel.com → Add New → Project → "Deploy without Git" (veya bu klasörü sürükleyip bırakın)
2. Framework Preset: **Other**, Output Directory: **.** (bu klasör)
3. Deploy → verilen adres doğrudan çalışır.

Vercel CLI ile:

    npm i -g vercel
    cd bu-klasor
    vercel --prod

## GitHub Pages ile
Bu klasörün içeriğini deponun `docs/` klasörüne (veya `gh-pages` dalına) koyup
Settings → Pages'ten yayınlayın. Ek ayar gerekmez.

## Notlar
- Thread'siz (nothreads) sürüm olarak derlendi; bu yüzden özel CORS/COOP başlığı
  GEREKMEZ, her statik sunucuda çalışır.
- İlk açılış ~9 MB indirir (gzip'li). Sunum öncesi sayfayı bir kez açıp
  önbelleğe almanız iyi olur.
- Ses (vuruş + tezahürat) tarayıcı kuralı gereği ilk tıklamadan sonra çalışır;
  giriş ekranında "Devam Et"e basılınca sorun kalmaz.
- CSV: web sürümünde "CSV dışa aktar" bağlantısı dosyayı doğrudan indirir.
  Veriler tarayıcının kalıcı deposunda (IndexedDB) tutulur — yani veri,
  kullanılan bilgisayara/tarayıcıya bağlıdır. Görüşme bitince CSV'yi indirin.
- Yönetici kodu: Y-ADM-996
