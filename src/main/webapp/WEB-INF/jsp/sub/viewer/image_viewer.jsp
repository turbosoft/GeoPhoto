<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">

<jsp:include page="../../page_common.jsp"></jsp:include>

<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");

String loginId = request.getParameter("loginId");
String loginType = request.getParameter("loginType");
String loginToken = request.getParameter("loginToken");

String idx = request.getParameter("idx");			//idx
String user_id = request.getParameter("user_id");	//user id
String file_url = request.getParameter("file_url");	//file url ex) upload/file.jpg
String b_contentTabArr = request.getParameter("b_contentTabArr");	//contentTab array
String projectUserId = request.getParameter("projectUserId");	//project User id
%>

<script type="text/javascript" charset="utf-8">
var loginId = '<%= loginId %>';				// 로그인 아이디
var loginType = '<%= loginType %>';			// 로그인 타입
var loginToken = '<%= loginToken %>';		// 로그인 token
var projectUserId = '<%= projectUserId %>';		//project User id

var idx = '<%= idx %>';
var user_id = '<%= user_id %>';
var b_contentTabArr = "<%=b_contentTabArr%>";	//content tab array
var request = null;		//request;
var projectBoard = 0;	//GeoCMS 연동여부		0:연동안됨, 1:연동됨

var file_url = '<%= file_url %>';
var base_url = '';
var upload_url = '';
var editUserYN  = 0;						//편집가능여부

$(function() {
	$('.image_write_button').button();
	$('.image_write_button').width(80);
	$('.image_write_button').height(25);
	$('.image_write_button').css('fontSize', 12);
	
	$('.image_setting_button').button();
	$('.image_setting_button').width(80);
	$('.image_setting_button').height(25);
	$('.image_setting_button').css('fontSize', 12);

	$('#image_map_area').maxZIndex({inc:1});
	
	callRequest();
});

//GeoCMS 연결여부 확인 function
function callRequest(){
	var textUrl = 'geoSetChkBoard.do';
	httpRequest(textUrl);
	request.open("POST", "http://"+location.host + "/GeoCMS/" + textUrl, true);
	request.send();
}

//GeoCMS 연결 여부 확인
function httpRequest(textUrl){
	if(window.XMLHttpRequest){
		try{
			request = new XMLHttpRequest();
		}catch(e){
			request = null;
		}

	}else if(window.ActiveXObject){
		//* IE
		try{
			request = new ActiveXObject("Msxml2.XMLHTTP");
		}catch(e){
			//* Old Version IE
			try{
				request = new ActiveXObject("Microsoft.XMLHTTP");
			}catch(e){
				request = null;
			}
		}
	}

	request.onreadystatechange = function(){
		if(request.readyState == 4 && request.status == 200){
			projectBoard = 1;
		}
		if(request.readyState == 4){
			if(projectBoard == 1){
				base_url = 'http://'+ location.host + '/GeoCMS';
				upload_url = '/upload/GeoPhoto/';
				
				if(loginId != null && loginId != '' && loginId != 'null' && ((loginId == user_id && loginType != 'WRITE') || loginType == 'ADMIN')){
// 					$('#makeImageBtn').css('display', 'block');
					$('body').append('<img src="<c:url value="/images/geoImg/viewer/write_btn.jpg"/>" onclick="imageWrite();" style="position:absolute; left:880px; top:565px; width:140px; height:35px; display:block; cursor: pointer;" id="makeImageBtn">');
				}else{
					if(editUserCheck() == 1 ||  (loginId != null && loginId != '' && loginId != 'null' && projectUserId == loginId)){
						
						$('body').append('<img src="<c:url value="/images/geoImg/viewer/write_btn.jpg"/>" onclick="imageWrite();" style="position:absolute; left:880px; top:565px; width:140px; height:35px; display:block; cursor: pointer;" id="makeImageBtn">');
// 						$('#makeImageBtn').css('display', 'block');
					}
				}
			}else{
				base_url = '<c:url value="/"/>';
				upload_url = '/upload/';
				$('body').append('<img src="<c:url value="/images/geoImg/viewer/write_btn.jpg"/>" onclick="imageWrite();" style="position:absolute; left:880px; top:565px; width:140px; height:35px; display:block; cursor: pointer;" id="makeImageBtn">');
// 				$('#makeImageBtn').css('display', 'block');
			}
		}
	}
}

//편집 가능 유저 확인
function editUserCheck(){
	var Url			= baseRoot() + "cms/getShareUser/";
	var param		= loginToken + "/" + loginId + "/" + idx + "/GeoPhoto";
	var callBack	= "?callback=?";
	editUserYN  = 0;
	
	$.ajax({
		  type	: "get"
		, url	: Url + param + callBack
		, dataType	: "jsonp"
		, async	: false
		, cache	: false
		, success: function(response) {
			if(response.Code == 100 && response.Data[0].SHAREEDIT == 'Y'){
				editUserYN = 1;
			}
		}
	});
	
	return editUserYN;
}

//on load function
function imageViewerInit() {
	//이미지 그리기
	changeImage();
}

//이미지 그리기
function changeImage() {
	var img = new Image();
	img.src = base_url + upload_url + file_url;
	
	img.onload = function() {
		//이미지 Resize
		var result_arr;
		var margin = 10;
		var width = $('#image_main_area').width();
		var height = $('#image_main_area').height();
		
		result_arr = resizeImage(width, height, img.width, img.height, margin);
		//canvas 의 width height 비율과 다른 이미지의 경우 축소하여도 y 축이 음수가 나오는 경우를 처리하기 위함
		while(result_arr[1]<3) {
			margin += 10;
			result_arr = resizeImage(width, height, img.width, img.height, margin);
		}
		
		var img_element = $(document.createElement('img'));
		img_element.attr('id', 'image_write_canvas');
		img_element.attr('src',  base_url + upload_url + file_url);
		img_element.attr('style', 'position:absolute; left:'+result_arr[0]+'px; top:'+result_arr[1]+'px;');
		img_element.attr('width', result_arr[2]);
		img_element.attr('height', result_arr[3]);
		img_element.appendTo('#image_main_area');

		//XML 로드
		loadXML();

		//EXIF 로드
		loadExif();
	};
}

//image size reset
function resizeImage(canvas_width, canvas_height, img_width, img_height, margin) {
	var min; var max; var ratio;
	if(img_width>img_height) { min = img_height; max = img_width; ratio = (canvas_width-margin) / max; }
	else { min = img_width; max = img_height; ratio = (canvas_height-margin) / max; }
	var resize_width = img_width * ratio; var resize_height = img_height * ratio;
	var x = (canvas_width - resize_width) / 2; var y = (canvas_height - resize_height) / 2;
	var result_arr = new Array();
	result_arr.push(x); result_arr.push(y); result_arr.push(resize_width); result_arr.push(resize_height);
	return result_arr;
}

/* xml_start ------------------------------------ XML 설정 ------------------------------------- */

