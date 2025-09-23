// Core/DeepLink/MapIntent.swift
import CoreLocation

public enum MapIntent {
    case center(CLLocationCoordinate2D)
    case focusPOI(id: Int)
}