
# 🧭 TravelBuddy

iOS-приложение с картой, списком точек интереса и экраном настроек.  
Проект демонстрирует архитектуру с чётким разделением слоёв, реактивный UI и интеграцию системных фреймворков iOS.

---

## Архитектура

TravelBuddy построен по принципам **Clean Architecture** и **MVVM** с внедрением зависимостей через **Swinject**.  
Потоки данных однонаправленные (Combine + async/await).  
Навигация управляется координаторами, а бизнес-логика отделена от инфраструктуры.

App/

├ Presentation/ → View + ViewModel (Combine/async, Router/Coordinator)

├ Domain/       → контракты и модели (чистая логика)

├ Infrastructure/ → реализация контрактов (сеть, кэш, IAP, Push, Analytics)

├ Core/         → утилиты, DesignTokens, L10n, экстеншены

└ Resources/    → локализация, моки, ассеты



### Поток данных
User → View → ViewModel → UseCase/Repository → Data Source → ViewModel (state) → View


### Domain и Infrastructure

- **Domain** описывает *что нужно сделать* — контракты (`POIServiceProtocol`, `POICacheProtocol`) и модели (`POI`, `POICategoryFilter`, `OnboardingPage`).
- **Infrastructure** реализует *как это делается* — `HTTPClient`, `RemotePOIService`, `LocalPOIService`, `POIRepository`, `RealmPOICache`, `IAPService`, `NotificationService`, `AnalyticsService`.

`POIRepository` объединяет источники и реализует политику:
- cache-then-refresh;
- TTL для «свежести» данных;
- дедупликацию параллельных запросов.

---

## Навигация и координаторы

- Корневой `AppCoordinator` создаёт таб-интерфейс: **Places**, **Map**, **Settings**.  
- Для каждой вкладки — свой координатор (`POIListCoordinator`, `MapCoordinator`, `SettingsCoordinator`).
- Навигационные команды передаются через Router (Combine-publisher), ViewModel не знает о UIKit.

---

## Данные и кэш

HTTPClient (URLSession)
↓
RemotePOIService / LocalPOIService
↓
POIRepository (TTL, cache-then-refresh, dedup)
↓
RealmPOICache


Кэширование выполняется локально через Realm, отметка свежести хранится в `UserDefaults`.

---
## Локализация и дизайн

L10n — типобезопасный хелпер для NSLocalizedString, поддерживает формат с параметрами.

DesignTokens — цвета, шрифты и отступы с учётом Dark Mode и Dynamic Type.


## Запуск проекта

Открыть TravelBuddy.xcodeproj в Xcode 15+.

Выбрать схему TravelBuddy, запустить на симуляторе.

Проверить диплинк:

xcrun simctl openurl booted "travelbuddy://map?lat=55.75&lon=37.61"


Чтобы пересмотреть онбординг — удалить приложение или сбросить ключ hasCompletedOnboarding в UserDefaults.

## 🔔 Push-уведомления (APNs)

В проекте реализован сервис PushService (MVVM + DI), который покрывает:

запрос разрешений (UNUserNotificationCenter.requestAuthorization);

регистрацию в APNs и приём device token;

показ уведомлений в foreground (баннер/лист/звук);

локальные уведомления;

категории/экшены;

диплинки из payload → DeepLinkService.

1) Настройка проекта
Capabilities (Target → Signing & Capabilities)

✅ Push Notifications

✅ Background Modes → Remote notifications (нужно для “тихих” data-уведомлений; баннеры работают и без этого)

Info → URL Types

Добавьте схему travelbuddy для диплинков.

URL Types → +

Identifier: travelbuddy

URL Schemes: travelbuddy


AppDelegate

Делегат и категории назначаются при запуске приложения:

pushService = DIContainer.shared.resolver.resolve(PushServiceProtocol.self)
UNUserNotificationCenter.current().delegate = (pushService as? UNUserNotificationCenterDelegate)
pushService?.registerCategories()