//소스가 길어서 따로 함수로 생성
function autoCreateText(id, font_size, font_color, bg_color, bold, italic, underline, href, text, top, left) {
	if(id == "c") {
		if(font_size == 'H3') $('#caption_font_select').val('H3');
		else if(font_size == 'H2') $('#caption_font_select').val('H2');
		else if(font_size == 'H1') $('#caption_font_select').val('H1');
		else $('#caption_font_select').val('Normal');
		
		$('#caption_font_color').val(font_color);
		if(bg_color!='none') { $('#caption_bg_color').val(bg_color); $('input[name=caption_bg_checkbok]').attr('checked', false); }
		else { bg_color = '#FFFFFF'; $('input[name=caption_bg_checkbok]').attr('checked', true); }
		
		var check_html = "";
		if(bold == 'true') check_html += '<input type="checkbox" id="caption_bold" class="caption_bold" checked="checked" /><label for="caption_bold" style="width:30px; height:30px;">Bold</label>';
		else check_html += '<input type="checkbox" id="caption_bold" class="caption_bold" /><label for="caption_bold" style="width:30px; height:30px;">Bold</label>';
		if(italic == 'true') check_html += '<input type="checkbox" id="caption_italic" class="caption_italic" checked="checked" /><label for="caption_italic" style="width:30px; height:30px;">Italic</label>';
		else check_html += '<input type="checkbox" id="caption_italic" class="caption_italic" /><label for="caption_italic" style="width:30px; height:30px;">Italic</label>';
		if(underline == 'true') check_html += '<input type="checkbox" id="caption_underline" class="caption_underline" checked="checked" /><label for="caption_underline" style="width:30px; height:30px;">Underline</label>';
		else check_html += '<input type="checkbox" id="caption_underline" class="caption_underline" /><label for="caption_underline" style="width:30px; height:30px;">Underline</label>';
		if(href == 'true') check_html += '<input type="checkbox" id="caption_link" class="caption_link" checked="checked" /><label for="caption_link" style="width:30px; height:30px;">HyperLink</label>';
		else check_html += '<input type="checkbox" id="caption_link" class="caption_link" /><label for="caption_link" style="width:30px; height:30px;">HyperLink</label>';
		$('#caption_check').html(check_html);
		$('#caption_text').val(text);
		
		createCaption();
		var obj = $('#'+auto_caption_str);
		obj.attr('style', 'position:absolute; left:'+left+'px; top:'+top+'px; display:block;');
	}
	else if(id == "b") {
		if(font_size == 'H3') $('#bubble_font_select').val('H3');
		else if(font_size == 'H2') $('#bubble_font_select').val('H2');
		else if(font_size == 'H1') $('#bubble_font_select').val('H1');
		else $('#bubble_font_select').val('Normal');
		
		$('#bubble_font_color').val(font_color);
		if(bg_color!='none') { $('#bubble_bg_color').val(bg_color); $('input[name=bubble_bg_checkbok]').attr('checked', false); }
		else { bg_color = '#FFFFFF'; $('input[name=bubble_bg_checkbok]').attr('checked', true); }
		
		var check_html = "";
		if(bold == 'true') check_html += '<input type="checkbox" id="bubble_bold" class="bubble_bold" checked="checked" /><label for="bubble_bold" style="width:30px; height:30px;">Bold</label>';
		else check_html += '<input type="checkbox" id="bubble_bold" class="bubble_bold" /><label for="bubble_bold" style="width:30px; height:30px;">Bold</label>';
		if(italic == 'true') check_html += '<input type="checkbox" id="bubble_italic" class="bubble_italic" checked="checked" /><label for="bubble_italic" style="width:30px; height:30px;">Italic</label>';
		else check_html += '<input type="checkbox" id="bubble_italic" class="bubble_italic" /><label for="bubble_italic" style="width:30px; height:30px;">Italic</label>';
		if(underline == 'true') check_html += '<input type="checkbox" id="bubble_underline" class="bubble_underline" checked="checked" /><label for="bubble_underline" style="width:30px; height:30px;">Underline</label>';
		else check_html += '<input type="checkbox" id="bubble_underline" class="bubble_underline" /><label for="bubble_underline" style="width:30px; height:30px;">Underline</label>';
		if(href == 'true') check_html += '<input type="checkbox" id="bubble_link" class="bubble_link" checked="checked" /><label for="bubble_link" style="width:30px; height:30px;">HyperLink</label>';
		else check_html += '<input type="checkbox" id="bubble_link" class="bubble_link" /><label for="bubble_link" style="width:30px; height:30px;">HyperLink</label>';
		$('#bubble_check').html(check_html);
		text = text.replace(/@line@/g, "\r\n");
		$('#bubble_text').val(text);
		
		createBubble();
		var obj = $('#'+auto_bubble_str);
		obj.attr('style', 'position:absolute; left:'+left+'px; top:'+top+'px; display:block;');
	}
}

var auto_caption_str;
var auto_caption_num = 0;
function createCaption() {
	auto_caption_str = "c" + auto_caption_num;
	
	var font_size = $('#caption_font_select').val(); var font_color = $('#caption_font_color').val(); var bg_color = $('#caption_bg_color').val(); var bg_check = $('input[name=caption_bg_checkbok]').attr('checked'); var bold_check = $('#caption_bold').attr('checked'); var italic_check = $('#caption_italic').attr('checked'); var underline_check = $('#caption_underline').attr('checked'); var link_check = $('#caption_link').attr('checked'); var text = $('#caption_text').val();
	if(bg_check==true) bg_color = '';
	var html_text;
	//폰트, 색상 설정
	if(font_size=='H3') html_text = '<font id="f'+auto_caption_str+'" style="font-size:14px; color:'+font_color+';"><pre id="p'+auto_caption_str+'" style="font-size:14px;background:'+bg_color+';">'+text+'</pre></font>';
	else if(font_size=='H2') html_text = '<font id="f'+auto_caption_str+'" style="font-size:18px; color:'+font_color+';"><pre id="p'+auto_caption_str+'" style="font-size:18px;background:'+bg_color+';">'+text+'</pre></font>';
	else if(font_size=='H1') html_text = '<font id="f'+auto_caption_str+'" style="font-size:22px; color:'+font_color+';"><pre id="p'+auto_caption_str+'" style="font-size:22px;background:'+bg_color+';">'+text+'</pre></font>';
	else html_text = '<font id="f'+auto_caption_str+'" style="color:'+font_color+';"><pre id="p'+auto_caption_str+'" style="background:'+bg_color+';">'+text+'</pre></font>';
	//bold, italic, underline, hyperlink 설정
	if(bold_check==true) html_text = '<b id="b'+auto_caption_str+'">'+html_text+'</b>';
	if(italic_check==true) html_text = '<i id="i'+auto_caption_str+'">'+html_text+'</i>';
	if(underline_check==true) html_text = '<u id="u'+auto_caption_str+'">'+html_text+'</u>';
	if(link_check==true) {
		if(html_text.indexOf('http://')== -1) html_text = '<a href="http://'+text+'" id="h'+auto_caption_str+'" target="_blank">'+html_text+'</a>';
		else html_text = '<a href="'+text+'" id="h'+auto_caption_str+'" target="_blank">'+html_text+'</a>';
	}
	
	var div_element = $(document.createElement('div'));
	div_element.attr('id', auto_caption_str); div_element.attr('style', 'position:absolute; left:10px; top:10px; display:block;'); div_element.html(html_text); div_element.appendTo('#image_main_area');
	
	auto_caption_num++;
	
	var data_arr = new Array();
	data_arr.push(auto_caption_str); data_arr.push("Caption"); data_arr.push(text);
	insertTableObject(data_arr);
}

