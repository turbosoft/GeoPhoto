<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
<meta http-equiv="content-type" content="text/html; charset=utf-8"/>

<script type="text/javascript" src="http://maps.googleapis.com/maps/api/js?sensor=false&key=AIzaSyAZ4i-9lnjP3m46b2oqg4BlVxDmDfhExvU"></script>
<script type='text/javascript'>

/* --------------------- 내부 함수 --------------------*/
var map;

var map_type;	

var marker, view_marker;
var marker_latlng, view_marker_latlng;

var fov; //화각
var view_value; //촬영 거리

var draw_angle;

var direction_latlng;

var draw_direction;

function init() {
	//set map option
	var myOptions = { mapTypeId: google.maps.MapTypeId.ROADMAP };
	//create map
	map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
}

/* --------------------- 초기 설정 함수 --------------------*/

//촬영 지점 설정
function setCenter(lat_str, lng_str, type) {
	map_type = type;
	var lat = parseFloat(lat_str);
	var lng = parseFloat(lng_str);
	
	if(lat_str>0 && lng_str>0) { marker_latlng = new google.maps.LatLng(lat, lng); map.setZoom(16); }
	else { marker_latlng = new google.maps.LatLng(37.5663889, 126.9997222); map.setZoom(10); }
	
	var marker_image = "<c:url value='/images/geoImg/maps/photo_marker.png'/>";
	
	if(marker==null) {
		var drag = false;
		if(map_type==2) drag = true;
		marker = new google.maps.Marker({
			position: marker_latlng,
			map: map,
			title: "Center",
			icon: marker_image,
			draggable: drag
		});
	}
	else {
		marker.setPosition(marker_latlng);
	}
	
	map.setCenter(marker_latlng);
}
//촬영 각도와 거리를 계산하여 지도에 표현
function setAngle(direction_str, focal_str) {
	var direction = parseInt(direction_str);
	var focal = parseFloat(focal_str);
	
	fov = getFOV(focal);
	view_value = getViewLength(0.3); //km 단위
	
	if(direction>0 && focal>0) {
		setViewPoint(marker_latlng, view_value, direction);
		createViewPolygon(view_value, direction, fov);
		createViewPolyline(marker_latlng, direction_latlng);
		createViewMarker(direction_latlng);
	}
}
//화각 구하기
getFOV = function(focal_length) {
	var fov = (2 * Math.atan(3.626 / (2 * focal_length))) * 180 / Math.PI;
	return fov;
};
//촬영 거리 구하기
getViewLength = function(focus) {
	return focus;
};

