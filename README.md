# Eczanem

Eczanem, sıfır bütçeli servislerle çalışan Flutter mobil uygulamasıdır. Konuma göre yakın eczaneleri OpenStreetMap tabanlı haritada gösterir, nöbetçi eczane verisini API anahtarıyla alır ve kişisel ilaç hatırlatmalarını cihaz üzerinde saklar.

## Kurulum

1. Flutter stable sürümünü kurun.
2. `.env.example` dosyasındaki formatla `.env` dosyasına Eczaneler.ORG anahtarınızı yazın: `API_KEY=...`.
3. Paketleri indirin: `flutter pub get`.
4. Çalıştırın: `flutter run`.
5. Model alanlarını değiştirirseniz Hive adapter üretimi için `dart run build_runner build --delete-conflicting-outputs` komutunu kullanın.

## Neden Bu Paketler?

- `flutter_map`: Google Maps ücreti olmadan OpenStreetMap haritası.
- `geolocator`: Cihaz GPS konumu ve izin yönetimi.
- `http`: Eczaneler.ORG ve Overpass istekleri.
- `hive`: Hafif yerel veritabanı.
- `flutter_local_notifications`: Ücretsiz cihaz içi ilaç hatırlatmaları.
- `provider`: Sade durum yönetimi.
- `flutter_dotenv`: API anahtarını kod dışında tutma.
- `url_launcher`: Telefon arama ve harici harita uygulamasına yönlendirme.

## API Notu

Eczaneler.ORG endpoint yolu `lib/services/eczane_api_service.dart` içinde tek sabit olarak tutulur. Dokümantasyondaki kesin yol farklıysa yalnızca `cityDutyEndpoint` sabitini güncellemeniz yeterlidir.

## Günlük Merkezi Veri Güncelleme

Uygulama, her kullanıcı açılışında eczane API'sini tüketmek yerine önce hazır JSON verisini okumaya ayarlandı.

1. GitHub Pages'i aktif edin ve `public/data/pharmacies_latest.json` dosyasının yayınlanan adresini alın.
2. Flutter tarafındaki `.env` dosyasına şunu yazın:

`PHARMACY_DATA_URL=https://kullanici-adiniz.github.io/repo-adiniz/data/pharmacies_latest.json`

Workflow `.github/workflows/daily-pharmacy-sync.yml` dosyasında tanımlı. Her gün 06:00 UTC'de, yani Türkiye saatiyle 09:00'da çalışır. Bu sistem ücretli API kullanmaz; 81 ilin kamuya açık nöbetçi eczane sayfalarını makul aralıkla okuyup tek JSON cache üretir.

İlk ücretsiz sürümde bazı kaynaklarda koordinat olmadığı için nöbetçi eczaneler il merkezi koordinatıyla işaretlenebilir. Adres ve ilçe bilgisi JSON içinde tutulur; hassas koordinat için sonradan OSM/Nominatim veya elle oluşturulan cache eklenebilir.

Normal eczane datası için `public/data/normal_pharmacies_seed.json` kullanılır. Bunu haftalık/aylık OSM export ile güncellemek daha sağlıklıdır; her gün tüm Türkiye için Overpass sorgusu çalıştırmak önerilmez.


## Ücretsiz 81 İl Kaynakları

`data_sync/free_sources.json` içinde 81 il için kaynak URL bulunur. Varsayılan kaynaklar il bazlı kamuya açık `eczaneleri.net` sayfalarıdır. Bir ilin resmi eczacı odası sayfası daha sağlıklı veri verirse aynı dosyada o ilin `sourceUrl` alanı değiştirilebilir.

Bu sistem API anahtarı istemez. Yine de kaynak siteleri yormamak için günlük tek çalıştırma ve istekler arasında bekleme uygulanır.