var auto_bubble_str;
var auto_bubble_num = 0;
function createBubble() {
	auto_bubble_str = "b" + auto_bubble_num;
	var font_size = $('#bubble_font_select').val(); var font_color = $('#bubble_font_color').val(); var bg_color = $('#bubble_bg_color').val(); var bg_check = $('input[name=bubble_bg_checkbok]').attr('checked'); var bold_check = $('#bubble_bold').attr('checked'); var italic_check = $('#bubble_italic').attr('checked'); var underline_check = $('#bubble_underline').attr('checked'); var link_check = $('#bubble_link').attr('checked'); var text = $('#bubble_text').val();
	if(bg_check==true) bg_color = '';
	var html_text;
	//폰트, 색상 설정
	if(font_size=='H3') html_text = '<font id="f'+auto_bubble_str+'" style="font-size:14px; color:'+font_color+';"><pre id="p'+auto_bubble_str+'" style="font-size:14px;background:'+bg_color+';">'+text+'</pre></font>';
	else if(font_size=='H2') html_text = '<font id="f'+auto_bubble_str+'" style="font-size:18px; color:'+font_color+';"><pre id="p'+auto_bubble_str+'" style="font-size:18px;background:'+bg_color+';">'+text+'</pre></font>';
	else if(font_size=='H1') html_text = '<font id="f'+auto_bubble_str+'" style="font-size:22px; color:'+font_color+';"><pre id="p'+auto_bubble_str+'" style="font-size:22px;background:'+bg_color+';">'+text+'</pre></font>';
	else html_text = '<font id="f'+auto_bubble_str+'" style="color:'+font_color+';"><pre id="p'+auto_bubble_str+'" style="background:'+bg_color+';">'+text+'</pre></font>';
	//bold, italic, underline, hyperlink 설정
	if(bold_check==true) html_text = '<b id="b'+auto_bubble_str+'">'+html_text+'</b>';
	if(italic_check==true) html_text = '<i id="i'+auto_bubble_str+'">'+html_text+'</i>';
	if(underline_check==true) html_text = '<u id="u'+auto_bubble_str+'">'+html_text+'</u>';
	if(link_check==true) {
		if(html_text.indexOf('http://')== -1) html_text = '<a href="http://'+text+'" id="h'+auto_bubble_str+'" target="_blank">'+html_text+'</a>';
		else html_text = '<a href="'+text+'" id="h'+auto_bubble_str+'" target="_blank">'+html_text+'</a>';
	}
	
	var div_element = $(document.createElement('div')); div_element.attr('id', auto_bubble_str); div_element.attr('style', 'position:absolute; left:10px; top:10px; display:block;'); div_element.html(html_text); div_element.appendTo('#image_main_area');

	auto_bubble_num++;

	var data_arr = new Array();
	data_arr.push(auto_bubble_str); data_arr.push("Bubble"); data_arr.push(text);
	insertTableObject(data_arr);
}

var auto_icon_str;
var auto_icon_num = 0;
function createIcon(img_src) {
	auto_icon_str = "i" + auto_icon_num;
	
	var img_element = $(document.createElement('img'));
	img_element.attr('id', auto_icon_str);
	img_element.attr('src', img_src);
	img_element.attr('style', 'position:absolute; display:block; left:30px; top:30px;');
	img_element.attr('width', 100);
	img_element.attr('height', 100);
	img_element.appendTo('#image_main_area');
	$('#'+img_element.attr('id')).resizable().parent().draggable();
	$('#'+img_element.attr('id')).contextMenu('context2', {
		bindings: {
			'context_delete': function(t) {
// 				jConfirm('정말 삭제하시겠습니까?', '정보', function(type){ if(type) $('#'+t.id).remove(); removeTableObject(t.id); });
				jConfirm('Are you sure you want to delete?', 'Info', function(type){ if(type) $('#'+t.id).remove(); removeTableObject(t.id); });
			}
		}
	});
	
	auto_icon_num++;
	
	var data_arr = new Array();
	data_arr.push(auto_icon_str); data_arr.push("Image"); data_arr.push(img_src);
	insertTableObject(data_arr);
}

//Geometry Common Value
var auto_geometry_str; 
var auto_geometry_num = 0; 

var geometry_point_arr_1 = new Array(); 
var geometry_point_arr_2 = new Array();

var geometry_total_arr_1 = new Array(); 
var geometry_total_arr_2 = new Array();

var geometry_total_arr_buf_1 = new Array(); 
var geometry_total_arr_buf_2 = new Array();

//Geometry Circle & Rect Value
var geometry_click_move_val = false; 
var geometry_click_move_point_x = 0; 
var geometry_click_move_point_y = 0;

//Geometry Point Value
var geometry_point_before_x = 0; 
var geometry_point_before_y = 0; 
var geometry_point_num = 1;

