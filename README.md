# Kicked-Ball Simulation — Vercel dağıtım klasörü

Bu klasör Godot 4.5 "Web" export çıktısıdır ve **olduğu gibi** dağıtılır.
Vercel'in çalıştıracağı bir derleme adımı YOKTUR.

## Dağıtım

    vercel deploy --prod          # bu klasörün İÇİNDEN

veya vercel.com üzerinden repo import ederek:
  Framework Preset : Other
  Build Command    : (boş bırak)
  Output Directory : .

## Yeniden üretim

Bu klasör ELLE düzenlenmez — kaynaktan yeniden üretilir:

    ./tools/build_web.sh              # proje kökünden
    ./tools/build_web.sh --deploy     # üret + vercel'e yükle

## vercel.json neden gerekli?

- `.wasm` -> `application/wasm`  (bazı CDN'ler yanlış MIME tipi verir; yanlış tipte
  WebAssembly streaming derlemesi bozulur veya yavaş yola düşer)
- `.pck`  -> `application/octet-stream`
- COOP/COEP başlıkları: thread'siz build için ZORUNLU DEĞİL, zararsız; ileride
  `variant/thread_support=true` yapılırsa SharedArrayBuffer için ŞART olur.
- `index.html` no-cache, diğer varlıklar immutable: yeni sürüm anında görünür,
  38 MB'lık wasm ise tarayıcıda önbelleklenir.

## Sürüm notu

Export ayarı: release, `variant/thread_support = false` (thread'siz).
Bu sayede COOP/COEP başlıkları olmayan herhangi bir statik sunucuda da çalışır.
