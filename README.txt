COMMUNICATEPARS - WINDOWS -> iPad/iPhone FIZIKSEL MOUSE KONTROLU
Surum: 0.3.0 (deneysel)

YENI OZELLIKLER
  - Gercek USB/kablolu mouse hareketi iPad'e aktarilir.
  - Sol, sag ve orta mouse tuslari aktarilir.
  - Mouse tekerlegi aktarilir.
  - K tusuyla mouse iPad ile Windows arasinda aninda degistirilir.
  - Windows Raw Input ayri bir is parcaciginda calisir.
  - 8 ms ornekleme ve birlestirilmis HID raporlari kullanilir.

ONEMLI UYARI
Bu yontem calisirken Intel Bluetooth aygitinin Windows surucusunu gecici olarak
WinUSB ile degistirir. Test boyunca Windows'un normal Bluetooth ozelligi,
Bluetooth kulaklik, klavye ve mouse calismaz. Wi-Fi etkilenmez.

Baslamadan once kablolu/USB klavye ve mouse kullanin. "YEDEK HAZIR" yazisini
gormeden Zadig adimina GECMEYIN. Zadig'de yanlis aygit secmek baska bir USB
aygitini devre disi birakabilir.

DESTEKLENEN TEST BILGISAYARI
  Windows 10 x64: 10.0.19045
  Intel Bluetooth USB kimligi: 8087:0A2A

ONCEKI 0.2 TESTINDEN GELIYORSANIZ
  - Once 0.2 klasorundeki 3_BLUETOOTHU_GERI_GETIR.bat dosyasini yonetici olarak
    calistirin ve normal Bluetooth'un geri geldigini kontrol edin.
  - iPad'de daha once eslestirilen "HID Mouse" baglanmazsa "Bu Aygiti Unut"
    secenegini kullanip yeniden eslestirin. Yeni klasor yeni eslestirme veritabani
    kullanir.

1) INTEL SURUCUSUNU YEDEKLE
  - 1_SURUCU_YEDEKLE.bat dosyasina sag tiklayin.
  - "Yonetici olarak calistir" secin.
  - Yalnizca yesil "YEDEK HAZIR" mesaji gelirse devam edin.
  - driver-backup klasorunu test bitene kadar silmeyin veya tasimayin.

2) INTEL BLUETOOTH'U WINUSB'YE GECIR
  - Zadig'i resmi sitesinden indirin: https://zadig.akeo.ie/
  - Zadig'i yonetici olarak acin.
  - Options > List All Devices secin.
  - Listeden YALNIZCA "Intel(R) Wireless Bluetooth(R)" aygitini secin.
  - USB ID alaninin kesinlikle 8087 ve 0A2A oldugunu kontrol edin.
  - Sag tarafta WinUSB secin.
  - Replace Driver dugmesine basin ve tamamlanmasini bekleyin.
  - Wi-Fi aygitini, mouse'u, klavyeyi veya kamerayi secmeyin.

3) FIZIKSEL MOUSE KONTROLUNU CALISTIR
  - 2_MOUSE_KONTROLUNU_CALISTIR.bat dosyasini acin.
  - Konsolda "Windows Raw Input hazir" ve "BTstack up and running" yazilarini
    bekleyin.
  - iPad/iPhone'da Bluetooth'u ve AssistiveTouch'u acin.
  - Ayarlar > Erisilebilirlik > Dokunma > AssistiveTouch > Aygitlar >
    Bluetooth Aygitlari bolumunden "HID Mouse" aygitini baglayin.
  - Konsolda "Report Characteristic Subscribed 1" gorulunce K tusuna basin.

KONTROLLER
  K       : Fiziksel mouse'u iPad'e verir.
  K tekrar: Mouse'u Windows'a geri verir.
  Ctrl+C  : Programi kapatir.

Mouse iPad'e verildiginde Windows imleci oldugu noktada tutulur. K ile geri
alindiginda Windows imleci onceki konumuna doner. Programi kapatmadan once K ile
mouse'u Windows'a geri vermeniz onerilir.

4) WINDOWS BLUETOOTH'U GERI GETIR
  - K tusuyla mouse'u Windows'a geri alin.
  - Programi Ctrl+C ile kapatin.
  - 3_BLUETOOTHU_GERI_GETIR.bat dosyasina sag tiklayin.
  - "Yonetici olarak calistir" secin.
  - "BLUETOOTH GERI YUKLENDI" mesajini bekleyin.
  - Bluetooth simgesi gelmezse Windows'u bir kez yeniden baslatin.

SORUN CIKARSA
  - Konsoldaki tum metnin ekran goruntusunu alin.
  - Program yanit vermese bile mouse sabitlemesi program kapaninca sona erer.
  - 3_BLUETOOTHU_GERI_GETIR.bat dosyasini yonetici olarak calistirin.
  - Otomatik geri yukleme olmazsa Windows'u yeniden baslatip betigi tekrar
    calistirin. driver-backup klasorunu silmeyin.

LISANS
BTstack sadece kisisel ve ticari olmayan kullanim kosuluyla bu pakette bulunur.
Ticari kullanim icin BlueKitchen ticari lisansi gerekir. Ayrintilar licenses
klasorundedir.

PROGRAM SHA-256
  CommunicatePars-iOS-Mouse.exe
  33220a6ff8ad14cf3992231a56c8d9976447ba54152b1193a32d1289af357394