function createGeometry(type) {
	auto_geometry_str = "g" + auto_geometry_num;
	
	var min_x, max_x, min_y, max_y;
	if(type==1 || type==2) {
		if(geometry_point_arr_1[0] < geometry_point_arr_1[1]) { min_x = geometry_point_arr_1[0]; max_x = geometry_point_arr_1[1]; }
		else { min_x = geometry_point_arr_1[1]; max_x = geometry_point_arr_1[0]; }
		if(geometry_point_arr_2[0] < geometry_point_arr_2[1]) { min_y = geometry_point_arr_2[0]; max_y = geometry_point_arr_2[1]; }
		else { min_y = geometry_point_arr_2[1]; max_y = geometry_point_arr_2[0]; }
	}
	else {
		//좌표점에서 사각형 찾기
		min_x = Math.min.apply(Math, geometry_point_arr_1);
		max_x = Math.max.apply(Math, geometry_point_arr_1);
		min_y = Math.min.apply(Math, geometry_point_arr_2);
		max_y = Math.max.apply(Math, geometry_point_arr_2);
	}
	var left = min_x; var top = min_y; var width = max_x - min_x; var height = max_y - min_y;
	var left_str = $('#image_write_canvas').css('left'); var top_str = $('#image_write_canvas').css('top');
	var left_offset = parseInt(left_str.replace('px','')); var top_offset = parseInt(top_str.replace('px',''));
	left += left_offset; top += top_offset;
	//canvas 객체 삽입
	var canvas_element = $(document.createElement('canvas'));
	canvas_element.attr('id', auto_geometry_str);
	canvas_element.attr('style', 'position:absolute; display:block; left:'+left+'px; top:'+top+'px;');
	canvas_element.attr('width', width);
	canvas_element.attr('height', height);
	canvas_element.mouseover(function() {
		mouseeventGeometry(this.id, true, type);
	});
	canvas_element.mouseout(function() {
		mouseeventGeometry(this.id, false, type);
	});
	canvas_element.appendTo('#image_main_area');

	//canvas 객체에 Geometry 그리기
	var canvas = $('#'+auto_geometry_str);
	var context = canvas[0].getContext("2d");
	
	var x, y;
	var x_str = auto_geometry_str+'@'+left+'@'; var y_str = auto_geometry_str+'@'+top+'@';
	var x_str_buf = auto_geometry_str+'@'+left+'@'; var y_str_buf = auto_geometry_str+'@'+top+'@';
	
	var line_color = $('#geometry_line_color').val();
	line_color = line_color.substring(1, line_color.length);
	var bg_color = $('#geometry_bg_color').val();
	bg_color = bg_color.substring(1, bg_color.length);
	context.strokeStyle = css3color(line_color, 1);
	context.lineWidth = 1;
	
	if(type==1) {
		x = 0;
		y = 0;
		width = max_x - min_x; height = max_y - min_y;
		var kappa = .5522848;
			ox = (width/2) * kappa, oy = (height/2) * kappa, xe = x + width, ye = y + height, xm = x + width/2, ym = y + height/2;
		context.beginPath();
		context.moveTo(x, ym);
		context.bezierCurveTo(x, ym - oy, xm - ox, y, xm, y); context.bezierCurveTo(xm + ox, y, xe, ym - oy, xe, ym); context.bezierCurveTo(xe, ym + oy, xm + ox, ye, xm, ye); context.bezierCurveTo(xm - ox, ye, x, ym + oy, x, ym);
		context.closePath(); context.stroke();
		x_str += x + '_' + width + '@' + line_color; y_str += y + '_' + height + '@' + bg_color + '@circle';
		x_str_buf += geometry_point_arr_1[0] + '_' + geometry_point_arr_1[1] + '@' + line_color; y_str_buf += geometry_point_arr_2[0] + '_' + geometry_point_arr_2[1] + '@' + bg_color + '@circle';
	}
	else if(type==2) {
		width = max_x - min_x; height = max_y - min_y;
		context.strokeRect(0, 0, width, height);
		x_str += 0 + '_' + width + '@' + line_color; y_str += 0 + '_' + height + '@' + bg_color + '@rect';
		x_str_buf += geometry_point_arr_1[0] + '_' + geometry_point_arr_1[1] + '@' + line_color; y_str_buf += geometry_point_arr_2[0] + '_' + geometry_point_arr_2[1] + '@' + bg_color + '@rect';
	}
	else {
		context.beginPath();
		for(var i=0; i<geometry_point_arr_1.length; i++) {
			x = Math.abs(left - geometry_point_arr_1[i] - left_offset);
			y = Math.abs(top - geometry_point_arr_2[i] - top_offset);
			if(i==0) context.moveTo(x, y);
			else context.lineTo(x, y);
			if(i==geometry_point_arr_1.length-1) { x_str += x + '@' + line_color; y_str += y + '@' + bg_color + '@point'; }
			else { x_str += x + '_'; y_str += y + '_'; }
			if(i==geometry_point_arr_1.length-1) { x_str_buf += geometry_point_arr_1[i] + '@' + line_color; y_str_buf += geometry_point_arr_2[i] + '@' + bg_color + '@point'; }
			else { x_str_buf += geometry_point_arr_1[i] + '_'; y_str_buf += geometry_point_arr_2[i] + '_'; }
		}
		context.closePath();
		context.stroke();
	}
	auto_geometry_num++;
	//데이터 저장
	geometry_total_arr_1.push(x_str);
	geometry_total_arr_2.push(y_str);
	geometry_total_arr_buf_1.push(x_str_buf);
	geometry_total_arr_buf_2.push(y_str_buf);
	
	cancelGeometry();
	
	var data_arr = new Array();
	data_arr.push(auto_geometry_str); data_arr.push("Geometry");
	if(type==1) { data_arr.push("Circle"); }
	else if(type==2) { data_arr.push("Rectangle"); }
	else { data_arr.push("Point"); }
	insertTableObject(data_arr);
}
function mouseeventGeometry(id, over, type) {
	//좌표 배열에서 좌표 가져옴
	var x_arr, y_arr, x_str, y_str, line_color, bg_color;
	for(var i=0; i<geometry_total_arr_1.length; i++) {
		if(id==geometry_total_arr_1[i].split("\@")[0]) {
			line_color = geometry_total_arr_1[i].split("\@")[3]; bg_color = geometry_total_arr_2[i].split("\@")[3];
			x_str = geometry_total_arr_1[i].split("\@")[2]; y_str = geometry_total_arr_2[i].split("\@")[2];
			x_arr = x_str.split("_"); y_arr = y_str.split("_");
		}
	}
	
	var x, y, width, height;
	var canvas = $('#'+id);
	var context = canvas[0].getContext("2d");
	context.clearRect(0,0,canvas.attr('width'),canvas.attr('height'));
	context.strokeStyle = css3color(line_color, 1); context.lineWidth = 1;
	
	if(type==1) {
		x = parseInt(x_arr[0]); y = parseInt(y_arr[0]); width = parseInt(x_arr[1]); height = parseInt(y_arr[1]);
		var kappa = .5522848;
			ox = (width/2) * kappa, oy = (height/2) * kappa, xe = x + width, ye = y + height, xm = x + width/2, ym = y + height/2;
		context.beginPath(); context.moveTo(x, ym);
		context.bezierCurveTo(x, ym - oy, xm - ox, y, xm, y); context.bezierCurveTo(xm + ox, y, xe, ym - oy, xe, ym); context.bezierCurveTo(xe, ym + oy, xm + ox, ye, xm, ye); context.bezierCurveTo(xm - ox, ye, x, ym + oy, x, ym);
		context.closePath();
		if(over) { context.fillStyle = css3color(bg_color, 0.2); context.fill(); }
		context.stroke();
	}
	else if(type==2) {
		x = x_arr[0]; y = y_arr[0]; width = x_arr[1]; height = y_arr[1];
		if(over) { context.fillStyle = css3color(bg_color, 0.2); context.fillRect(x, y, width, height); }
		context.strokeRect(x, y, width, height);
	}
	else {
		context.beginPath();
		for(var i=0; i<x_arr.length; i++) { x = parseInt(x_arr[i]); y = parseInt(y_arr[i]); if(i==0) context.moveTo(x, y); else context.lineTo(x, y); }
		context.closePath();
		if(over) { context.fillStyle = css3color(bg_color, 0.2); context.fill(); }
		context.stroke();
	}
}

function cancelGeometry() {
	//데이터 초기화
	$('.geometry_complete_button').remove(); $('.geometry_cancel_button').remove(); $('#geometry_draw_canvas').remove();
	geometry_point_arr_1 = null; geometry_point_arr_1 = new Array(); geometry_point_arr_2 = null; geometry_point_arr_2 = new Array();
	geometry_click_move_val = false; geometry_click_move_point_x = 0; geometry_click_move_point_y = 0; geometry_point_before_x = 0; geometry_point_before_y = 0; geometry_point_num = 1;
}

//객체 테이블
function insertTableObject(data_arr) {
	var html_text = "";
	html_text += "<tr id='obj_tr"+data_arr[0]+"' bgcolor='#EAEAEA'>";
	html_text += "<td align='center'><label>"+data_arr[0]+"</label></td>";
	html_text += "<td align='center'><label>"+data_arr[1]+"</label></td>";
	html_text += "<td id='obj_td"+data_arr[0]+"'><label>"+data_arr[2]+"</label></td>";
	html_text += "</tr>";
	
	$('#object_table tr:last').after(html_text);
	$('.ui-widget-content').css('fontSize', 12);
}