2) Как протестировать
A. Локальный пуш (быстрее всего)

В приложении → Settings:

Request Permission — выдать разрешение.

Schedule Local Test — через 2 сек появится локальное уведомление.
Баннер в foreground контролируется тумблером Show banner in Foreground.

B. Имитация remote push на симуляторе

Симулятор не ходит в APNs, но умеет принимать payload через simctl push.

Создайте файл push.apns (включен в проект)

{
  "aps": {
    "alert": { "title": "Hello from simctl", "body": "Open POI #1" },
    "sound": "default",
    "badge": 1,
    "category": "APP_DEFAULT"
  },
  "deeplink": "travelbuddy://poi/1"
}

xcrun simctl push booted <YOUR_BUNDLE_ID> push.apns
пример:
xcrun simctl push booted niiazkhasanov.TravelBuddy push.apns

Ожидание:

если приложение на экране и включён тумблер — увидите баннер;

если в фоне — пуш ляжет в Notification Center; тап передаст диплинк в приложение (didReceive → DeepLinkService.handle(url:)).

C. Горячая команда без файла (stdin)
cat <<'JSON' | xcrun simctl push booted <YOUR_BUNDLE_ID> -
{
  "aps": {
    "alert": { "title": "Map center", "body": "Paris" },
    "sound": "default",
    "category": "APP_DEFAULT"
  },
  "deeplink": "travelbuddy://map?lat=48.8584&lon=2.2945"
}
JSON


Реальный девайс (настоящие APNs) (не трогал)

Нужен Apple Developer аккаунт и .p8 ключ в Certificates → Keys → Apple Push Notifications key.

Сервер (или FCM) отправляет HTTP/2-запрос на APNs с device token из didRegisterForRemoteNotificationsWithDeviceToken.

Для демо без бэка проще использовать Firebase Cloud Messaging и слать пуш из Firebase Console. 

5) Что работает / не работает на симуляторе
Возможность    Симулятор    Девайс
Локальные уведомления                     ✅    ✅
Banner в foreground                       ✅    ✅
simctl push (имитация APNs payload)       ✅    —
Настоящий device token и APNs доставка    ❌    ✅

На симе реального APNs нет. simctl push лишь вызывает делегаты UNUserNotificationCenter, чего достаточно для проверки UI/логики и диплинков.

## Основные модули

### Map
SwiftUI + `MapViewRepresentable` (мост на MKMapView).  
Поддерживает аннотации, кластеризацию, переход к деталям и диплинки с координатами.

### POI List
Список точек с фильтрацией по категориям.  
Работает через `POIListViewModel` и `POIRepository`.  
Переход в деталь — через `POIListRouter`.

### POI Detail
Показ информации о месте, открытие в Apple Maps, шаринг, обработка ошибок.

### Settings
Настройки темы, уведомлений и Premium-доступа (StoreKit 2).  
Реализованы:
- запрос разрешения на уведомления (`UNUserNotificationCenter`),
- наблюдение транзакций и покупок (`IAPService`, `IAPObserver`),
- состояние Premium.

---

## Диплинки

Поддерживаются ссылки:
- `travelbuddy://map?lat=<lat>&lon=<lon>` — центрировать карту;
- `travelbuddy://poi/<id>` — открыть деталь точки.

Парсинг выполняет `DeepLinkParser`, бизнес-обработка — `DeepLinkService`.  
Работает при холодном и горячем запуске приложения.

### Центр карты
- `travelbuddy://map?lat=48.8584&lon=2.2945` — центр на Eiffel Tower  
- `travelbuddy://map?lat=48.8606&lon=2.3376` — центр на Louvre Museum  
- `travelbuddy://map?lat=48.8867&lon=2.3431` — центр на Sacré-Cœur Basilica  