//촬영 각도 및 거리에 맞추어 좌표 설정
function setViewPoint(point, km, direction) {
	var rad = (km * 1000) / 1609.344;
	var d2r = Math.PI / 180;
	var circleLatLngs = new Array();
	var circleLat = (rad / 3963.189) / d2r;
	var circleLng = circleLat / Math.cos(point.lat() * d2r);
	
	var theta = direction * d2r;
	var vertexLat = point.lat() + (circleLat * Math.cos(theta));
	var vertexLng = point.lng() + (circleLng * Math.sin(theta));
	direction_latlng = new google.maps.LatLng(parseFloat(vertexLat), parseFloat(vertexLng));
}
//촬영 범위를 폴리곤으로 표현
function createViewPolygon(km, direction, angle) {
	direction = parseInt(direction);
	var angle_val = angle / 2;
	var min_direction = direction - angle_val;
	if(min_direction<0) min_direction = min_direction + 360;
	var max_direction = direction + angle_val;
	if(max_direction>360) max_direction = Math.abs(360 - max_direction);
	
	var rad = (km * 1000) / 1609.344;
	var d2r = Math.PI / 180;
	var circleLatLngs = new Array();
	var circleLat = (rad / 3963.189) / d2r;
	var circleLng = circleLat / Math.cos(marker_latlng.lat() * d2r);
	circleLatLngs.push(marker_latlng);
	
	var theta, vertexLat, vertexLng, vertextLatLng;
	if(min_direction<max_direction) {
		for(var i=min_direction; i<max_direction; i++) {
			theta = i * d2r;
			vertexLat = marker_latlng.lat() + (circleLat * Math.cos(theta));
			vertexLng = marker_latlng.lng() + (circleLng * Math.sin(theta));
			vertextLatLng = new google.maps.LatLng(parseFloat(vertexLat), parseFloat(vertexLng));
			if(i==0) { circleLatLngs.push(marker_latlng); }
			if(i==direction) { direction_latlng = new google.maps.LatLng(parseFloat(vertexLat), parseFloat(vertexLng)); }
			circleLatLngs.push(vertextLatLng);
		}
	}
	else {
		for(var i=min_direction; i<361; i++) {
			theta = i * d2r;
			vertexLat = marker_latlng.lat() + (circleLat * Math.cos(theta));
			vertexLng = marker_latlng.lng() + (circleLng * Math.sin(theta));
			vertextLatLng = new google.maps.LatLng(parseFloat(vertexLat), parseFloat(vertexLng));
			if(i==min_direction) { circleLatLngs.push(marker_latlng); }
			if(i==direction) { direction_latlng = new google.maps.LatLng(parseFloat(vertexLat), parseFloat(vertexLng)); }
			circleLatLngs.push(vertextLatLng);
		}
		for(var i=0; i<max_direction; i++) {
			theta = i * d2r;
			vertexLat = marker_latlng.lat() + (circleLat * Math.cos(theta));
			vertexLng = marker_latlng.lng() + (circleLng * Math.sin(theta));
			vertextLatLng = new google.maps.LatLng(parseFloat(vertexLat), parseFloat(vertexLng));
			if(i==direction) { direction_latlng = new google.maps.LatLng(parseFloat(vertexLat), parseFloat(vertexLng)); }
			circleLatLngs.push(vertextLatLng);
		}
	}
	
	if(draw_angle!=null) draw_angle.setMap(null);
	
	draw_angle = new google.maps.Polygon({
		paths: circleLatLngs,
		strokeColor: "#FF0000",
		strokeOpacity: 0.8,
		strokeWeight: 2,
		fillColor: "#FF0000",
		fillOpacity: 0.3
	});
	draw_angle.setMap(map);
}
//촬영 위치와 촬영 범위 위치를 선으로 연결
function createViewPolyline(point1, point2) {
	var direction_arr = [point1, point2];
	
	if(draw_direction!=null) draw_direction.setMap(null);
	
	draw_direction = new google.maps.Polyline({
		path: direction_arr,
		strokeColor: "#0000FF",
		strokeOpacity: 1.0,
		strokeWeight: 2
	});
	draw_direction.setMap(map);
}
//촬영 범위 좌표 설정
function createViewMarker(point) {
	var marker_image = "<c:url value='/images/geoImg/maps/view_marker.png'/>";
	
	if(view_marker==null) {
		var drag = false;
		if(map_type==2) drag = true;
		view_marker = new google.maps.Marker({
			position: point,
			map: map,
			title: "View",
			icon: marker_image,
			draggable: drag
		});
	}
	else {
		view_marker.setPosition(point);
	}
	if(map_type==2) {
		google.maps.event.addListener(view_marker, 'dragend', function() {
			dragEvent(1);
		});
		google.maps.event.addListener(marker, 'dragend', function() {
			dragEvent(2);
		});
	}
}
//마커 드래그 이벤트
function dragEvent(type) {
	draw_direction.setPath([marker.getPosition(), view_marker.getPosition()]);
	if(type==2) { marker_latlng = new google.maps.LatLng(marker.getPosition().lat(), marker.getPosition().lng()); }
	var km = draw_direction.inKm();
	var degree = draw_direction.Bearing();
	createViewPolygon(km, degree, fov);
	
	parent.setExifData(marker.getPosition().lat(), marker.getPosition().lng(), parseInt(degree));
}

/* ---------------------------- 구글맵 확장 기능 --------------------------------- */
google.maps.LatLng.prototype.kmTo = function(a){
	var e = Math, ra = e.PI/180;
	var b = this.lat() * ra, c = a.lat() * ra, d = b - c; 
	var g = this.lng() * ra - a.lng() * ra;
	var f = 2 * e.asin(e.sqrt(e.pow(e.sin(d/2), 2) + e.cos(b) * e.cos(c) * e.pow(e.sin(g/2), 2)));
	return f * 6378.137; 
}; 
google.maps.Polyline.prototype.inKm = function(n){ 
	var a = this.getPath(n), len = a.getLength(), dist = 0; 
	for(var i=0; i<len-1; i++){ 
		dist += a.getAt(i).kmTo(a.getAt(i+1)); 
	}
	return dist;
};

google.maps.Polyline.prototype.Bearing = function(d){
	var path = this.getPath(d), len = path.getLength();
	var from = path.getAt(0);
	var to = path.getAt(len-1);
	if (from.equals(to)) {
		return 0;
	}
	var lat1 = from.latRadians();
	var lon1 = from.lngRadians();
	var lat2 = to.latRadians();
	var lon2 = to.lngRadians();
	
	var angle = - Math.atan2( Math.sin( lon1 - lon2 ) * Math.cos( lat2 ), Math.cos( lat1 ) * Math.sin( lat2 ) - Math.sin( lat1 ) * Math.cos( lat2 ) * Math.cos( lon1 - lon2 ) );
	if ( angle < 0.0 ) angle  += Math.PI * 2.0;
	if ( angle > Math.PI ) angle -= Math.PI * 2.0; 
	
	angle = parseFloat(angle.toDeg());
	if(-180<=angle && angle<0) angle += 360;
	return angle;
};

google.maps.LatLng.prototype.latRadians = function() {
	return this.lat() * Math.PI/180;
};

google.maps.LatLng.prototype.lngRadians = function() {
	return this.lng() * Math.PI/180;
};

Number.prototype.toDeg = function() {
	return this * 180 / Math.PI;
};

</script>
</head>

<body style='margin:0px; padding:0px;' onload='init();'>
	<div id="map_canvas" style="width:100%; height:100%;"></div>
</body>
</html>