function loadXML() {
	var file_arr = file_url.split(".");   		// ["/upload/20141201_140526", "jpg"]
	var xml_file_name = file_arr[0] + '.xml';  		// "/upload/20141201_140526.xml"
	
	$.ajax({
		type: "GET",
		url: base_url + upload_url + xml_file_name,
// 		url: "<c:url value='/"+ xml_file_name +"'/>",
		dataType: "xml",
		contentType: "application/x-www-form-urlencoded; charset=utf-8", 
		cache: false,
		success:function(xml) {
			$(xml).find('obj').each(function(index) {
				var id = $(this).find('id').text();
				if(id == "c" || id == "b") {
					var font_size = $(this).find('fontsize').text(); var font_color = $(this).find('fontcolor').text(); var bg_color = $(this).find('backgroundcolor').text();
					var bold = $(this).find('bold').text(); var italic = $(this).find('italic').text(); var underline = $(this).find('underline').text(); var href = $(this).find('href').text();
					var text = $(this).find('text').text(); var top = $(this).find('top').text(); var left = $(this).find('left').text();
					autoCreateText(id, font_size, font_color, bg_color, bold, italic, underline, href, text, top, left);
				}
				else if(id == "i") {
					var top = $(this).find('top').text();
					var left = $(this).find('left').text();
					var width = $(this).find('width').text();
					var height = $(this).find('height').text();
					var src = $(this).find('src').text();
					
					createIcon(src);
					var obj = $('#'+auto_icon_str);
					obj.parent().position().top = top;
					obj.parent().position().left = left;
					
					obj.parent().attr('style', 'overflow: hidden; position: absolute; width:'+width+'; height:'+height+'; top:'+top+'px; left:'+left+'px; margin:0px;');
					obj.attr('style', 'position:static; display: block; top:'+top+'px; left:'+left+'px; width:'+width+'; height:'+height+';');
				}
				else if(id == "g") {
					var buf = $(this).find('type').text();
					var type;
					if(buf=='circle') type = 1;
					else if(buf=='rect') type = 2;
					else if(buf=='point') type = 3;
					else {}
					
					var top = $(this).find('top').text();
					var left = $(this).find('left').text();
					var x_str = $(this).find('xstr').text();
					var y_str = $(this).find('ystr').text();
					var line_color = $(this).find('linecolor').text();
					var bg_color = $(this).find('backgroundcolor').text();
					$('#geometry_line_color').val(line_color);
					$('#geometry_bg_color').val(bg_color);
					//inputGeometryShape(type);
					var buf1 = x_str.split('_');
					for(var i=0; i<buf1.length; i++) { geometry_point_arr_1.push(parseInt(buf1[i])); }
					var buf2 = y_str.split('_');
					for(var i=0; i<buf2.length; i++) { geometry_point_arr_2.push(parseInt(buf2[i])); }
					createGeometry(type);
				}
				else {}
			});
		},
		error: function(xhr, status, error) {
// 			alert('XML 호출 오류! 관리자에게 문의하여 주세요.');
		}
	});
}

/* exif_start ----------------------------------- EXIF 설정 ------------------------------------- */
function loadExif() {
	var encode_file_name = encodeURIComponent(upload_url + file_url);

	$.ajax({
		type: 'POST',
		url: base_url + '/geoExif.do',
// 		url: "<c:url value='/geoExif.do'/>",
		data: 'file_name='+encode_file_name+'&type=load',
		success: function(data) {
			var response = data.trim();
			
			exifSetting(response);
		}
	});
}

function exifSetting(data) {
	var line_buf_arr = data.split("\<LineSeparator\>");
	var line_data_buf_arr;
	//Make
	line_data_buf_arr = line_buf_arr[0].split("\<Separator\>"); $('#make_text').val(line_data_buf_arr[1]);
	//Model
	line_data_buf_arr = line_buf_arr[1].split("\<Separator\>"); $('#model_text').val(line_data_buf_arr[1]);
	//Date Time
	line_data_buf_arr = line_buf_arr[2].split("\<Separator\>"); $('#date_text').val(line_data_buf_arr[1]);
	//Flash
	line_data_buf_arr = line_buf_arr[3].split("\<Separator\>"); $('#flash_text').val(line_data_buf_arr[1]);
	//Shutter Speed
	line_data_buf_arr = line_buf_arr[4].split("\<Separator\>"); $('#shutter_text').val(line_data_buf_arr[1]);
	//Aperture
	line_data_buf_arr = line_buf_arr[5].split("\<Separator\>"); $('#aperture_text').val(line_data_buf_arr[1]);
	//Max Aperture
	line_data_buf_arr = line_buf_arr[6].split("\<Separator\>"); $('#m_aperture_text').val(line_data_buf_arr[1]);
	//Focal Length
	line_data_buf_arr = line_buf_arr[7].split("\<Separator\>");
	var focal_str;
	if(line_data_buf_arr[1].indexOf('\(')!=-1 && line_data_buf_arr[1].indexOf('\)')!=-1) focal_str = line_data_buf_arr[1].substring(line_data_buf_arr[1].indexOf('\(')+1, line_data_buf_arr[1].indexOf('\)'));
	else focal_str = line_data_buf_arr[1];
	$('#focal_text').val(focal_str);
	//Digital Zoom
	line_data_buf_arr = line_buf_arr[8].split("\<Separator\>"); $('#zoom_text').val(line_data_buf_arr[1]);
	//White Balance
	line_data_buf_arr = line_buf_arr[9].split("\<Separator\>"); $('#white_text').val(line_data_buf_arr[1]);
	//Brightness
	line_data_buf_arr = line_buf_arr[10].split("\<Separator\>"); $('#bright_text').val(line_data_buf_arr[1]);
	//User Comment
	line_data_buf_arr = line_buf_arr[11].split("\<Separator\>");
	if(line_data_buf_arr[1].charAt(0)=="'" && line_data_buf_arr[1].charAt(line_data_buf_arr[1].length-1)=="'") line_data_buf_arr[1] = line_data_buf_arr[1].substring(1, line_data_buf_arr[1].length-1);
	var index = line_data_buf_arr[1].indexOf("\<\?xml");
	if(index!=-1) {
		$('#comment_text').val(line_data_buf_arr[1].substring(0, index));
	}
	else {
		$('#comment_text').val(line_data_buf_arr[1]);
	}
	
	//GPS Speed
	line_data_buf_arr = line_buf_arr[12].split("\<Separator\>"); $('#speed_text').val(line_data_buf_arr[1]);
	//GPS Altitude
	line_data_buf_arr = line_buf_arr[13].split("\<Separator\>"); $('#alt_text').val(line_data_buf_arr[1]);
	//GPS Direction
	line_data_buf_arr = line_buf_arr[14].split("\<Separator\>");
	if(line_data_buf_arr[1].charAt(0)=="'" && line_data_buf_arr[1].charAt(line_data_buf_arr[1].length-1)=="'") line_data_buf_arr[1] = line_data_buf_arr[1].substring(1, line_data_buf_arr[1].length-1);
	var direction_str;
	if(line_data_buf_arr[1].indexOf('\(')!=-1 && line_data_buf_arr[1].indexOf('\)')!=-1) direction_str = line_data_buf_arr[1].substring(line_data_buf_arr[1].indexOf('\(')+1, line_data_buf_arr[1].indexOf('\)'));
	else direction_str = line_data_buf_arr[1];
	$('#gps_direction_text').val(direction_str);
	//GPS Longitude
	line_data_buf_arr = line_buf_arr[15].split("\<Separator\>"); $('#lon_text').val(line_data_buf_arr[1]);
	//GPS Latitude
	line_data_buf_arr = line_buf_arr[16].split("\<Separator\>"); $('#lat_text').val(line_data_buf_arr[1]);
	
	//맵설정
	reloadMap(2);
}

