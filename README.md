# Yabancılar İçin Yapay Zeka Destekli Mobil Türkçe Öğrenimi Uygulaması

Bu proje, yabancı kullanıcıların Türkçe öğrenmesini destekleyen mobil frontend uygulamasıdır.

# Hızlı Başlangıç

Projeyi hızlıca çalıştırmak için aşağıdaki komutları kullanabilirsiniz:

```powershell
flutter pub get
flutter devices
flutter run -d emulator-5554
```

Uygulamanın tam işlevsellikle çalışabilmesi için backend’in çalışıyor olması gerekmektedir. Android emulator üzerinden backend'e bağlanmak için kullanılan varsayılan adres şudur:

```text
http://10.0.2.2:5260/api
```

# Proje Özeti

Bu uygulama, yabancılar için geliştirilmiş yapay zeka destekli bir mobil Türkçe öğrenimi platformudur. Kullanıcıların kayıt olma, giriş yapma, şifre sıfırlama ve e-posta doğrulama gibi temel yetkilendirme süreçleri güvenli ve modern bir şekilde Firebase Auth kullanılarak sağlanmaktadır. Kayıt ve giriş sonrası Firebase ID token üzerinden backend ile haberleşilip JWT token alınmaktadır. Uygulama aynı zamanda ders içerikleri, soru çözümleri ve AI destekli öğrenme özellikleri ile backend üzerinden entegre olarak çalışır.

# Kullanılan Teknolojiler

* **Flutter & Dart**: Cross-platform mobil uygulama geliştirme altyapısı ve programlama dili.
* **Firebase Auth & Firebase Core**: Kullanıcı kaydı, girişi, şifre sıfırlama ve e-posta doğrulama işlemleri için kullanılan güvenli yetkilendirme altyapısı.
* **Riverpod / StateNotifier**: Uygulama içi state yönetimi (durum yönetimi) için modern ve güvenli bir yaklaşım.
* **Dio**: API isteklerini (HTTP request), interceptor, token ekleme ve yönlendirmeleri yönetmek için kullanılan gelişmiş ağ paketi.
* **Flutter Secure Storage**: Alınan JWT (JSON Web Token) değerini cihazda şifreli ve güvenli bir şekilde saklamak için kullanılır.
* **Flutter TTS**: Metinleri sesli olarak okuma (Text-to-Speech) özelliği sağlar.
* **Record / Ses Paketleri**: Kullanıcının ses kaydını almak ve ses işleme operasyonları yapmak için kullanılır.
* **Android Emulator**: Uygulamayı lokalde test etmek için kullanılan sanal cihaz (Örn: `10.0.2.2` API yönlendirmesi ile).
* **Backend API Bağlantısı**: Tüm veritabanı kayıtları, SQL entegrasyonu ve AI işlemleri backend üzerinden gerçekleştirilir.

# Proje Klasör Yapısı

* `lib/`: Uygulamanın tüm Dart kaynak kodlarının bulunduğu ana dizin.
* `lib/main.dart`: Uygulamanın başlangıç noktasıdır, Firebase initialization ve HTTP override (gerekirse SSL için) işlemleri burada yapılır.
* `lib/firebase_options.dart`: FlutterFire CLI tarafından üretilen, projenin Firebase bağlantısını sağlayan client configuration dosyası.
* `lib/data/services/`: API, Firebase Auth, Öğrenci ve AI servisleri gibi uygulamanın veri katmanı sınıflandırılmalarının bulunduğu dizin.
* `lib/features/auth/`: Login, register, forgot password ve email verification gibi yetkilendirme ile ilgili tüm UI ekranlarının bulunduğu özellik dizini.
* `android/`: Android platformuna özgü native yapılandırma, manifest ve Gradle dosyalarının bulunduğu dizin.
* `pubspec.yaml`: Uygulamanın bağımlılıklarını (dependencies), sürüm numarasını ve asset ayarlarını içeren yapılandırma dosyası.

# Firebase Auth Entegrasyonu

* Uygulama başlarken `main.dart` içinde `Firebase.initializeApp` çağrısı ile Firebase başlatılır.
* Proje kökündeki `firebase_options.dart` dosyası FlutterFire tarafından otomatik üretilmiştir ve bağlanılacak Firebase projesini belirler.
* Yetkilendirme modeli olarak Email/Password authentication kullanılır.
* Email verification (e-posta doğrulama) süreci Firebase üzerinden gerçekleştirilir ve kullanıcı onaylamadan sisteme JWT token ile giremez.
* Password reset (şifre sıfırlama) işlemleri doğrudan Firebase'in güvenli şifre sıfırlama mail akışı ile yapılır.
* Firebase ID Token'ı alınarak, backend'in Firebase Admin SDK aracılığıyla bu token'ı doğrulaması ve sisteme entegre etmesi sağlanır.

# Kayıt Akışı

