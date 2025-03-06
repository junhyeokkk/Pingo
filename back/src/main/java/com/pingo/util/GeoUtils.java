package com.pingo.util;
import org.springframework.data.geo.Point;

public class GeoUtils {

    private static final double EARTH_RADIUS_KM = 6371.0; // 지구 반지름 (단위: km)

    public static double calculateDistance(Point p1, Point p2) {
        double lat1 = Math.toRadians(p1.getY());
        double lon1 = Math.toRadians(p1.getX());
        double lat2 = Math.toRadians(p2.getY());
        double lon2 = Math.toRadians(p2.getX());

        double dlat = lat2 - lat1;
        double dlon = lon2 - lon1;

        double a = Math.pow(Math.sin(dlat / 2), 2)
                + Math.cos(lat1) * Math.cos(lat2) * Math.pow(Math.sin(dlon / 2), 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return EARTH_RADIUS_KM * c; // 거리 반환 (단위: km)
    }
}