/* map_start ----------------------------------- 맵 버튼 설정 ------------------------------------- */
function reloadMap(type) {
	var arr = readMapData();
	$('#googlemap').get(0).contentWindow.setCenter(arr[0], arr[1], 1);
	if(type==2) { $('#googlemap').get(0).contentWindow.setAngle(arr[2], arr[3]); }
}

readMapData = function() {
	var direction_str = $('#gps_direction_text').val();
	var lon_text = $('#lon_text').val();
	var lat_text = $('#lat_text').val();
	var focal_str = $('#focal_text').val();
	if(focal_str != null && focal_str != ""){
		focal_str = focal_str.replace(/'/, '');
	}
	
	var buf_arr = new Array();
	buf_arr.push(lat_text);
	buf_arr.push(lon_text);
	buf_arr.push(direction_str);
	buf_arr.push(focal_str);
	return buf_arr;
};

function setExifData(lat_str, lng_str, direction) {
	$('#lat_text').val(lat_str);
	$('#lon_text').val(lng_str);
	$('#gps_direction_text').val(direction);
}

//맵 크기 조절
var resize_map_state = 1;
var resize_scale = 400;
var init_map_left, init_map_top, init_map_width, init_map_height;
function resizeMap() {
	if(resize_map_state==1) {
		init_map_left = 765;
		init_map_top = 568;
		init_map_width = $('#image_map_area').width();
		init_map_height = $('#image_map_area').height();
		resize_map_state=2;
		$('#image_map_area').animate({left:init_map_left-resize_scale, top:init_map_top-resize_scale, width:init_map_width+resize_scale, height:init_map_height+resize_scale},"slow", function() { $('#resize_map_btn').css('background-image','url(<c:url value="/images/geoImg/icon_map_min.jpg"/>)'); reloadMap(1); });
	}
	else if(resize_map_state==2) {
		resize_map_state=1;
		$('#image_map_area').animate({left:init_map_left, top:init_map_top, width:init_map_width, height:init_map_height},"slow", function() { $('#resize_map_btn').css('background-image','url(<c:url value="/images/geoImg/icon_map_max.jpg"/>)'); reloadMap(1); });
	}
	else {}
}

//저작
function imageWrite() {
// 	jConfirm('뷰어를 닫고 저작을 수행하시겠습니까?', '정보', function(type){
	jConfirm('Do you want to close the viewer and author?', 'Info', function(type){
		if(type) {
			$.FrameDialog.closeDialog();	//뷰어 닫기
			openImageWrite();
		}
	});
}
//새창 띄우기 (저작)
function openImageWrite() {
	if(editUserYN == 0 && (projectUserId == loginId && projectUserId != user_id)){
		editUserYN = 1;
	}
	window.open('', 'image_write_page', 'width=1150, height=860');
	var form = document.createElement('form');
	form.setAttribute('method','post');
	form.setAttribute('action',"<c:url value='/geoPhoto/image_write_page.do'/>?loginToken="+loginToken+"&loginId="+loginId+"&projectBoard="+projectBoard+'&editUserYN='+editUserYN+'&projectUserId='+projectUserId);
	form.setAttribute('target','image_write_page');
	document.body.appendChild(form);
	
	var insert = document.createElement('input');
	insert.setAttribute('type','hidden');
	insert.setAttribute('name','file_url');
	insert.setAttribute('value',file_url);
	form.appendChild(insert);
	
	var insertIdx = document.createElement('input');
	insertIdx.setAttribute('type','hidden');
	insertIdx.setAttribute('name','idx');
	insertIdx.setAttribute('value',idx);
	form.appendChild(insertIdx);
	
	var insertContentArr = document.createElement('input');
	insertContentArr.setAttribute('type','hidden');
	insertContentArr.setAttribute('name','b_contentTabArr');
	insertContentArr.setAttribute('value',b_contentTabArr);
	form.appendChild(insertContentArr);
	
	form.submit();
}

rgb2hex = function(rgb) {
	rgb = rgb.match(/^rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*(\d+))?\)$/);
    function hex(x) {
        return ("0" + parseInt(x).toString(16)).slice(-2);
    }
    return "#" + hex(rgb[1]) + hex(rgb[2]) + hex(rgb[3]);
};
hex_to_decimal = function(hex) {
	return Math.max(0, Math.min(parseInt(hex, 16), 255));
};
css3color = function(color, opacity) {
	if(color.length==3) { var c1, c2, c3; c1 = color.substring(0, 1); c2 = color.substring(1, 2); c3 = color.substring(2, 3); color = c1 + c1 + c2 + c2 + c3 + c3; }
	return 'rgba('+hex_to_decimal(color.substr(0,2))+','+hex_to_decimal(color.substr(2,2))+','+hex_to_decimal(color.substr(4,2))+','+opacity+')';
};
</script>

</head>

<body onload='imageViewerInit();'>
<!---------------------------------------------------- 메인 영역 시작 ------------------------------------------------>

<!-- 이미지 영역 -->
<!-- <div id='image_main_area' style='position:absolute; left:10px; top:15px; width:800px; height:500px; display:block; border:1px solid #999999;'>
</div> -->
<div id='image_main_area' style='position:absolute; left:10px; top:15px; width:780px; height:580px; display:block; border:1px solid #999999;'>
</div>
<!-- 추가 객체 영역 -->
<div id="ioa_title" style='position:absolute; left:797px; top:12px; width:150px; height:245px;'><img src="<c:url value='/images/geoImg/title_02.jpg'/>" alt="객체추가리스트"></div>
<div id='image_object_area' style='position:absolute; left:800px; top:33px; width:300px; height:245px; display:block; border:1px solid #999999; overflow-y:scroll;'>
	<table id='object_table'>
		<tr style='font-size:12px; height:20px;' class='col_black'>
			<td width=50 class='anno_head_tr'>ID</td>
			<td width=80 class='anno_head_tr'>Type</td>
			<td width=170 class='anno_head_tr'>Data</td>
		</tr>
	</table>
</div>

<!-- EXIF 영역 -->
<div id="ex_tit"><img src="<c:url value='/images/geoImg/title_03.gif'/>" style='position:absolute; left:799px; top:288px;' alt="이미지정보"></div>
<div id='image_exif_area' style='position:absolute; left:800px; top:310px; width:300px; height:245px; display:block; /*border:1px solid #999999;*/ '>
</div>

