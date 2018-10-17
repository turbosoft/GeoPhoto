<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>

<%
 response.setHeader("Cache-Control","no-cache");
 response.setHeader("Pragma","no-cache");
 response.setDateHeader("Expires",0);
%>

<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
<meta http-equiv="content-type" content="text/html; charset=utf-8"/>

<jsp:include page="../../page_common.jsp"></jsp:include>
<!-- <script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?v=3&key=AIzaSyAth-_FyQxRomNh2JkI_MvAWXRJuLOEXNI&language=ko&region=KR"></script> -->
<script type="text/javascript" src="http://maps.googleapis.com/maps/api/js?key=AIzaSyAth-_FyQxRomNh2JkI_MvAWXRJuLOEXNI&v=3.exp&sensor=false&libraries=places,geometry&language=en&region=ER"></script>
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

var circle;

var imgDMarkerLat = 0;		//default marker latitude
var imgDMarkerLng = 0;		//default marker longitude
var imgDMapZoom = 10;		//defalut map zoom
var imgCoordinate = false;	//coordinate boolean

function init() {
	if(map == null || map == undefined){
		//set map option
		var myOptions = { mapTypeId: google.maps.MapTypeId.ROADMAP };
		//create map
		map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
	}
}

//base map setting
function setDefaultData(dMarkerLat, dMarkerLng, dMapZoom){
	imgDMarkerLat = dMarkerLat;
	imgDMarkerLng = dMarkerLng;
	imgDMapZoom = dMapZoom;
}

/* --------------------- 초기 설정 함수 --------------------*/

//촬영 지점 설정
function setCenter(lat_str, lng_str, type) {
	map_type = type;
	var lat = parseFloat(lat_str);
	var lng = parseFloat(lng_str);
	
	if(map == null || map == undefined){
		init();
	}
	
	if(lat_str!=0 && lng_str!=0) {
		marker_latlng = new google.maps.LatLng(lat, lng); map.setZoom(16);
	}else{
		if(imgDMarkerLat == null || imgDMarkerLat == ""){
			imgDMarkerLat = 37.5663889;
    	}
    	if(imgDMarkerLng == null || imgDMarkerLng == ""){
    		imgDMarkerLng = 126.9997222;
    	}
		marker_latlng = new google.maps.LatLng(imgDMarkerLat, imgDMarkerLng);
		map.setZoom(imgDMapZoom);
	}
	
// 	var marker_image = "<c:url value='/images/geoImg/maps/photo_marker.png'/>";
	var marker_image = "http://maps.google.com/mapfiles/ms/icons/red-dot.png";

	if(marker == null || marker == undefined) {
		var drag = false;
		if(map_type==2) drag = true;
		marker = new google.maps.Marker({
			position: marker_latlng,
			map: map,
			title: "Center",
			icon: marker_image,
			draggable: drag
		});
		if(map_type==2){
			google.maps.event.addListener(marker, 'dragend', function() {
				dragEventEmpty();
			});
		}
	}
	else {
		marker.setPosition(marker_latlng);
	}
	
	map.setCenter(marker_latlng);
	
	if(!(type == 2 && $('#map_canvas').width() > 330)){
		bounds = new google.maps.LatLngBounds();
		bounds.extend(marker_latlng);
		map.fitBounds(bounds);
	}
}
var bounds = new google.maps.LatLngBounds();