1. Kullanıcı register formunu (ad, soyad, e-posta, şifre) doldurur.
2. Flutter, Firebase Auth üzerinden kullanıcı oluşturur (`createUserWithEmailAndPassword`).
3. Firebase otomatik olarak doğrulama maili gönderir.
4. Kullanıcı email verification (e-posta doğrulama) ekranına yönlendirilir.
5. Kullanıcı e-postasındaki linke tıklayarak mailini doğrular.
6. Flutter, Firebase ID token alır.
7. Backend'deki `complete-firebase-register` endpoint'ine Firebase token ve profil bilgileri gönderilir.
8. Backend, token'ı doğrular ve SQL tarafında öğrenci kaydını (Student tablosunda) tamamlar.
9. Başarılıysa kullanıcı uygulamaya devam eder ve ana ekrana alınır.

# Login Akışı

1. Kullanıcı e-posta ve şifresini girer.
2. Firebase Auth ile giriş (login) yapılır (`signInWithEmailAndPassword`).
3. Kullanıcının `emailVerified` durumu kontrol edilir, doğrulanmamışsa verification ekranına atılır.
4. Doğrulanmışsa Firebase ID token alınır.
5. Backend'deki `firebase-login` endpoint'ine bu ID token gönderilir.
6. Backend Firebase token'ı doğrular ve uygulama içi özel JWT token döner.
7. Alınan JWT token `Flutter Secure Storage` kullanılarak cihaza güvenli şekilde kaydedilir.
8. Kullanıcı uygulamaya (ana ekrana) yönlendirilir.

# Şifre Sıfırlama Akışı

* Şifre sıfırlama işlemleri tamamen Firebase Auth üzerinden gerçekleştirilmektedir.
* Kullanıcı "Şifremi Unuttum" ekranında kayıtlı e-posta adresini girer.
* Firebase `sendPasswordResetEmail` fonksiyonu ile e-postaya şifre sıfırlama linki gönderilir.
* Kullanıcı gelen maildeki link üzerinden yeni şifresini belirler.
* Yeni şifresiyle uygulamaya Firebase Auth üzerinden başarılı bir şekilde giriş yapar.
* *Not: Bu akış backend’deki eski SQL bazlı password reset sistemiyle karıştırılmamalıdır, sadece Firebase kullanılır.*

# Backend Bağlantısı

* Android emulator testleri için backend adresi şu şekilde yapılandırılmıştır:

```text
http://10.0.2.2:5260/api
```

* Uygulama fiziksel bir cihazda çalıştırılacaksa, `10.0.2.2` yerine backend'i barındıran bilgisayarın yerel ağ IP adresi (örn. `192.168.1.x`) kullanılmalıdır.
* Backend kapalıysa (çalışmıyorsa) Firebase'e kayıt işlemi kısmen tamamlansa bile `complete-firebase-register` adımında hata alınır ve kayıt tamamlanamaz. Benzer şekilde, login sonrasında Firebase token alınsa bile JWT token alınamayacağı için giriş akışı çalışmaz.
* Android tarafında yerel geliştirme ortamında HTTP isteklerine (HTTPS değil) izin verebilmek için `cleartextTraffic` açık olarak yapılandırılmıştır.

# Local Çalıştırma

Projeyi bilgisayarınızda çalıştırmak için aşağıdaki adımları izleyin:

```powershell
cd "C:\path\to\final-project-frontend-ediz-push"
flutter pub get
flutter devices
flutter run -d emulator-5554
```

Eğer açık bir emulator yoksa, önce emulator'ü başlatın:

```powershell
flutter emulators
flutter emulators --launch Pixel_API_36
flutter devices
flutter run -d emulator-5554
```

*(Not: `Pixel_API_36` kısmı bilgisayarınızdaki mevcut emulator ismine göre değişiklik gösterebilir.)*

# Firebase Kurulum Notları

* Firebase Console üzerinden **Authentication -> Sign-in method** sekmesinden "Email/Password" provider'ı aktif (Enable) edilmelidir.
* Projeye yeni platformlar eklemek gerekirse `flutterfire configure` komutuyla `firebase_options.dart` tekrar üretilebilir.
* `firebase_options.dart` dosyasındaki API key ve appId gibi değerler **Firebase Client Config** değerleridir. Bunlar backend secret'ı değildir ve frontend'de bulunması normaldir.
* Yine de en iyi güvenlik pratikleri için Google Cloud Console üzerinden projeye ait API Key'ler kısıtlanmalıdır (API key restriction - örn. sadece Android/iOS uygulamalarından gelen istekleri kabul edecek şekilde).

# Android / Gradle Notları

Android ortamı için yapılmış başlıca uyumluluk ve yapılandırma ayarları şunlardır:

* **compileSdk**: Proje güncel gereksinimleri karşılamak adına `compileSdk = 36` olarak ayarlanmıştır.
* **Gradle / Kotlin**: Proje Gradle Kotlin DSL (`build.gradle.kts`) kullanmaktadır ve JavaVersion olarak `17` hedeflenmiştir.
* **Desugaring**: Android'in eski sürümlerinde yeni Java özelliklerini destekleyebilmek için `coreLibraryDesugaring` (`isCoreLibraryDesugaringEnabled = true`) aktiftir.
* **Cleartext Traffic**: Lokal backend testleri (HTTP üzerinden çalışan) için `AndroidManifest.xml` içinde `android:usesCleartextTraffic="true"` bayrağı verilmiştir.
* **Emulator Uyumluluğu**: API 36 gibi yeni nesil emulatorlerle test edilmiştir, uyumlu çalışmaktadır.

# Güvenlik Notları

* **ÖNEMLİ**: Frontend kodları (Dart) içine Groq API key gibi yapay zeka servislerine ait gizli anahtarlar kesinlikle yazılmamalıdır.
* Frontend içinde veritabanına bağlanmak için kullanılan Azure SQL connection string veya SQL şifreleri bulunmamalıdır.
* Frontend içinde Firebase Admin SDK'ya ait `service-account.json` / private key değerleri bulunmamalıdır. Firebase Admin SDK yalnızca backend tarafında bulunmalı ve çalışmalıdır.
* `firebase_options.dart` içerisindeki key'ler genel (public) client config bilgileridir, ifşa olmaları güvenlik riski yaratmaz ancak gereksiz kullanımları önlemek için Google Cloud Console üzerinden "Android apps / iOS apps" olarak sınırlandırılmaları (restriction) önerilir.

# Bilinen Hatalar ve Çözümler

* **Backend Bağlantı Hatası (Connection Timeout)**: Backend projesi açık değilse uygulamanın API istekleri hata verir. Backend'i çalıştırdığınızdan emin olun.
* **Emulator Bağlantı Sorunu**: Emulator içinden backend'e bağlanırken `localhost` veya `127.0.0.1` çalışmaz. Daima `10.0.2.2` IP'sini kullanın.
* **Email Verification Maili Gelmiyor**: Spam (Gereksiz) klasörünü kontrol edin. Firebase limitlerine takılmamak için çok fazla deneme yapmayın.
* **Firebase email-already-in-use**: Kayıt olurken bu e-posta adresi zaten kullanımdaysa alınan hatadır. Başka bir mail ile deneyin veya şifre sıfırlama yapın.
* **Backend 307 Redirect**: Eğer backend HTTP'den HTTPS'e yönlendirme (redirection) zorluyorsa Dio ile 307 hatası alınabilir. Geliştirme ortamında (API testlerinde) HTTP override kullanıldığına (`MyHttpOverrides`) veya URL'in doğru yazıldığına emin olun.
* **Backend 500 Hatası**: Backend loglarını kontrol edin. Büyük ihtimalle veritabanı (SQL) tarafında bir çakışma (aynı UUID veya ID) yaşanmıştır.
* **Android Cleartext HTTP Hatası**: Cihaz, güvenli olmayan HTTP bağlantısını reddederse `AndroidManifest.xml` dosyasındaki `usesCleartextTraffic="true"` satırının varlığını ve projeyi temizleyip (`flutter clean`) yeniden derlediğinizi kontrol edin.
* **Firebase Email Verified False Kalması**: Maildeki doğrulama linkine tıklandıktan sonra Firebase arka planda onaylasa da uygulama içindeki obje eski kalabilir. Bunun için `_auth.currentUser?.reload()` çağrısı yapılarak kullanıcının güncel durumu getirilmelidir.

# Test Edilen Akışlar

Aşağıdaki özellikler başarıyla entegre edilmiş ve test edilmiştir:

* Firebase register (Kayıt) işlemi
* Email verification (E-posta doğrulama) zorunluluğu
* Backend `complete-firebase-register` (Kayıt tamamlama ve SQL yazma)
* Azure SQL kullanıcı veri tabanı aktarımı
* Firebase login (E-posta / Şifre ile giriş)
* Backend JWT token alma (Login sonrası)
* Firebase password reset (Şifremi unuttum maili)

# Son Değişiklik Özeti

* Firebase Auth servisi (`firebase_auth_service.dart`) projeye eklendi ve tüm yetkilendirme yeteneği Firebase üzerine alındı.
* Kayıt (Register) akışı Firebase Auth üzerine taşındı.
* Email verification (e-posta doğrulama) ekranı projeye dahil edildi.
* Login akışı güncellenerek, Firebase ID token alınıp ardından backend üzerinden JWT alma şeklinde kurgulandı.
* Forgot password akışı Firebase üzerinden güvenli bir şekilde çalışır hale getirildi.
* API Base URL ayarları Android Emulator (`10.0.2.2`) ile uyumlu hale getirildi.
* Android projelerinde lokal API testlerinin yapılabilmesi için `AndroidManifest.xml` içine `usesCleartextTraffic="true"` ayarı yapıldı.