<!-- 지도 영역 -->
<div id='image_map_area' style='position:absolute; left:765px; top:568px; width:30px; height:30px; display:block; background-color:#999;'>
	<iframe id='googlemap' src='<c:url value="/geoPhoto/image_googlemap.do"/>' style='width:100%; height:100%; margin:1px; border:none;'></iframe>
	<div id='resize_map_btn' onclick='resizeMap();' style='position:absolute; left:0px; top:0px; width:30px; height:30px; cursor:pointer; background-image:url(<c:url value='/images/geoImg/icon_map_max.jpg'/>);'>
	</div>
</div>

<!----------------------------------------------------- 메인 영역 끝 ------------------------------------------------->

<!----------------------------------------------------- 서브 영역 ------------------------------------------------------------->

<!-- 자막 삽입 다이얼로그 객체 -->
<div id='caption_dialog' style='position:absolute; left:0px; top:0px; display:none;'>
	<div style='display:table; width:100%; height:100%;'>
		<div align="center" style='display:table-cell; vertical-align:middle;'>
			<table border='0'>
				<tr><td width=65><label style="font-size:12px;">Font Size : </label></td>
				<td><select id="caption_font_select" style="font-size:12px;"><option>Normal<option>H3<option>H2<option>H1</select></td>
				<td><label style="font-size:12px;">Font Color : </label></td>
				<td><input id="caption_font_color" type="text" class="iColorPicker" value="#FFFFFF" style="width:50px;"/></td>
				<td><label style="font-size:12px;">BG Color : </label></td>
				<td><input id="caption_bg_color" type="text" class="iColorPicker" value="#000000" style="width:50px;"/></td>
				<td id='caption_checkbox_td'><input type="checkbox" name="caption_bg_checkbok" onclick="checkCaption();"/><label style="font-size:12px;">투명</label></td></tr>
				<tr><td colspan='7' id='caption_check'></td></tr>
				<tr><td colspan='7'><hr/></td></tr>
				<tr><td colspan='5'><input id="caption_text" type="text" style="width:90%; font-size:12px; border:solid 2px #777;"/></td>
				<td colspan='2' align='center' id='caption_button'></td></tr>
			</table>
		</div>
	</div>
</div>

<!-- 말풍선 삽입 다이얼로그 객체 -->
<div id='bubble_dialog' style='position:absolute; left:0px; top:0px; display:none;'>
	<div style='display:table; width:100%; height:100%;'>
		<div align="center" style='display:table-cell; vertical-align:middle;'>
			<table border='0'>
				<tr><td width=65><label style="font-size:12px;">Font Size : </label></td>
				<td><select id="bubble_font_select" style="font-size:12px;"><option>Normal<option>H3<option>H2<option>H1</select></td>
				<td><label style="font-size:12px;">Font Color : </label></td>
				<td><input id="bubble_font_color" type="text" class="iColorPicker" value="#FFFFFF" style="width:50px;"/></td>
				<td><label style="font-size:12px;">BG Color : </label></td>
				<td><input id="bubble_bg_color" type="text" class="iColorPicker" value="#000000" style="width:50px;"/></td>
				<td id='bubble_checkbox_td'><input type="checkbox" name="bubble_bg_checkbok" onclick="checkBubble();"/><label style=" font-size:12px;">투명</label></td></tr>
				<tr><td colspan='7' id='bubble_check'></td></tr>
				<tr><td colspan='7'><hr/></td></tr>
				<tr><td colspan='5'><textarea id="bubble_text" rows="3" style="width:90%; font-size:12px; border:solid 2px #777;"></textarea></td>
				<td colspan='2' align='center' id='bubble_button'></td></tr>
			</table>
		</div>
	</div>
</div>

<!-- 이미지 삽입 다이얼로그 객체 -->
<div id='icon_dialog' style='position:absolute; left:0px; top:0px; display:none;'>
	<div style='position:absolute; left:5px; top:-15px;'>
		<button class="ui-state-default" style="width:80px; height:30px; font-size:12px;" onclick="tabImage(1);">Icon</button>
		<button class="ui-state-default" style="width:80px; height:30px; font-size:12px;" onclick="tabImage(2);">Image</button>
	</div>
	<div id='icon_div1' style='position:absolute; left:15px; top:20px; width:465px; height:150px; background-color:#999; border:1px solid #999999; overflow-y:scroll; display:block;'>
		<table id='icon_table1' border="0">
			<tr><td><img id='icon_img1' src=''></td><td><img id='icon_img2' src=''></td><td><img id='icon_img3' src=''></td><td><img id='icon_img4' src=''></td><td><img id='icon_img5' src=''></td><td><img id='icon_img6' src=''></td><td><img id='icon_img7' src=''></td><td><img id='icon_img8' src=''></td><td><img id='icon_img9' src=''></td><td><img id='icon_img10' src=''></td></tr>
			<tr><td><img id='icon_img11' src=''></td><td><img id='icon_img12' src=''></td><td><img id='icon_img13' src=''></td><td><img id='icon_img14' src=''></td><td><img id='icon_img15' src=''></td><td><img id='icon_img16' src=''></td><td><img id='icon_img17' src=''></td><td><img id='icon_img18' src=''></td><td><img id='icon_img19' src=''></td><td><img id='icon_img20' src=''></td></tr>
			<tr><td><img id='icon_img21' src=''></td><td><img id='icon_img22' src=''></td><td><img id='icon_img23' src=''></td><td><img id='icon_img24' src=''></td><td><img id='icon_img25' src=''></td><td><img id='icon_img26' src=''></td><td><img id='icon_img27' src=''></td><td><img id='icon_img28' src=''></td><td><img id='icon_img29' src=''></td><td><img id='icon_img30' src=''></td></tr>
			<tr><td><img id='icon_img31' src=''></td><td><img id='icon_img32' src=''></td><td><img id='icon_img33' src=''></td><td><img id='icon_img34' src=''></td><td><img id='icon_img35' src=''></td><td><img id='icon_img36' src=''></td><td><img id='icon_img37' src=''></td><td><img id='icon_img38' src=''></td><td><img id='icon_img39' src=''></td><td><img id='icon_img40' src=''></td></tr>
			<tr><td><img id='icon_img41' src=''></td><td><img id='icon_img42' src=''></td><td><img id='icon_img43' src=''></td><td><img id='icon_img44' src=''></td><td><img id='icon_img45' src=''></td><td><img id='icon_img46' src=''></td><td><img id='icon_img47' src=''></td><td><img id='icon_img48' src=''></td><td><img id='icon_img49' src=''></td><td><img id='icon_img50' src=''></td></tr>
			<tr><td><img id='icon_img51' src=''></td><td><img id='icon_img52' src=''></td><td><img id='icon_img53' src=''></td><td><img id='icon_img54' src=''></td><td><img id='icon_img55' src=''></td><td><img id='icon_img56' src=''></td><td><img id='icon_img57' src=''></td><td><img id='icon_img58' src=''></td><td><img id='icon_img59' src=''></td><td><img id='icon_img60' src=''></td></tr>
			<tr><td><img id='icon_img61' src=''></td><td><img id='icon_img62' src=''></td><td><img id='icon_img63' src=''></td><td><img id='icon_img64' src=''></td><td><img id='icon_img65' src=''></td><td><img id='icon_img66' src=''></td><td><img id='icon_img67' src=''></td><td><img id='icon_img68' src=''></td><td><img id='icon_img69' src=''></td><td><img id='icon_img70' src=''></td></tr>
			<tr><td><img id='icon_img71' src=''></td><td><img id='icon_img72' src=''></td><td><img id='icon_img73' src=''></td><td><img id='icon_img74' src=''></td><td><img id='icon_img75' src=''></td><td><img id='icon_img76' src=''></td><td><img id='icon_img77' src=''></td><td><img id='icon_img78' src=''></td><td><img id='icon_img79' src=''></td><td><img id='icon_img80' src=''></td></tr>
			<tr><td><img id='icon_img81' src=''></td><td><img id='icon_img82' src=''></td><td><img id='icon_img83' src=''></td><td><img id='icon_img84' src=''></td><td><img id='icon_img85' src=''></td><td><img id='icon_img86' src=''></td><td><img id='icon_img87' src=''></td><td><img id='icon_img88' src=''></td><td><img id='icon_img89' src=''></td><td><img id='icon_img90' src=''></td></tr>
			<tr><td><img id='icon_img91' src=''></td><td><img id='icon_img92' src=''></td><td><img id='icon_img93' src=''></td><td><img id='icon_img94' src=''></td><td><img id='icon_img95' src=''></td><td><img id='icon_img96' src=''></td><td><img id='icon_img97' src=''></td><td><img id='icon_img98' src=''></td><td><img id='icon_img99' src=''></td><td><img id='icon_img100' src=''></td></tr>
			<tr><td><img id='icon_img101' src=''></td><td><img id='icon_img102' src=''></td><td><img id='icon_img103' src=''></td><td><img id='icon_img104' src=''></td><td><img id='icon_img105' src=''></td><td><img id='icon_img106' src=''></td><td><img id='icon_img107' src=''></td><td><img id='icon_img108' src=''></td><td><img id='icon_img109' src=''></td><td><img id='icon_img110' src=''></td></tr>
			<tr><td><img id='icon_img111' src=''></td><td><img id='icon_img112' src=''></td><td><img id='icon_img113' src=''></td><td><img id='icon_img114' src=''></td><td><img id='icon_img115' src=''></td><td><img id='icon_img116' src=''></td><td><img id='icon_img117' src=''></td><td><img id='icon_img118' src=''></td><td><img id='icon_img119' src=''></td><td><img id='icon_img120' src=''></td></tr>
			<tr><td><img id='icon_img121' src=''></td><td><img id='icon_img122' src=''></td><td><img id='icon_img123' src=''></td><td><img id='icon_img124' src=''></td><td><img id='icon_img125' src=''></td><td><img id='icon_img126' src=''></td><td><img id='icon_img127' src=''></td><td><img id='icon_img128' src=''></td><td><img id='icon_img129' src=''></td><td><img id='icon_img130' src=''></td></tr>
		</table>
	</div>

	<div id='icon_div2' style='position:absolute; display:none;'>
		<table id='icon_table2' border="1">
			<tr>
				<td>이미지 검색 바 위치</td>
			</tr>
			<tr>
				<td>이미지 검색 결과 위치</td>
			</tr>
		</table>
	</div>
