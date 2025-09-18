//
//  POIRepository.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/1/25.
//


import Combine
import Foundation

public final class POIRepository: POIServiceProtocol {
    private let remote: POIServiceProtocol
    private let local: POIServiceProtocol
    private let cache: POICacheProtocol

    // TTL для обновления (можешь менять: 5 минут = 300 сек)
    private let ttl: TimeInterval = 300

    // in-flight общий publisher для дедупликации конкурентных запросов
    private let stateQueue = DispatchQueue(label: "poi.repo.state")
    private var inFlight: AnyPublisher<[POI], Error>?

    // хранение времени последнего успешного remote save (не меняем протокол кэша)
    private let lastRefreshKey = "poi.cache.lastRefreshAt"

    public init(remote: POIServiceProtocol,
                local: POIServiceProtocol,
                cache: POICacheProtocol) {
        self.remote = remote
        self.local  = local
        self.cache  = cache
    }

    public func fetchPOIs() -> AnyPublisher<[POI], Error> {
        let cached = loadCacheAsync()

        // если кэш свежий — отдаём его и выходим
        if isFresh() {
            return cached
        }

        // иначе: сразу отдаём содержимое кэша (если есть) и затем — обновление из сети
        // (если in-flight уже идёт — переиспользуем)
        let refresh = remoteOnceShared()
            .catch { [weak self] _ -> AnyPublisher<[POI], Error> in
                guard let self else {
                    return Fail(error: URLError(.unknown)).eraseToAnyPublisher()
                }
                // fallback: локальный JSON (и одновременно обновим кэш)
                return self.local.fetchPOIs()
                    .handleEvents(receiveOutput: { [weak self] pois in
                        self?.saveToCache(pois)
                    })
                    .eraseToAnyPublisher()
            }

        // cacheThenRefresh: сначала кэш, затем сеть
        return cached
            .filter { !$0.isEmpty }
            .append(refresh)
            .eraseToAnyPublisher()
    }

    // MARK: - Helpers

    private func loadCacheAsync() -> AnyPublisher<[POI], Error> {
        Deferred {
            Future<[POI], Error> { [weak self] promise in
                guard let self else {
                    promise(.failure(URLError(.unknown))); return
                }
                DispatchQueue.global(qos: .userInitiated).async {
                    let pois = self.cache.load()
                    promise(.success(pois))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func remoteOnceShared() -> AnyPublisher<[POI], Error> {
        // 1) если уже есть общий in-flight, вернём его
        if let shared = stateQueue.sync(execute: { inFlight }) {
            return shared
        }

        // 2) создаём новый, сохраняем в inFlight и шарим
        let publisher = remote.fetchPOIs()
            .handleEvents(receiveOutput: { [weak self] pois in
                self?.saveToCache(pois)
                self?.setLastRefresh(Date())
            }, receiveCompletion: { [weak self] _ in
                self?.stateQueue.async { self?.inFlight = nil }
            }, receiveCancel: { [weak self] in
                self?.stateQueue.async { self?.inFlight = nil }
            })
            .share()
            .eraseToAnyPublisher()

        stateQueue.async { [weak self] in self?.inFlight = publisher }
        return publisher
    }

    private func saveToCache(_ pois: [POI]) {
        // запись синхронная внутри реализаций; если будет дисковая — они уже у тебя в autoreleasepool
        cache.save(pois)
    }

    // MARK: - TTL

    private func isFresh(now: Date = Date()) -> Bool {
        guard let last = getLastRefresh() else { return false }
        return now.timeIntervalSince(last) < ttl
    }

    private func getLastRefresh() -> Date? {
        let t = UserDefaults.standard.double(forKey: lastRefreshKey)
        return t > 0 ? Date(timeIntervalSince1970: t) : nil
    }

    private func setLastRefresh(_ date: Date) {
        UserDefaults.standard.set(date.timeIntervalSince1970, forKey: lastRefreshKey)
    }
}