//촬영 각도와 거리를 계산하여 지도에 표현
function setAngle(direction_str, focal_str) {
	var direction = parseInt(direction_str);
	var focal = parseFloat(focal_str);
	parent.setNewDirection = direction_str;
	parent.setNewFocal = focal_str; 
	
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
	//var diagonalLength = Math.sqrt(Math.pow(36, 2) + Math.pow(24, 2));
	//var diagonalLength = Math.sqrt(Math.pow(3.626, 2) + Math.pow(2.709, 2));
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
	
	if(view_marker==null || marker == undefined) {
		var drag = false;
		if(map_type==2 || imgCoordinate) drag = true;
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
	if(map_type==2 || imgCoordinate) {
		google.maps.event.addListener(view_marker, 'dragend', function() {
			dragEvent(1);
		});
		google.maps.event.addListener(marker, 'dragend', function() {
			dragEvent(2);
		});
	}

	if(!imgCoordinate){
		bounds.extend(point);
		map.fitBounds(bounds);
	}
}
//마커 드래그 이벤트
function dragEvent(type) {
	draw_direction.setPath([marker.getPosition(), view_marker.getPosition()]);
	if(type==2 || imgCoordinate) {marker_latlng = new google.maps.LatLng(marker.getPosition().lat(), marker.getPosition().lng());}
	var km = draw_direction.inKm();
	var degree = draw_direction.Bearing();
	parent.setNewDirection = degree;
	parent.setNewFocal = 3.626 / (2 * Math.tan(Math.PI * fov / 360));
// 	double fov = (2 * Math.atan(diagonalLength / (2 * focalLength))) * 180 / Math.PI;
// 	var fov = (2 * Math.atan(3.626 / (2 * focal_length))) * 180 / Math.PI;
// 	 double focal = 3.626 / (2 * Math.tan(Math.PI * fov / 360));
	
	createViewPolygon(km, degree, fov);
	parent.setExifData(marker.getPosition().lat(), marker.getPosition().lng(), parseInt(degree));
}

//좌표없는 마커 드래그 이벤트
function dragEventEmpty() {
	parent.setExifData(marker.getPosition().lat(), marker.getPosition().lng(), 0);
	if(circle!=null){
		drawCircleOnMap(marker.getPosition().lat(), marker.getPosition().lng(), 100, 2);
	}
}

/**
 * 반경 그리기
 * @param : xy 좌표, 반경사이즈
 */
function drawCircleOnMap(lat_str, lng_str, radius, rType){ //반경중앙좌표, 반경(단위: m)
 	var lat = parseFloat(lat_str);
	var lng = parseFloat(lng_str);
	
	if(circle!=null) circle.setMap(null);
    circle = new google.maps.Circle({
        strokeColor: '#07aca5', //원 바깥 선 색
        strokeOpacity: 0.8, // 바깥 선 투명도
        strokeWeight: 1, //바깥 선 두께
        fillColor: '#07aca5', //선안의 색
        fillOpacity: 0.2,// 토명도
        center: {lat: lat, lng: lng}, //위치 좌표
        radius: Number(radius) // 반경, 단위: m
    });
    
    circle.setMap(map);// 반경을 추가할 map에 set
    if(rType == 1){
    	bounds.union(circle.getBounds());
        map.fitBounds(bounds);
    }
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

//-------------------------------------------------------------좌표 추가------------------------------------------------

//촬영 지점 설정
function graySetCenter() {
	imgCoordinate = true;
	bounds = new google.maps.LatLngBounds();
	
	if(map == null || map == undefined){
		//set map option
		var myOptions = { mapTypeId: google.maps.MapTypeId.ROADMAP };
		//create map
		map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
	}
	
	if(imgDMarkerLat == null || imgDMarkerLat == "" || imgDMarkerLat == 0){
		imgDMarkerLat = 37.5663889;
	}
	if(imgDMarkerLng == null || imgDMarkerLng == "" || imgDMarkerLng == 0){
		imgDMarkerLng = 126.9997222;
	}
	marker_latlng = new google.maps.LatLng(imgDMarkerLat, imgDMarkerLng);
	map.setZoom(imgDMapZoom);
	
// 	var marker_image = "<c:url value='/images/geoImg/maps/photo_marker.png'/>";
	var marker_image = "http://maps.google.com/mapfiles/ms/icons/red-dot.png";

 	if(marker == null || marker == undefined){
 		marker = new google.maps.Marker({
 			position: marker_latlng,
 			map: map,
 			title: "Center",
 			icon: marker_image,
 			draggable: true
 		});
 	}else{
 		marker.setPosition(marker_latlng);
 	}
		
	map.setCenter(marker_latlng);
	
	$('#searchDefaultPlace').val("");
	
	map.setOptions({
		streetViewControl: false,
	    scaleControl:false,
	    mapTypeControl: false,
	    scaleControl : false
	});
	
	google.maps.event.addListener(map, 'click', function(event) {
		var latitude = event.latLng.lat();
	    var longitude = event.latLng.lng();
	    marker.setPosition(event.latLng);
	    marker_latlng = new google.maps.LatLng(latitude, longitude);
	    setAngle(100, 5);
    });
	//앵글 추가
	setAngle(100, 5);
	
	$('.imgModeCls2').css('display','block');
	
	mapAutocomplete = new google.maps.places.Autocomplete(
            /** @type {!HTMLInputElement} */ (
                document.getElementById('searchDefaultPlace')), {
//	              types: ['(cities)'],
//	              componentRestrictions: countryRestrict
    });
    places = new google.maps.places.PlacesService(map);
    mapAutocomplete.addListener('place_changed', onPlaceChanged);
}

var mapAutocomplete = null;
//place text click
function onPlaceChanged() {
	var place = mapAutocomplete.getPlace();
    if (place.geometry) {
      map.panTo(place.geometry.location);
      map.setZoom(15);
      marker.setPosition(place.geometry.location);
      marker_latlng = new google.maps.LatLng(place.geometry.location);
      setAngle(100, 5);
    }else {
      document.getElementById('searchDefaultPlace').placeholder = 'Enter a city';
    }
}

function grayMarkerSet(setType){
	imgCoordinate = false;
	if(setType == 'ok'){
// 		$('.imgModeCls2').css('display','none');
		parent.setNewMarkerLat = marker.getPosition().lat();
		parent.setNewMarkerLng = marker.getPosition().lng();
		google.maps.event.clearListeners(map, 'click');
		marker.setDraggable = false;
		
	}else if(setType == 'cancel'){
		if(marker != null && marker != undefined){
			marker.setDraggable = false;
			google.maps.event.clearListeners(map, 'click');
			$('.imgModeCls2').css('display','none');
		}
		
	}else if(setType == 'reset'){
		setNewMarkerLat = imgDMarkerLat;
		setNewMarkerLng = imgDMarkerLng;
		
		marker_latlng = new google.maps.LatLng(imgDMarkerLat, imgDMarkerLng);
		map.setZoom(imgDMapZoom);
		map.setCenter(marker_latlng);
	}
}
</script>
</head>

<body style='margin:0px; padding:0px;' onload='init();'>
	<!-- center setting -->
<!-- 	<div class="imgModeCls1" id="morkerModeOpen" onclick="defaultMarkerSet('open');" style="display: none; height: 30px;width: 130px;position: absolute;left: 100px;top: 10px;z-index: 9;background-color: #ffffff;text-align: center;cursor: pointer;"> -->
<!-- 		<div style="margin-top: 3px; display: inline-block;">Set default location</div> -->
<!-- 	</div> -->
	<div class="imgModeCls2" id="morkerModeReset" onclick="grayMarkerSet('reset');" style="display: none; height: 30px;width: 50px;position: absolute;left: 105px;top: 10px;z-index: 9;background-color: #ffffff;text-align: center;cursor: pointer;">
		<div style="margin-top: 3px; display: inline-block;">Reset</div>
	</div>
	
	<div class="imgModeCls2" style="display: none;height: 30px;width: 290px;position: absolute;left: 40px;/* top: 10px; */z-index: 9;text-align: center;cursor: pointer;">
		<input type="text" id="searchDefaultPlace" style="margin-top: 3px; display: inline-block; width: 100%;" placeholder="Enter location">
	</div>
	
	<div id="map_canvas" style="width:100%; height:100%;"></div>
</body>
</html>