### Открыть POI
- `travelbuddy://poi/1` — Eiffel Tower (Monument)  
- `travelbuddy://poi/2` — Louvre Museum (Museum)  
- `travelbuddy://poi/3` — Cafe de Flore (Cafe)  
- `travelbuddy://poi/18` — Café Marly (последний элемент списка)  

### Невалидные
- `travelbuddy://poi/999` — несуществующий POI  
- `travelbuddy://map?lat=abc&lon=123` — некорректные координаты  
- `travelbuddy://unknown` — неизвестный хост  


---

## Локализация и дизайн

- **L10n** — типобезопасный хелпер для `NSLocalizedString`, поддерживает формат с параметрами.  
- **DesignTokens** — цвета, шрифты и отступы с учётом Dark Mode и масштабирования.

---

## Тесты и CI

- **UI Snapshot-тесты**: `TravelBuddySnapshotUITests` с `SnapshotHelper.swift` (Onboarding → Places → Detail → Map → Settings).  
- **UI Launch-тесты**: `TravelBuddyUITests`, `TravelBuddyUITestsLaunchTests`.  
- **CI**: GitHub Actions — сборка, юнит-тесты, снапшоты через fastlane.

Базовое покрытие тестами ≈ 28 %. Критичные модули (Repository, ViewModel) — до 60 %.

---

## Фича-флаги

Настраиваются в `AppConfig.makeDefault()`:

| Флаг | Назначение | По умолчанию |
|------|-------------|--------------|
| `enableDebugLogs` | логирование отладочных событий | false |
| `useAlamofireClient` | альтернативный сетевой клиент (POC) | false |
| `showBLETab` | вкладка со сканером BLE-устройств | false |
| `enableAudioGuide` | экспериментальный аудиогид (AVFoundation) | false |

---

## Запуск проекта

1. Открыть `TravelBuddy.xcodeproj` в Xcode 15+.
2. Выбрать схему **TravelBuddy**, запустить на симуляторе.
3. Для проверки диплинков:  
   `xcrun simctl openurl booted "travelbuddy://map?lat=55.75&lon=37.61"`
4. Чтобы пересмотреть онбординг — удалить приложение или сбросить ключ `hasCompletedOnboarding` в `UserDefaults`.

---

## Структура проекта

TravelBuddy/

├ App/

│  ├ AppCoordinator, AppRouter, SceneDelegate, AppDelegate

│  ├ DeepLinkService / DeepLinkParser

│  ├ DIContainer (Swinject)

│  └ AppConfig

│

├ Presentation/

│  ├ POIList/

│  ├ POIDetail/

│  ├ POIMap/

│  ├ Onboarding/

│  ├ Settings/

│  ├ MapContainer / MapViewRepresentable

│  └ Общие UI-компоненты

│

├ Domain/

│  ├ POI.swift

│  ├ POICategoryFilter.swift

│  ├ POIServiceProtocol.swift

│  └ POICacheProtocol.swift

│

├ Infrastructure/

│  ├ HTTPClient.swift

│  ├ RemotePOIService.swift / LocalPOIService.swift

│  ├ POIRepository.swift / RealmPOICache.swift

│  ├ IAPService.swift / IAPObserver.swift

│  ├ NotificationService.swift / AnalyticsService.swift

│  ├ PushService.swift / PushPayload.swift / PushCategoryFactory.swift

│  └ Вспомогательные источники данных

│

├─ Core/

│  ├ DesignTokens.swift

│  ├ L10n.swift

│  └ Расширения и утилиты

│

├ Resources/

│  ├ Localizable.strings

│  ├ Assets.xcassets

│  └ Mocks/

│

└─ Tests/

   ├ TravelBuddySnapshotUITests/
   
   ├ TravelBuddyUITests/
   
   └ SnapshotHelper.swift


---

## Автор

**Niiaz Khasanov**  
iOS Developer  
Swift 5 | Combine | SwiftUI | UIKit | Swinject | Clean Architecture  