</div>

<!-- Geometry 삽입 다이얼로그 객체 -->
<div id='geometry_dialog' style='position:absolute; left:0px; top:0px; display:none;'>
	<div style='display:table; width:100%; height:100%;'>
		<div align="center" style='display:table-cell; vertical-align:middle;'>
			<table id='geometry_table' border="0">
				<tr>
					<td><label style="font-size:12px;">Shape Style : </label>
					<input type='radio' name='geo_shape' value='circle'><label style="font-size:12px;">Circle</label>
					<input type='radio' name='geo_shape' value='rect'><label style="font-size:12px;">Rect</label>
					<input type='radio' name='geo_shape' value='point' checked><label style="font-size:12px;">Point</label></td>
					<td width='20'></td>
					<td rowspan='3'><button class="ui-state-default ui-corner-all" style="width:80px; height:30px; font-size:12px;" onclick="setGeometry();">확인</button></td>
				</tr>
				<tr><td><hr/></td><td width='20'></td></tr>
				<tr>
					<td><label style="font-size:12px;">Line Color : </label>
					<input id="geometry_line_color" type="text" class="iColorPicker" value="#999999" style="width:50px;"/>
					&nbsp;&nbsp;&nbsp;
					<label style="font-size:12px;">MouseOver Color : </label>
					<input id="geometry_bg_color" type="text" class="iColorPicker" value="#FF0000" style="width:50px;"/></td>
					<td width='20'></td>
				</tr>
			</table>
		</div>
	</div>
</div>

<!-- EXIF 삽입 다이얼로그 객체 -->
<div id='exif_dialog' style='position:absolute; left:800px; top:310px; width:300px; height:248px; border:1px solid #999999; display:block; font-size:13px;'>
	<div class='accordionButton col_black'>&nbsp;EXIF Normal Info</div>
	<div class='accordionContent' style='height:207px; overflow-y:scroll;'>
		<table id='normal_exif_table'>
			<tr><td width='15'></td><td width='100'><label style='font-size:12px;'>Make</label></td><td width='150'><input id='make_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
			<tr><td width='15'><td><label>Model</label></td><td><input id='model_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
			<tr><td width='15'><td><label>Date Time</label></td><td><input id='date_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
			<tr><td width='15'><td><label>Flash</label></td><td><input id='flash_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
			<tr><td width='15'><td><label>Shutter Speed</label></td><td><input id='shutter_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
			<tr><td width='15'><td><label>Aperture</label></td><td><input id='aperture_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
			<tr><td width='15'><td><label>Max Aperture</label></td><td><input id='m_aperture_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
			<tr><td width='15'><td><label>Focal Length</label></td><td><input id='focal_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
			<tr><td width='15'><td><label>Digital Zoom</label></td><td><input id='zoom_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
			<tr><td width='15'><td><label>White Balance</label></td><td><input id='white_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
			<tr><td width='15'><td><label>Brightness</label></td><td><input id='bright_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
			<tr><td width='15'><td><label>User Comment</label></td><td><input id='comment_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
		</table>
	</div>
	
	<div class='accordionButton col_black'>&nbsp;EXIF GPS Info</div>
	<div class='accordionContent' style='height:205px; overflow-y:scroll;'>
		<table id='gps_exif_table' style="margin-top: 15px;">
			<tr><td width='15'></td><td width='100'><label style='font-size:12px;'>Speed</label></td><td width='150'><input id='speed_text' name='text' type='text' style='font-size:12px;' disabled/></td></tr>
			<tr><td width='15'></td><td><label>Altitude</label></td><td><input id='alt_text' name='text' type='text' style='font-size:12px;' disabled/></td></tr>
			<tr><td width='15'></td><td><label>GPS Direction</label></td><td><input id='gps_direction_text' name='text' type='text' style='font-size:12px;' disabled/></td></tr>
			<tr><td width='15'></td><td><label>Longitude</label></td><td><input id='lon_text' name='text' type='text' style='font-size:12px;' disabled/></td></tr>
			<tr><td width='15'></td><td><label>Latitude</label></td><td><input id='lat_text' name='text' type='text' style='font-size:12px;' disabled/></td></tr>
		</table>
	</div>
</div>

<!-- 저작 버튼 -->
	

</body>

</html>
