<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">

<jsp:include page="../../page_common.jsp"></jsp:include>

<%
String file_url = request.getParameter("file_url");
String idx = request.getParameter("idx");
String loginToken = request.getParameter("loginToken");
String loginId = request.getParameter("loginId");
String b_contentTabArr = request.getParameter("b_contentTabArr");	//contentTab array
String projectBoard = request.getParameter("projectBoard");
String editUserYN = request.getParameter("editUserYN");
%>

<script type="text/javascript">

/* init_start ----- 초기 설정 ------------------------------------------------------------ */
var idx = '<%= idx %>';
var loginToken = '<%= loginToken %>';
var loginId = '<%= loginId %>';
var b_contentTabArr = "<%=b_contentTabArr%>";	//content tab array
if(b_contentTabArr != null){
	b_contentTabArr = b_contentTabArr.split(",");
}
var projectBoard = '<%= projectBoard %>';
var editUserYN = '<%= editUserYN %>';

var nowSelTab;
var nowShareType;
var oldShareUserLen = 0;

var file_url = '<%= file_url %>';
var base_url = '';
var upload_url = '';
var icon_css = ' style="width: 25px; height: 25px; margin: 3px; cursor:pointer;" ';

$(function() {
// 	class="menuIcon"
	//저작 버튼 설정
	$('.exif_button').button({ icons: { primary: 'ui-icon-exif'} }); $('.exif_button').width(100); $('.exif_button').height(30); $('.exif_button').css('fontSize', 12);	
	$('.save_button').button({ icons: { primary: 'ui-icon-disk'}, text: false }); $('.save_button').width(50); $('.save_button').height(35);
	$('.exit_button').button({ icons: { primary: 'ui-icon-closethick'}, text: false }); $('.exit_button').width(50); $('.exit_button').height(35);
	
	//구글지도 zindex 설정
	$('#image_map_area').maxZIndex({inc:1});
	
	//저장 버튼 설정
	$('.save_dialog').dialog({
		autoOpen: false,
		width: 'auto',
		modal: true
	});
	
	$('.e_dialog').dialog({
		autoOpen: false,
		width: 'auto',
		modal: true
	});
	
	if(projectBoard == 1){
		base_url = 'http://'+ location.host + '/GeoCMS';
		upload_url = '/upload/GeoPhoto/';
		if(editUserYN != 1){
			//ui 
			$('#showInfoDiv').css('display','block');
			$('.menuIcon').css('width','14%');
			$('.menuIconData').css('display', 'block');
		}
		//tab select
		var innerHTML = '';
		for(var i=0;i<b_contentTabArr.length;i++){
			innerHTML += '<option value="'+ b_contentTabArr[i] +'">'+ b_contentTabArr[i] +'</option>';
		}
		$('#showKind').append(innerHTML);
		getOneImageData();
	}else{
		base_url = '<c:url value="/"/>';
		upload_url = '/upload/';
	}
});

function getOneImageData(){
	var Url			= baseRoot() + "cms/getImage/";
	var param		= "one/" + loginToken + "/" + loginId + "/&nbsp/&nbsp/&nbsp/" +idx;
	var callBack	= "?callback=?";
	
	$.ajax({
		type	: "get"
		, url	: Url + param + callBack
		, dataType	: "jsonp"
		, async	: false
		, cache	: false
		, success: function(data) {
			if(data.Code == 100){
				var response = data.Data;
				var tmpShareList = data.shareList;

				if(response != null && response != ''){
					response = response[0];
					nowSelTab = response.TABNAME;
					nowShareType = response.SHARETYPE;
					
					$('#title_area').val(response.TITLE);
					$('#content_area').val(response.CONTENT);
// 					var nowShareTypeText = nowShareType == 0? '비공개':nowShareType== 1? '전체공개':'특정인 공개';
					var nowShareTypeText = nowShareType == 0? 'Nondisclosure':nowShareType== 1? 'Full disclosure':'Selective disclosure';
					
					$('#showKindLabel').text(nowSelTab);
					$('#shareKindLabel').text(nowShareTypeText);
					
					$("input[name=shareRadio][value=" + nowShareType + "]").attr("checked", true);
					$('#showKind').val(nowSelTab);
					
					if(tmpShareList != null && tmpShareList.length > 0){
						oldShareUserLen = tmpShareList.length;
					}
				}
			}else{
				jAlert(data.Message, 'Info');
			}
		}
	});
}

function dataChangeClick(){
	compHide();
	$('#data_dialog').css('display','block');
}

function imgGetShareUser(){
	contentViewDialog = jQuery.FrameDialog.create({
		url: base_url+'/geoCMS/share.do?shareIdx='+ idx +'&shareKind=GeoPhoto',
		width: 370,
		height: 535,
		buttons: {},
		autoOpen:false
	});
	contentViewDialog.dialog('widget').find('.ui-dialog-titlebar').remove();
	contentViewDialog.dialog('open');
}

/* init_start ----- 사진 리사이즈 및 EXIF 불러오기 설정 ------------------------------------- */

//on load function
function imageWriteInit() {
	//이미지 그리기
	changeImage();
}

var img_origin_width, img_origin_height;
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

		img_origin_width = img.width; img_origin_height = img.height;
		result_arr = resizeImage(width, height, img.width, img.height, margin);
		//canvas 의 width height 비율과 다른 이미지의 경우 축소하여도 y 축이 음수가 나오는 경우를 처리하기 위함
		while(result_arr[1]<3) {
			margin += 10;
			result_arr = resizeImage(width, height, img.width, img.height, margin);
		}
		
		var img_element = $('#image_write_canvas');
		img_element.attr('src', base_url + upload_url + file_url);
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

/* caption_start ----------------------------------- 자막 삽입 버튼 설정 ------------------------------------- */
function inputCaption(id, text) {
	compHide();
	$('#caption_font_color').attr('disabled', true);
	$('#caption_bg_color').attr('disabled', true);
	
	if(id==0 & text=="") {
		//caption dialog 내부 객체 초기화
		$('#caption_font_select').val('Normal'); $('#caption_font_color').val('#000000'); $('#caption_font_color').css('background-color', '#000000'); $('#caption_bg_color').val('#FFFFFF'); $('#caption_bg_color').css('background-color', '#FFFFFF'); $('input[name=caption_bg_checkbok]').attr('checked', true); $('#icp_caption_bg_color').removeAttr('onclick'); $('#caption_check').html('<input type="checkbox" id="caption_bold" style="display:none;"/><img src="<c:url value="/images/geoImg/write/bold_off.png"/>" '+icon_css+' onclick="captionCheck(this);"><input type="checkbox" id="caption_italic" style="display:none;" /><img src="<c:url value="/images/geoImg/write/italic_off.png"/>" '+icon_css+' onclick="captionCheck(this);"><input type="checkbox" id="caption_underline" style="display:none;" /><img src="<c:url value="/images/geoImg/write/underLine_off.png"/>" '+icon_css+' onclick="captionCheck(this);"><input type="checkbox" id="caption_link" style="display:none;"/><img src="<c:url value="/images/geoImg/write/hyperLink_off.png"/>" '+icon_css+' onclick="captionCheck(this);">'); $('#caption_button').html('<button class="ui-state-default ui-corner-all" style="width:80px; height:30px; font-size:12px;" onclick="createCaption();">Input</button>'); $('#caption_text').val('');
// 		$('#caption_font_select').val('Normal'); $('#caption_font_color').val('#000000'); $('#caption_font_color').css('background-color', '#000000'); $('#caption_bg_color').val('#FFFFFF'); $('#caption_bg_color').css('background-color', '#FFFFFF'); $('input[name=caption_bg_checkbok]').attr('checked', true); $('#icp_caption_bg_color').removeAttr('onclick'); $('#caption_check').html('<input type="checkbox" id="caption_bold" class="caption_bold" /><label for="caption_bold" style="width:30px; height:30px;background-image:url(/images/geoImg/bold_off.png)">Bold</label><input type="checkbox" id="caption_italic" class="caption_italic" /><label for="caption_italic" style="width:30px; height:30px;">Italic</label><input type="checkbox" id="caption_underline" class="caption_underline" /><label for="caption_underline" style="width:30px; height:30px;">Underline</label><input type="checkbox" id="caption_link" class="caption_link" /><label for="caption_link" style="width:30px; height:30px;">HyperLink</label>'); $('.caption_bold').button({ icons: { primary: 'ui-icon-bold'}, text: false }); $('.caption_italic').button({ icons: { primary: 'ui-icon-italic'}, text: false }); $('.caption_underline').button({ icons: { primary: 'ui-icon-underline'}, text: false }); $('.caption_link').button({ icons: { primary: 'ui-icon-link'}, text: false }); $('#caption_button').html('<button class="ui-state-default ui-corner-all" style="width:80px; height:30px; font-size:12px;" onclick="createCaption();">입력</button>'); $('#caption_text').val('');
	}
	else {
		//caption dialog 내부 객체 설정
		var font_size = $('#f'+id).css('font-size');
		
		if(font_size == '14px') $('#caption_font_select').val('H3');
		else if(font_size == '18px') $('#caption_font_select').val('H2');
		else if(font_size == '22px') $('#caption_font_select').val('H1');
		else $('#caption_font_select').val('Normal');
		
		var font_color = rgb2hex($('#f'+id).css('color')); 
		$('#caption_font_color').val(font_color); 
		$('#caption_font_color').css('background-color', font_color);
		
		var bg_color_value = $('#p'+id).css('backgroundColor'); 
		var bg_color = '';
		
		if(bg_color_value!='transparent') { bg_color = rgb2hex($('#p'+id).css('backgroundColor')); $('input[name=caption_bg_checkbok]').attr('checked', false); }
		else { bg_color = '#FFFFFF'; $('input[name=caption_bg_checkbok]').attr('checked', true); }
		
		$('#caption_bg_color').val(bg_color); 
		$('#caption_bg_color').css('background-color', bg_color);
		
		var check_html = ""; 
		var html_text = $('#'+id).html();
		var img_kind = 'off';
		check_html += '<input type="checkbox" id="caption_bold" style="display:none;" ';
		if(html_text.indexOf('<b id') != -1){
			check_html += ' checked="checked" ';
			img_kind = 'on';
		}
		check_html += ' /><img src="<c:url value="/images/geoImg/write/bold_'+img_kind+'.png"/>" '+icon_css+' onclick="captionCheck(this);">';
		
		img_kind = 'off';
		check_html += '<input type="checkbox" id="caption_italic" style="display:none;"';
		if(html_text.indexOf('<i id') != -1){
			check_html += ' checked="checked" ';
			img_kind = 'on';
		}
		check_html += ' /><img src="<c:url value="/images/geoImg/write/italic_'+img_kind+'.png"/>" '+icon_css+' onclick="captionCheck(this);">';
		
		img_kind = 'off';
		check_html += '<input type="checkbox" id="caption_underline"  style="display:none;"';
		if(html_text.indexOf('<u id') != -1){
			check_html += ' checked="checked" ';
			img_kind = 'on';
		}
		check_html += ' /><img src="<c:url value="/images/geoImg/write/underLine_'+img_kind+'.png"/>" '+icon_css+' onclick="captionCheck(this);">';
		
		img_kind = 'off';
		check_html += '<input type="checkbox" id="caption_link" style="display:none;"';
		if(html_text.indexOf('<a href') != -1){
			check_html += ' checked="checked" ';
			img_kind = 'on';
		}
		check_html += ' /><img src="<c:url value="/images/geoImg/write/hyperLink_'+img_kind+'.png"/>" '+icon_css+' onclick="captionCheck(this);">';
		
		
// 		if(html_text.indexOf('<b id') != -1) check_html += '<input type="checkbox" id="caption_bold" class="caption_bold" checked="checked" /><label for="caption_bold" style="width:30px; height:30px;">Bold</label>';
// 		else check_html += '<input type="checkbox" id="caption_bold" class="caption_bold" /><label for="caption_bold" style="width:30px; height:30px;">Bold</label>';
// 		if(html_text.indexOf('<i id') != -1) check_html += '<input type="checkbox" id="caption_italic" class="caption_italic" checked="checked" /><label for="caption_italic" style="width:30px; height:30px;">Italic</label>';
// 		else check_html += '<input type="checkbox" id="caption_italic" class="caption_italic" /><label for="caption_italic" style="width:30px; height:30px;">Italic</label>';
// 		if(html_text.indexOf('<u id') != -1) check_html += '<input type="checkbox" id="caption_underline" class="caption_underline" checked="checked" /><label for="caption_underline" style="width:30px; height:30px;">Underline</label>';
// 		else check_html += '<input type="checkbox" id="caption_underline" class="caption_underline" /><label for="caption_underline" style="width:30px; height:30px;">Underline</label>';
// 		if(html_text.indexOf('<a href') != -1) check_html += '<input type="checkbox" id="caption_link" class="caption_link" checked="checked" /><label for="caption_link" style="width:30px; height:30px;">HyperLink</label>';
// 		else check_html += '<input type="checkbox" id="caption_link" class="caption_link" /><label for="caption_link" style="width:30px; height:30px;">HyperLink</label>';
// 		$('#caption_check').html(check_html); $('.caption_bold').button({ icons: { primary: 'ui-icon-bold'}, text: false }); $('.caption_italic').button({ icons: { primary: 'ui-icon-italic'}, text: false }); $('.caption_underline').button({ icons: { primary: 'ui-icon-underline'}, text: false }); $('.caption_link').button({ icons: { primary: 'ui-icon-link'}, text: false }); $('#caption_text').val($('#p'+id).html()); $('#caption_button').html('<button id="caption_replace_btn" class="ui-state-default ui-corner-all" style="width:80px; height:30px; font-size:12px;">수정</button>');

		$('#caption_check').html(check_html); 
		$('#caption_text').val($('#p'+id).html()); 
		$('#caption_button').html('<button id="caption_replace_btn" class="ui-state-default ui-corner-all" style="width:80px; height:30px; font-size:12px;">수정</button>');
		$('#caption_replace_btn').click(function() { replaceCaption(id); });
	}
	
	document.getElementById('caption_dialog').style.display='block';
}

function checkCaption() {
	if(!$('input[name=caption_bg_checkbok]').attr('checked')) { $('#icp_caption_bg_color').bind('click', function() { iColorShow('caption_bg_color','icp_caption_bg_color'); }); }
	else { $('#icp_caption_bg_color').unbind('click'); }
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
	div_element.attr('id', auto_caption_str); div_element.attr('style', 'position:absolute; left:10px; top:10px; display:block;'); div_element.html(html_text); div_element.draggable(); div_element.dblclick(function() { inputCaption(div_element.attr('id'), text); }); div_element.appendTo('#image_main_area');
	
	$('#'+div_element.attr('id')).contextMenu('context1', {
		bindings: {
			'context_modify': function(t) { inputCaption(t.id, text); },
			'context_delete': function(t) { jConfirm('Are you sure you want to delete?', 'Info', function(type){ if(type) { $('#'+t.id).remove(); removeTableObject(t.id); } }); }
// 			'context_delete': function(t) { jConfirm('정말 삭제하시겠습니까?', '정보', function(type){ if(type) { $('#'+t.id).remove(); removeTableObject(t.id); } }); }
		}
	});
	
	auto_caption_num++;
	
	compHide();
	
	var data_arr = new Array();
	data_arr.push(auto_caption_str); data_arr.push("Caption"); data_arr.push(text);
	insertTableObject(data_arr);
}

function replaceCaption(id) {
	var font_size = $('#caption_font_select').val();
	var font_color = $('#caption_font_color').val();
	var bg_color = $('#caption_bg_color').val();
	var bg_check = $('input[name=caption_bg_checkbok]').attr('checked');
	var bold_check = $('#caption_bold').attr('checked');
	var italic_check = $('#caption_italic').attr('checked');
	var underline_check = $('#caption_underline').attr('checked');
	var link_check = $('#caption_link').attr('checked');
	var text = $('#caption_text').val();
	
	if(bg_check==true) bg_color = ''; // 빨간색 넣으면 바로 변경되어 보여줌
	
	var html_text;
	//폰트, 색상 설정
	if(font_size=='H3') html_text = '<font id="f'+id+'" style="font-size:14px; color:'+font_color+';"><pre id="p'+id+'" style="font-size:14px;background:'+bg_color+';">'+text+'</pre></font>';
	else if(font_size=='H2') html_text = '<font id="f'+id+'" style="font-size:18px; color:'+font_color+';"><pre id="p'+id+'" style="font-size:18px;background:'+bg_color+';">'+text+'</pre></font>';
	else if(font_size=='H1') html_text = '<font id="f'+id+'" style="font-size:22px; color:'+font_color+';"><pre id="p'+id+'" style="font-size:22px;background:'+bg_color+';">'+text+'</pre></font>';
	else html_text = '<font id="f'+id+'" style="color:'+font_color+';"><pre id="p'+id+'" style="background:'+bg_color+';">'+text+'</pre></font>';
	
	//bold, italic, underline, hyperlink 설정
	if(bold_check==true) html_text = '<b id="b'+id+'">'+html_text+'</b>';
	if(italic_check==true) html_text = '<i id="i'+id+'">'+html_text+'</i>';
	if(underline_check==true) html_text = '<u id="u'+id+'">'+html_text+'</u>';
	if(link_check==true) {
		if(html_text.indexOf('http://')== -1) html_text = '<a href="http://'+text+'" id="h'+id+'" target="_blank">'+html_text+'</a>';
		else html_text = '<a href="'+text+'" id="h'+id+'" target="_blank">'+html_text+'</a>';
	}
	
	$('#a'+id).remove(); $('#u'+id).remove(); $('#i'+id).remove(); $('#b'+id).remove(); $('#f'+id).remove(); $('#p'+id).remove();
	$('#'+id).html(html_text);
	
	compHide();
	
	var data_arr = new Array();
	data_arr.push(id); data_arr.push("Caption"); data_arr.push(text);
	replaceTableObject(data_arr);
}

/* bubble_start ----------------------------------- 말풍선 삽입 버튼 설정 ------------------------------------- */
function inputBubble(id, text) {
	compHide();
	
	$('#bubble_font_color').attr('disabled', true);
	$('#bubble_bg_color').attr('disabled', true);
	
	if(id==0 & text=="") {
		//bubble dialog 내부 객체 초기화
		$('#bubble_font_select').val('Normal'); $('#bubble_font_color').val('#000000'); $('#bubble_font_color').css('background-color', '#000000'); $('#bubble_bg_color').val('#FFFFFF'); $('#bubble_bg_color').css('background-color', '#FFFFFF'); $('input[name=bubble_bg_checkbok]').attr('checked', true); $('#icp_bubble_bg_color').removeAttr('onclick'); $('#bubble_check').html('<input type="checkbox" id="bubble_bold" style="display:none;"/><img src="<c:url value="/images/geoImg/write/bold_off.png"/>" '+icon_css+' onclick="captionCheck(this);"><input type="checkbox" id="bubble_italic" style="display:none;" /><img src="<c:url value="/images/geoImg/write/italic_off.png"/>" '+icon_css+' onclick="captionCheck(this);"><input type="checkbox" id="bubble_underline" style="display:none;" /><img src="<c:url value="/images/geoImg/write/underLine_off.png"/>" '+icon_css+' onclick="captionCheck(this);"><input type="checkbox" id="bubble_link" style="display:none;"/><img src="<c:url value="/images/geoImg/write/hyperLink_off.png"/>" '+icon_css+' onclick="captionCheck(this);">'); $('#bubble_button').html('<button class="ui-state-default ui-corner-all" style="width:80px; height:30px; font-size:12px;" onclick="createBubble();">Input</button>'); $('#bubble_text').val('');
// 		$('#bubble_font_select').val('Normal'); $('#bubble_font_color').val('#000000'); $('#bubble_font_color').css('background-color', '#000000'); $('#bubble_bg_color').val('#FFFFFF'); $('#bubble_bg_color').css('background-color', '#FFFFFF'); $('input[name=bubble_bg_checkbok]').attr('checked', true); $('#icp_bubble_bg_color').removeAttr('onclick'); $('#bubble_check').html('<input type="checkbox" id="bubble_bold" class="bubble_bold" /><label for="bubble_bold" style="width:30px; height:30px;">Bold</label><input type="checkbox" id="bubble_italic" class="bubble_italic" /><label for="bubble_italic" style="width:30px; height:30px;">Italic</label><input type="checkbox" id="bubble_underline" class="bubble_underline" /><label for="bubble_underline" style="width:30px; height:30px;">Underline</label><input type="checkbox" id="bubble_link" class="bubble_link" /><label for="bubble_link" style="width:30px; height:30px;">HyperLink</label>'); $('.bubble_bold').button({ icons: { primary: 'ui-icon-bold'}, text: false }); $('.bubble_italic').button({ icons: { primary: 'ui-icon-italic'}, text: false }); $('.bubble_underline').button({ icons: { primary: 'ui-icon-underline'}, text: false }); $('.bubble_link').button({ icons: { primary: 'ui-icon-link'}, text: false }); $('#bubble_button').html('<button class="ui-state-default ui-corner-all" style="width:80px; height:30px; font-size:12px;" onclick="createBubble();">입력</button>'); $('#bubble_text').val('');
	}
	else {
		//caption dialog 내부 객체 설정
		var font_size = $('#f'+id).css('font-size');
		if(font_size == '14px') $('#bubble_font_select').val('H3');
		else if(font_size == '18px') $('#bubble_font_select').val('H2');
		else if(font_size == '22px') $('#bubble_font_select').val('H1');
		else $('#bubble_font_select').val('Normal');
		var font_color = rgb2hex($('#f'+id).css('color')); $('#bubble_font_color').val(font_color); $('#bubble_font_color').css('background-color', font_color);
		var bg_color_value = $('#p'+id).css('backgroundColor'); var bg_color = '';
		if(bg_color_value!='transparent') { bg_color = rgb2hex($('#p'+id).css('backgroundColor')); $('input[name=bubble_bg_checkbok]').attr('checked', false); }
		else { bg_color = '#FFFFFF'; $('input[name=bubble_bg_checkbok]').attr('checked', true); }
		$('#bubble_bg_color').val(bg_color); $('#bubble_bg_color').css('background-color', bg_color);
		
		var check_html = ""; 
		var html_text = $('#'+id).html();
		var img_kind = 'off';
		check_html += '<input type="checkbox" id="bubble_bold" style="display:none;" ';
		if(html_text.indexOf('<b id') != -1){
			check_html += ' checked="checked" ';
			img_kind = 'on';
		}
		check_html += ' /><img src="<c:url value="/images/geoImg/write/bold_'+img_kind+'.png"/>" '+icon_css+' onclick="captionCheck(this);">';
		
		img_kind = 'off';
		check_html += '<input type="checkbox" id="bubble_italic" style="display:none;"';
		if(html_text.indexOf('<i id') != -1){
			check_html += ' checked="checked" ';
			img_kind = 'on';
		}
		check_html += ' /><img src="<c:url value="/images/geoImg/write/italic_'+img_kind+'.png"/>" '+icon_css+' onclick="captionCheck(this);">';
		
		img_kind = 'off';
		check_html += '<input type="checkbox" id="bubble_underline"  style="display:none;"';
		if(html_text.indexOf('<u id') != -1){
			check_html += ' checked="checked" ';
			img_kind = 'on';
		}
		check_html += ' /><img src="<c:url value="/images/geoImg/write/underLine_'+img_kind+'.png"/>" '+icon_css+' onclick="captionCheck(this);">';
		
		img_kind = 'off';
		check_html += '<input type="checkbox" id="bubble_link" style="display:none;"';
		if(html_text.indexOf('<a href') != -1){
			check_html += ' checked="checked" ';
			img_kind = 'on';
		}
		check_html += ' /><img src="<c:url value="/images/geoImg/write/hyperLink_'+img_kind+'.png"/>" '+icon_css+' onclick="captionCheck(this);">';
		
// 		if(html_text.indexOf('<b id') != -1) check_html += '<input type="checkbox" id="bubble_bold" class="bubble_bold" checked="checked" /><label for="bubble_bold" style="width:30px; height:30px;">Bold</label>';
// 		else check_html += '<input type="checkbox" id="bubble_bold" class="bubble_bold" /><label for="bubble_bold" style="width:30px; height:30px;">Bold</label>';
// 		if(html_text.indexOf('<i id') != -1) check_html += '<input type="checkbox" id="bubble_italic" class="bubble_italic" checked="checked" /><label for="bubble_italic" style="width:30px; height:30px;">Italic</label>';
// 		else check_html += '<input type="checkbox" id="bubble_italic" class="bubble_italic" /><label for="bubble_italic" style="width:30px; height:30px;">Italic</label>';
// 		if(html_text.indexOf('<u id') != -1) check_html += '<input type="checkbox" id="bubble_underline" class="bubble_underline" checked="checked" /><label for="bubble_underline" style="width:30px; height:30px;">Underline</label>';
// 		else check_html += '<input type="checkbox" id="bubble_underline" class="bubble_underline" /><label for="bubble_underline" style="width:30px; height:30px;">Underline</label>';
// 		if(html_text.indexOf('<a href') != -1) check_html += '<input type="checkbox" id="bubble_link" class="bubble_link" checked="checked" /><label for="bubble_link" style="width:30px; height:30px;">HyperLink</label>';
// 		else check_html += '<input type="checkbox" id="bubble_link" class="bubble_link" /><label for="bubble_link" style="width:30px; height:30px;">HyperLink</label>';
// 		$('#bubble_check').html(check_html); $('.bubble_bold').button({ icons: { primary: 'ui-icon-bold'}, text: false }); $('.bubble_italic').button({ icons: { primary: 'ui-icon-italic'}, text: false }); $('.bubble_underline').button({ icons: { primary: 'ui-icon-underline'}, text: false }); $('.bubble_link').button({ icons: { primary: 'ui-icon-link'}, text: false }); $('#bubble_text').val($('#p'+id).html()); $('#bubble_button').html('<button id="bubble_replace_btn" class="ui-state-default ui-corner-all" style="width:80px; height:30px; font-size:12px;">수정</button>');

		$('#bubble_check').html(check_html);
		$('#bubble_text').val($('#p'+id).html()); 
		$('#bubble_button').html('<button id="bubble_replace_btn" class="ui-state-default ui-corner-all" style="width:80px; height:30px; font-size:12px;">수정</button>');
		$('#bubble_replace_btn').click(function() { replaceBubble(id); });
	}
	
	document.getElementById('bubble_dialog').style.display='block';
}

function checkBubble() {
	if(!$('input[name=bubble_bg_checkbok]').attr('checked')) { $('#icp_bubble_bg_color').bind('click', function() { iColorShow('bubble_bg_color','icp_bubble_bg_color'); }); }
	else { $('#icp_bubble_bg_color').unbind('click'); }
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
	
	var div_element = $(document.createElement('div')); div_element.attr('id', auto_bubble_str); div_element.attr('style', 'position:absolute; left:10px; top:10px; display:block;'); div_element.html(html_text); div_element.draggable(); div_element.dblclick(function() { inputBubble(div_element.attr('id'), text); }); div_element.appendTo('#image_main_area');

	$('#'+div_element.attr('id')).contextMenu('context1', {
		bindings: {
			'context_modify': function(t) { inputBubble(t.id, text); },
			'context_delete': function(t) { jConfirm('Are you sure you want to delete?', 'Info', function(type){ 	if(type) { $('#'+t.id).remove(); removeTableObject(t.id); } }); }
// 			'context_delete': function(t) { jConfirm('정말 삭제하시겠습니까?', '정보', function(type){ 	if(type) { $('#'+t.id).remove(); removeTableObject(t.id); } }); }
		}
	});
	
	auto_bubble_num++;

	compHide();
	
	var data_arr = new Array();
	data_arr.push(auto_bubble_str); data_arr.push("Bubble"); data_arr.push(text);
	insertTableObject(data_arr);
}

function replaceBubble(id) {
	var font_size = $('#bubble_font_select').val();
	var font_color = $('#bubble_font_color').val();
	var bg_color = $('#bubble_bg_color').val();
	var bg_check = $('input[name=bubble_bg_checkbok]').attr('checked');
	var bold_check = $('#bubble_bold').attr('checked');
	var italic_check = $('#bubble_italic').attr('checked');
	var underline_check = $('#bubble_underline').attr('checked');
	var link_check = $('#bubble_link').attr('checked');
	var text = $('#bubble_text').val();
	
	if(bg_check==true) bg_color = '';
	
	var html_text;
	//폰트, 색상 설정
	if(font_size=='H3') html_text = '<font id="f'+id+'" style="font-size:14px; color:'+font_color+';"><pre id="p'+id+'" style="font-size:14px;background:'+bg_color+';">'+text+'</pre></font>';
	else if(font_size=='H2') html_text = '<font id="f'+id+'" style="font-size:18px; color:'+font_color+';"><pre id="p'+id+'" style="font-size:18px;background:'+bg_color+';">'+text+'</pre></font>';
	else if(font_size=='H1') html_text = '<font id="f'+id+'" style="font-size:22px; color:'+font_color+';"><pre id="p'+id+'" style="font-size:22px;background:'+bg_color+';">'+text+'</pre></font>';
	else html_text = '<font id="f'+id+'" style="color:'+font_color+';"><pre id="p'+id+'" style="background:'+bg_color+';">'+text+'</pre></font>';
	//bold, italic, underline, hyperlink 설정
	if(bold_check==true) html_text = '<b id="b'+id+'">'+html_text+'</b>';
	if(italic_check==true) html_text = '<i id="i'+id+'">'+html_text+'</i>';
	if(underline_check==true) html_text = '<u id="u'+id+'">'+html_text+'</u>';
	if(link_check==true) {
		if(html_text.indexOf('http://')== -1) html_text = '<a href="http://'+text+'" id="h'+id+'" target="_blank">'+html_text+'</a>';
		else html_text = '<a href="'+text+'" id="h'+id+'" target="_blank">'+html_text+'</a>';
	}
	
	$('#a'+id).remove(); $('#u'+id).remove(); $('#i'+id).remove(); $('#b'+id).remove(); $('#f'+id).remove(); $('#p'+id).remove();
	$('#'+id).html(html_text);
	
	compHide();
	
	var data_arr = new Array();
	data_arr.push(id); data_arr.push("Bubble"); data_arr.push(text);
	replaceTableObject(data_arr);
}

/* icon_start ----------------------------------- 아이콘 & 이미지 삽입 버튼 설정 ------------------------------------- */
function inputIcon() {
	compHide();
	
	for(var i=1; i<131; i++) {
		$('#icon_img'+i).attr('src', '<c:url value="/images/geoImg/icon/black/d'+i+'.png"/>');
		$('#icon_img'+i).unbind('mouseover');
		$('#icon_img'+i).bind('mouseover', function() {
			var buf = this.id.split('icon_img');
			$('#'+this.id).attr('src', '<c:url value="/images/geoImg/icon/white/d'+buf[1]+'_over.png"/>');
		});
		$('#icon_img'+i).unbind('mouseout');
		$('#icon_img'+i).bind('mouseout', function() {
			var buf = this.id.split('icon_img');
			$('#'+this.id).attr('src', '<c:url value="/images/geoImg/icon/black/d'+buf[1]+'.png"/>');
		});
		$('#icon_img'+i).unbind('click');
		$('#icon_img'+i).bind('click', function() {
			var buf = this.id.split('icon_img');
			var src = '<c:url value="/images/geoImg/icon/black/d'+buf[1]+'.png"/>';
			createIcon(src);
		});
	}
	document.getElementById('icon_dialog').style.display='block';
}
function tabImage(num) {
	if(num==1) {
		document.getElementById('icon_div1').style.display='block';
		document.getElementById('icon_div2').style.display='none';
	}
	else if(num==2) {
		document.getElementById('icon_div1').style.display='none';
		document.getElementById('icon_div2').style.display='block';
	}
	else {}
}

//text icon change
function captionCheck(obj){
	if(obj.src.indexOf('off') > -1){
		obj.src = obj.src.replace("off","on");
		$(obj).prev().attr('checked', true);
	}else{
		obj.src = obj.src.replace("on","off");
		$(obj).prev().attr('checked', false);
	}
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
				jConfirm('Are you sure you want to delete?', 'Info', function(type){ if(type) $('#'+t.id).remove(); removeTableObject(t.id); });
// 				jConfirm('정말 삭제하시겠습니까?', '정보', function(type){ if(type) $('#'+t.id).remove(); removeTableObject(t.id); });
			}
		}
	});
	
	auto_icon_num++;
	
	compHide();
	
	var data_arr = new Array();
	data_arr.push(auto_icon_str); data_arr.push("Image"); data_arr.push(img_src);
	insertTableObject(data_arr);
}


/* geo_start ----------------------------------- 지오매트리 삽입 버튼 설정 ------------------------------------- */

function inputGeometry() {
	compHide();
	$('#geometry_line_color').attr('disabled', true); $('#geometry_bg_color').attr('disabled', true); $('#geometry_line_color').val('#959595'); $('#geometry_line_color').css('background-color', '#999999'); $('#geometry_bg_color').val('#FF0000'); $('#geometry_bg_color').css('background-color', '#FF0000');
	document.getElementById('geometry_dialog').style.display='block';
}

function setGeometry() {
	var geo_type = $("input[name='geo_shape']:checked").val();
	if(geo_type=='circle') { inputGeometryShape(1); }
	else if(geo_type=='rect') { inputGeometryShape(2); }
	else { inputGeometryShape(3); }
}

//Geometry Common Value
var auto_geometry_str; var auto_geometry_num = 0; var geometry_point_arr_1 = new Array(); var geometry_point_arr_2 = new Array();
var geometry_total_arr_1 = new Array(); var geometry_total_arr_2 = new Array();
var geometry_total_arr_buf_1 = new Array(); var geometry_total_arr_buf_2 = new Array();
//Geometry Circle & Rect Value
var geometry_click_move_val = false; var geometry_click_move_point_x = 0; var geometry_click_move_point_y = 0;
//Geometry Point Value
var geometry_point_before_x = 0; var geometry_point_before_y = 0; var geometry_point_num = 1;

function inputGeometryShape(type) {
	compHide();
	var left = $('#image_write_canvas').css('left'); var top = $('#image_write_canvas').css('top'); var width = $('#image_write_canvas').attr('width'); var height = $('#image_write_canvas').attr('height');
	var canvas_element = $(document.createElement('canvas'));
	canvas_element.attr('id', 'geometry_draw_canvas'); canvas_element.attr('style', 'position:absolute; display:block; left:'+left+'; top:'+top+';'); canvas_element.attr('width', width); canvas_element.attr('height', height);
	
	if(type==1) {
		canvas_element.mousedown(function(e) {
			geometry_click_move_val = true;
			//좌표점 계산
			var left_str = $('#image_main_area').css('left'); var top_str = $('#image_main_area').css('top'); var left = parseInt(left_str.replace('px','')); var top = parseInt(top_str.replace('px','')); geometry_click_move_point_x = e.pageX - (this.offsetLeft + left); geometry_click_move_point_y = e.pageY - (this.offsetTop + top);
			geometry_point_arr_1 = null; geometry_point_arr_2 = null; geometry_point_arr_1 = new Array(); geometry_point_arr_2 = new Array();
			geometry_point_arr_1.push(geometry_click_move_point_x); geometry_point_arr_2.push(geometry_click_move_point_y);
		});
		canvas_element.mouseup(function(e) {
			geometry_click_move_val = false;
			//좌표점 계산
			var left_str = $('#image_main_area').css('left'); var top_str = $('#image_main_area').css('top'); var left = parseInt(left_str.replace('px','')); var top = parseInt(top_str.replace('px',''));
			geometry_point_arr_1.push(e.pageX - (this.offsetLeft + left)); geometry_point_arr_2.push(e.pageY - (this.offsetTop + top));
		});
		canvas_element.mousemove(function(e) {
			if(geometry_click_move_val) {
				//마우스 좌표 가져오기
				var left_str = $('#image_main_area').css('left'); var top_str = $('#image_main_area').css('top'); var left = parseInt(left_str.replace('px','')); var top = parseInt(top_str.replace('px','')); var mouse_x = e.pageX - (this.offsetLeft + left); var mouse_y = e.pageY - (this.offsetTop + top);
				//각 좌표 설정
				var start_x, start_y, width, height; width = Math.abs(geometry_click_move_point_x - mouse_x); height = Math.abs(geometry_click_move_point_y - mouse_y);
				if(geometry_click_move_point_x > mouse_x) start_x = mouse_x; else start_x = geometry_click_move_point_x;
				if(geometry_click_move_point_y > mouse_y) start_y = mouse_y; else start_y = geometry_click_move_point_y;
				var kappa = .5522848;
					ox = (width/2) * kappa, oy = (height/2) * kappa, xe = start_x + width, ye = start_y + height, xm = start_x + width/2, ym = start_y + height/2;
				//원 그리기
				var canvas = $('#geometry_draw_canvas');
				var context = document.getElementById('geometry_draw_canvas').getContext("2d");
				context.clearRect(0,0,canvas.attr('width'),canvas.attr('height'));
				context.strokeStyle = '#f00';
				context.beginPath(); context.moveTo(start_x, ym);
				context.bezierCurveTo(start_x, ym - oy, xm - ox, start_y, xm, start_y); context.bezierCurveTo(xm + ox, start_y, xe, ym - oy, xe, ym); context.bezierCurveTo(xe, ym + oy, xm + ox, ye, xm, ye); context.bezierCurveTo(xm - ox, ye, start_x, ym + oy, start_x, ym);
				context.closePath(); context.stroke();
			}
		});
	}
	else if(type==2) {
		canvas_element.mousedown(function(e) {
			geometry_click_move_val = true;
			//좌표점 계산
			var left_str = $('#image_main_area').css('left'); var top_str = $('#image_main_area').css('top'); var left = parseInt(left_str.replace('px','')); var top = parseInt(top_str.replace('px','')); geometry_click_move_point_x = e.pageX - (this.offsetLeft + left); geometry_click_move_point_y = e.pageY - (this.offsetTop + top);
			geometry_point_arr_1 = null; geometry_point_arr_2 = null; geometry_point_arr_1 = new Array(); geometry_point_arr_2 = new Array();
			geometry_point_arr_1.push(geometry_click_move_point_x); geometry_point_arr_2.push(geometry_click_move_point_y);
		});
		canvas_element.mouseup(function(e) {
			geometry_click_move_val = false;
			//좌표점 계산
			var left_str = $('#image_main_area').css('left'); var top_str = $('#image_main_area').css('top'); var left = parseInt(left_str.replace('px','')); var top = parseInt(top_str.replace('px',''));
			geometry_point_arr_1.push(e.pageX - (this.offsetLeft + left)); geometry_point_arr_2.push(e.pageY - (this.offsetTop + top));
		});
		canvas_element.mousemove(function(e) {
			if(geometry_click_move_val) {
				//마우스 좌표 가져오기
				var left_str = $('#image_main_area').css('left'); var top_str = $('#image_main_area').css('top'); var left = parseInt(left_str.replace('px','')); var top = parseInt(top_str.replace('px','')); var mouse_x = e.pageX - (this.offsetLeft + left); var mouse_y = e.pageY - (this.offsetTop + top);
				//각 좌표 설정
				var start_x, start_y, width, height;
				width = Math.abs(geometry_click_move_point_x - mouse_x); height = Math.abs(geometry_click_move_point_y - mouse_y);
				if(geometry_click_move_point_x > mouse_x) start_x = mouse_x;
				else start_x = geometry_click_move_point_x;
				if(geometry_click_move_point_y > mouse_y) start_y = mouse_y;
				else start_y = geometry_click_move_point_y;
				//사각형 그리기
				var canvas = $('#geometry_draw_canvas');
				var context = document.getElementById('geometry_draw_canvas').getContext("2d");
				context.clearRect(0,0,canvas.attr('width'),canvas.attr('height'));
				context.strokeStyle = '#f00';
				context.strokeRect(start_x, start_y, width, height);
			}
		});
	}
	else {
		canvas_element.click(function(e) {
			//좌표점 계산
			var left_str = $('#image_main_area').css('left'); var top_str = $('#image_main_area').css('top'); var left = parseInt(left_str.replace('px','')); var top = parseInt(top_str.replace('px','')); var x = e.pageX - (this.offsetLeft + left); var y = e.pageY - (this.offsetTop + top);
			//클릭 좌표점에 원과 숫자 그리기
			var context = document.getElementById('geometry_draw_canvas').getContext("2d"); context.strokeStyle = '#f00'; context.beginPath(); context.arc(x, y, 5, 0, 2*Math.PI, true); context.stroke();
			if(geometry_point_num>=10) context.fillText(geometry_point_num, x-7, y-6); else context.fillText(geometry_point_num, x-3, y-6);
			geometry_point_num++;
			if(geometry_point_before_x == 0 && geometry_point_before_y == 0) { geometry_point_before_x = x; geometry_point_before_y = y; }
			else { context.moveTo(geometry_point_before_x, geometry_point_before_y); context.lineTo(x, y); geometry_point_before_x = x; geometry_point_before_y = y; context.stroke(); }
			context.closePath();
			geometry_point_arr_1.push(x);
			geometry_point_arr_2.push(y);
		});
	}
	canvas_element.appendTo('#image_main_area');
	
	//그리기 완료 및 그리기 취소 버튼
	var html_text = '<button class="geometry_complete_button" onclick="createGeometry('+type+');" style="left:0px; top:0px;">그리기 완료</button>';
	html_text += '<button class="geometry_cancel_button" onclick="cancelGeometry();" style="left:10px; top:0px;">그리기 취소</button>';
	$('#image_main_area').append(html_text);
	$('.geometry_complete_button').button(); $('.geometry_cancel_button').button();
	$('.geometry_complete_button').width(100); $('.geometry_cancel_button').width(100);
	$('.geometry_complete_button').height(30); $('.geometry_cancel_button').height(30);
	$('.geometry_complete_button').css('fontSize', 12); $('.geometry_cancel_button').css('fontSize', 12);
}

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
	$('#'+canvas_element.attr('id')).contextMenu('context3', {
		bindings: {
			'context_add': function(t) {
				var obj = $('#'+t.id);
				var top = obj.css('top'); top = top.replace('px','');
				var left = obj.css('left'); left = left.replace('px','');
				autoCreateText('b', 'Normal', '#000000', '#FFFFFF', 'false', 'false', 'false', 'false', t.id+'의 말풍선', top, left);
			},
			'context_delete': function(t) { jConfirm('Are you sure you want to delete?', 'Info', function(type){ if(type) $('#'+t.id).remove(); removeTableObject(t.id); }); }
// 			'context_delete': function(t) { jConfirm('정말 삭제하시겠습니까?', '정보', function(type){ if(type) $('#'+t.id).remove(); removeTableObject(t.id); }); }
		}
	});

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

/* exif_start ----------------------------------- EXIF 설정 ------------------------------------- */
function loadExif() {
	//ajax 송신 시 URL 을 수정해줘야 함..
	//viewer 의 depth 에 따른 URL 문제로 ExifServlet 을 호출할 경우
	//http://xxx.xxx.xxx.xxx:8002/GeoCMS/sub/viewer/ExifServlet 으로 호출됨..
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

function saveExif() {
	var encode_file_name = encodeURIComponent(upload_url + file_url);
	
	var data_text = "";
	if($('#comment_text').val()!='Not Found.') data_text += $('#comment_text').val() + "\<LineSeparator\>";
	else data_text += "\<NONE\>\<LineSeparator\>";
	if($('#gps_direction_text').val()!='Not Found.') data_text += $('#gps_direction_text').val() + "\<LineSeparator\>";
	else data_text += "\<NONE\>\<LineSeparator\>";
	if($('#lon_text').val()!='Not Found.') data_text += $('#lon_text').val() + "\<LineSeparator\>";
	else data_text += "\<NONE\>\<LineSeparator\>";
	if($('#lat_text').val()!='Not Found.') data_text += $('#lat_text').val() + "\<LineSeparator\>";
	else data_text += "\<NONE\>";

// 	else data_text += "\<NONE\>\<LineSeparator\>";
// 	if($('#alt_text').val()!='Not Found.') data_text += $('#alt_text').val() + "\<LineSeparator\>";
// 	else data_text += "\<NONE\>\<LineSeparator\>";
// 	if($('#focal_text').val()!='Not Found.') data_text += $('#focal_text').val() + "\<LineSeparator\>";
// 	else data_text += "\<NONE\>";
	
	$.ajax({
		type: 'POST',
		url: base_url + '/geoExif.do',
		data: 'file_name='+encode_file_name+'&type=save&data='+data_text,
		success: function(data) {
			var response = data.trim();
// 			jAlert('정상적으로 저장 되었습니다.', '정보');
			jAlert('Saved successfully.', 'Info');
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

/* save_start ----------------------------------- 저장 버튼 및 불러오기 설정 ------------------------------------- */
//저장 버튼 다이얼로그 오픈
function saveSetting() {
	$('#save_dialog').dialog('open');
}
//저장 실행
function saveImageWrite(type) {
	$('#save_dialog').dialog('close');
	
	var obj_data_arr = new Array();
	
	var html_text = '';
	
	var objCount = $('#image_main_area').children().size(); // 오브젝트 몇개인지파악(그림까지 포함이니 +1)
	for(var i=0; i<objCount; i++) {
		var obj = $('#image_main_area').children().eq(i);
		var id = obj.attr('id');
		if(id=='') { obj = obj.children().eq(0); id = obj.attr('id'); }
		
		if(id!='image_write_canvas') {
			if(id.indexOf("c")!=-1) {
				var obj_font = $('#f'+id);
				var obj_pre = $('#p'+id); // 디버깅시 background: 값이 없다.
				
				obj_data_arr.push([id.substring(0, 1), obj.position().top, obj.position().left, obj.html(), obj_font.css('font-size'), obj_font.css('color'), obj_pre.css('backgroundColor'), obj_pre.html()]);
			}
			else if(id.indexOf("b")!=-1) {
				var obj_font = $('#f'+id);
				var obj_pre = $('#p'+id);
				var obj_pre_text = obj_pre.html();
				obj_pre_text = obj_pre_text.replace(/(\n|\r)+/g, "@line@");
				obj_data_arr.push([id.substring(0, 1), obj.position().top, obj.position().left, obj.html(), obj_font.css('font-size'), obj_font.css('color'), obj_pre.css('backgroundColor'), obj_pre_text]);
			}
			else if(id.indexOf("i")!=-1) {
				obj_data_arr.push([id.substring(0, 1), obj.parent().position().top, obj.parent().position().left, obj.css('width'), obj.css('height'), obj.attr('src')]);
			}
			else if(id.indexOf("g")!=-1) {
				var check_id, left, top, x_str, y_str, line_color, bg_color, geo_type;
				for(var j=0; j<geometry_total_arr_buf_1.length; j++) {
					var buf1 = geometry_total_arr_buf_1[j].split("\@");
					var buf2 = geometry_total_arr_buf_2[j].split("\@");
					check_id = buf1[0]; left = buf1[1]; top = buf2[1]; x_str = buf1[2]; y_str = buf2[2]; line_color = buf1[3]; bg_color = buf2[3]; geo_type = buf2[4];
					if(check_id==id) { obj_data_arr.push([id.substring(0, 1), top, left, x_str, y_str, line_color, bg_color, geo_type]); }
				}
			}
			else {}
		}
	}
	var xml_text = makeXMLStr(obj_data_arr);
	var encode_xml_text = encodeURIComponent(xml_text); // xml text encoding

	var encode_file_name = encodeURIComponent(upload_url + file_url);
	
	if(type==1 || type==2) {
		//xml 저장
		$.ajax({
			type: 'POST',
			url: base_url + '/geoXml.do',
			data: 'file_name='+encode_file_name+'&xml_data='+encode_xml_text,
			success: function(data) {
				var response = data.trim();
				if(response == 'XML_SAVE_SUCCESS'){
					if(projectBoard == 1){
// 						alert($('#gps_direction_text').val() + " : " + $('#lon_text').val() + " :  " + $('#lat_text').val());
// 						if($('#gps_direction_text').val()!='Not Found.') data_text += $('#gps_direction_text').val() + "\<LineSeparator\>";
// 						else data_text += "\<NONE\>\<LineSeparator\>";
// 						if($('#lon_text').val()!='Not Found.') data_text += $('#lon_text').val() + "\<LineSeparator\>";
// 						else data_text += "\<NONE\>\<LineSeparator\>";
// 						if($('#lat_text').val()!='Not Found.') data_text += $('#lat_text').val() + "\<LineSeparator\>";
// 						else data_text += "\<NONE\>";
						
						var tmp_xml_text = xml_text.replace(/\//g,'&sbsp');
						tmp_xml_text = tmp_xml_text.replace(/\?/g,'&mbsp');
						tmp_xml_text = tmp_xml_text.replace(/\#/g,'&pbsp');
						tmp_xml_text = tmp_xml_text.replace(/\./g,'&obsp');
						
						var tmpTitle = $('#title_area').val();
						var tmpContent = document.getElementById('content_area').value;
						var tmpShareType = $('input[name=shareRadio]:checked').val();
						var tmpAddShareUser = $('#shareAdd').val();
						var tmpRemoveShareUser = $('#shareRemove').val();
						var tmpTabName = $('#showKind').val();
						var tmpEditYes = $('#editYes').val();
						var tmpEditNo = $('#editNo').val();
						
						var longitude = $('#lon_text').val();
						var latitude = $('#lat_text').val();
										
						if(tmpTitle == null || tmpTitle == "" || tmpTitle == 'null'){
// 							 jAlert('제목을 입력해 주세요.', '정보');
							 jAlert('Please enter the subject.', 'Info');
							 return;
						 }
						 
						 if(tmpContent == null || tmpContent == "" || tmpContent == 'null'){
// 							 jAlert('내용을 입력해 주세요.', '정보');
							 jAlert('Please enter your details.', 'Info');
							 return;
						 }
						 
						 if(tmpShareType != null && tmpShareType == 2 && (tmpAddShareUser == null || tmpAddShareUser == '') && oldShareUserLen == 0){
// 							 jAlert('공유 유저가 지정되지 않았습니다.', '정보');
							 jAlert('No sharing user specified.', 'Info');
							 return;
						 }
						 
						 if(tmpTitle != null && tmpTitle.indexOf('\'') > -1){
// 								alert('특수문자 \' 는 사용할 수 없습니다.');
								jAlert("Special characters \ ' can not be used.", 'Info');
								return;
						 }	
						 if(tmpContent != null && tmpContent.indexOf('\'') > -1){
// 								alert('특수문자 \' 는 사용할 수 없습니다.');
								jAlert("Special characters \ ' can not be used.", 'Info');
								return;
						 }
						 tmpTitle = tmpTitle.replace(/\//g,'&sbsp').replace(/\?/g,'&mbsp').replace(/\#/g,'&pbsp').replace(/\./g,'&obsp').replace(/</g,'&lt').replace(/>/g,'&gt').replace(/\\/g,'&bt').replace(/%/g,'&mt').replace(/;/g,'&vbsp').replace(/\r/g,'&rnsp').replace(/\n/g,'&nnsp');
						 tmpContent = tmpContent.replace(/\//g,'&sbsp').replace(/\?/g,'&mbsp').replace(/\#/g,'&pbsp').replace(/\./g,'&obsp').replace(/</g,'&lt').replace(/>/g,'&gt').replace(/\\/g,'&bt').replace(/%/g,'&mt').replace(/;/g,'&vbsp').replace(/\r/g,'&rnsp').replace(/\n/g,'&nnsp');

						if(tmpAddShareUser == null || tmpAddShareUser.length <= 0){ tmpAddShareUser = '&nbsp'; }
						if(tmpRemoveShareUser == null || tmpRemoveShareUser.length <= 0){ tmpRemoveShareUser = '&nbsp'; }
						if(tmpEditYes == null || tmpEditYes == ''){ tmpEditYes = '&nbsp'; }
						if(tmpEditNo == null || tmpEditNo == ''){ tmpEditNo = '&nbsp'; }
						
						if(longitude == null || longitude == '' || longitude == 'Not Found.'){ longitude = '&nbsp'; }
						if(latitude == null || latitude == '' || latitude == 'Not Found.'){ latitude = '&nbsp'; }
						
						var Url			= baseRoot() + "cms/updateImage/";
						var param		= loginToken + "/" + loginId + "/" + idx + "/" + tmpTitle + "/" + tmpContent + "/" + tmpTabName + "/" + tmpShareType + "/" + tmpAddShareUser + "/" + tmpRemoveShareUser + "/" + tmp_xml_text + "/" + longitude + "/" +latitude +"/" + tmpEditYes + "/" + tmpEditNo;
						var callBack	= "?callback=?";
						
						$.ajax({
							type	: "POST"
							, url	: Url + param + callBack
							, dataType	: "jsonp"
							, async	: false
							, cache	: false
							, success: function(data) {
								var response = data.Data;
								if(data.Code == '100'){
									//exif 저장
					 				var comment_text = $('#comment_text').val();
					 				$('#comment_text').val(comment_text+xml_text);
					 				saveExif();
					 				$('#comment_text').val(comment_text);
					 				
					 				$('#showKindLabel').text();
					 				$('#shareKindLabel').text();
								}else{
									jAlert(data.Message, 'Info');
								}
							}
						});
					}else{
						//exif 저장
		 				var comment_text = $('#comment_text').val();
		 				$('#comment_text').val(comment_text+xml_text);
		 				saveExif();
		 				$('#comment_text').val(comment_text);
					}
				}
			}
		});
	}
	else if(type==3) {
		xml_text = xml_text.replace(/><+/g, "\>\\n\<");
		var conv_xml_text = encodeURIComponent(xml_text);
		
		window.open('', 'xml_view_page', 'width=530, height=630');
		var form = document.createElement('form');
		form.setAttribute('method','get');
		form.setAttribute('action','<c:url value="/geoPhoto/xml_view.do"/>');
		form.setAttribute('target','xml_view_page');
		document.body.appendChild(form);
		
		var insert = document.createElement('input');
		insert.setAttribute('type','hidden');
		insert.setAttribute('name','xml_data');
		insert.setAttribute('value',conv_xml_text);
		form.appendChild(insert);
		
		form.submit();
	}
	else if(type==4) {
		
		var emailAdrs = $('#eml').val();
		
		if(emailAdrs == "") {
			jAlert("please, put E-mail adress in the box",'Info');
		}
		else{
			
			
		}
		
	}
	else {}
}

function makeXMLStr(obj_data_arr) {
	var xml_text = '<?xml version="1.0" encoding="utf-8"?>';
	xml_text += "<upcm_obj>";
	for(var i=0; i<obj_data_arr.length; i++) {
		var buf_arr = obj_data_arr[i];
		var id = buf_arr[0];
		xml_text += "<obj>";
		xml_text += "<id>" + id + "</id>";
		if(id == "c" || id == "b") {
			var top = buf_arr[1];
			xml_text += "<top>" + top + "</top>";
			
			var left = buf_arr[2];
			xml_text += "<left>" + left + "</left>";
			
			var html_text = buf_arr[3];
			var href = "false";
			if(html_text.indexOf("<a href=")!=-1) href = "true";
			var underline = "false";
			if(html_text.indexOf("<u id=")!=-1) underline = "true";
			var italic = "false";
			if(html_text.indexOf("<i id=")!=-1) italic = "true";
			var bold = "false";
			if(html_text.indexOf("<b id=")!=-1) bold = "true";
			xml_text += "<href>" + href + "</href><underline>" + underline + "</underline><italic>" + italic + "</italic><bold>" + bold + "</bold>";
			
			var font_size = buf_arr[4];
			if(font_size == '14px') xml_text += "<fontsize>H3</fontsize>";
			else if(font_size == '18px') xml_text += "<fontsize>H2</fontsize>";
			else if(font_size == '22px') xml_text += "<fontsize>H1</fontsize>";
			else xml_text += "<fontsize>Normal</fontsize>";
			
			var font_color = rgb2hex(buf_arr[5]);
			xml_text += "<fontcolor>" + font_color + "</fontcolor>";
			
			var background_color = "none";
			
			if(buf_arr[6]!='rgba(0, 0, 0, 0)') 
			{	background_color = rgb2hex(buf_arr[6]);
				xml_text += "<backgroundcolor>" + background_color + "</backgroundcolor>";
			}
			else if(buf_arr[6]=='rgba(0, 0, 0, 0)')
			{
				xml_text += "<backgroundcolor></backgroundcolor>";
			}
			var text = buf_arr[7];
			xml_text += "<text>" + text + "</text>";
		}
		else if(id == "i") {
			var top = buf_arr[1];
			xml_text += "<top>" + top + "</top>";
			
			var left = buf_arr[2];
			xml_text += "<left>" + left + "</left>";
			
			var width = buf_arr[3];
			xml_text += "<width>" + width + "</width>";
			
			var height = buf_arr[4];
			xml_text += "<height>" + height + "</height>";
			
			var src = buf_arr[5];
			xml_text += "<src>" + src + "</src>";
		}
		else if(id == "g") {
			var top = buf_arr[1];
			xml_text += "<top>" + top + "</top>";
			
			var left = buf_arr[2];
			xml_text += "<left>" + left + "</left>";
			
			var x_str = buf_arr[3];
			xml_text += "<xstr>" + x_str + "</xstr>";
			
			var y_str = buf_arr[4];
			xml_text += "<ystr>" + y_str + "</ystr>";
			
			var line_color = '#' + buf_arr[5];
			xml_text += "<linecolor>" + line_color + "</linecolor>";
			
			var background_color = '#' + buf_arr[6];
			xml_text += "<backgroundcolor>" + background_color + "</backgroundcolor>";
			
			var type = buf_arr[7];
			xml_text += "<type>" + type + "</type>";
		}
		else {}
		
		xml_text += "</obj>";
	}
	xml_text += "</upcm_obj>";
	
	return xml_text;
}
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
		var img_kind = 'off';
		
		check_html += '<input type="checkbox" id="caption_bold" style="display:none;"';
		if(bold == 'true'){
			check_html += ' checked="checked" ';
			img_kind = 'on'; 
		}
		check_html += ' /><img src="<c:url value="/images/geoImg/write/bold_'+img_kind+'.png"/>" '+icon_css+' onclick="captionCheck(this);">';
		
		img_kind = 'off';
		check_html += '<input type="checkbox" id="caption_italic" style="display:none;"';
		if(italic == 'true'){
			check_html += ' checked="checked" ';
			img_kind = 'on'; 
		}else{
			check_html += ' /><img src="<c:url value="/images/geoImg/write/italic_'+img_kind+'.png"/>" '+icon_css+' onclick="captionCheck(this);">';
		}
		
		img_kind = 'off';
		check_html += '<input type="checkbox" id="caption_underline" style="display:none;"';
		if(underline == 'true'){
			check_html += ' checked="checked" ';
			img_kind = 'on'; 
		}else{
			check_html += ' /><img src="<c:url value="/images/geoImg/write/underLine_'+img_kind+'.png"/>" '+icon_css+' onclick="captionCheck(this);">';
		}
		
		img_kind = 'off';
		check_html += '<input type="checkbox" id="caption_link" style="display:none;"';
		if(href == 'true'){
			check_html += ' checked="checked" ';
			img_kind = 'on'; 
		}else{
			check_html += ' /><img src="<c:url value="/images/geoImg/write/link_'+img_kind+'.png"/>" '+icon_css+' onclick="captionCheck(this);">';
		}
		
// 		if(bold == 'true') check_html += '<input type="checkbox" id="caption_bold" class="caption_bold" checked="checked" /><label for="caption_bold" style="width:30px; height:30px;">Bold</label>';
// 		else check_html += '<input type="checkbox" id="caption_bold" class="caption_bold" /><label for="caption_bold" style="width:30px; height:30px;">Bold</label>';
// 		if(italic == 'true') check_html += '<input type="checkbox" id="caption_italic" class="caption_italic" checked="checked" /><label for="caption_italic" style="width:30px; height:30px;">Italic</label>';
// 		else check_html += '<input type="checkbox" id="caption_italic" class="caption_italic" /><label for="caption_italic" style="width:30px; height:30px;">Italic</label>';
// 		if(underline == 'true') check_html += '<input type="checkbox" id="caption_underline" class="caption_underline" checked="checked" /><label for="caption_underline" style="width:30px; height:30px;">Underline</label>';
// 		else check_html += '<input type="checkbox" id="caption_underline" class="caption_underline" /><label for="caption_underline" style="width:30px; height:30px;">Underline</label>';
// 		if(href == 'true') check_html += '<input type="checkbox" id="caption_link" class="caption_link" checked="checked" /><label for="caption_link" style="width:30px; height:30px;">HyperLink</label>';
// 		else check_html += '<input type="checkbox" id="caption_link" class="caption_link" /><label for="caption_link" style="width:30px; height:30px;">HyperLink</label>';
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
		var img_kind = 'off';
		check_html += '<input type="checkbox" id="bubble_bold" style="display:none;"';
		if(bold == 'true'){
			check_html += ' checked="checked" ';
			img_kind = 'on'; 
		}
		check_html += ' /><img src="<c:url value="/images/geoImg/write/bold_'+img_kind+'.png"/>" '+icon_css+' onclick="captionCheck(this);">';
		
		img_kind = 'off';
		check_html += '<input type="checkbox" id="bubble_italic" style="display:none;"';
		if(italic == 'true'){
			check_html += ' checked="checked" ';
			img_kind = 'on'; 
		}else{
			check_html += ' /><img src="<c:url value="/images/geoImg/write/italic_'+img_kind+'.png"/>" '+icon_css+' onclick="captionCheck(this);">';
		}
		
		img_kind = 'off';
		check_html += '<input type="checkbox" id="bubble_underline" style="display:none;"';
		if(underline == 'true'){
			check_html += ' checked="checked" ';
			img_kind = 'on'; 
		}else{
			check_html += ' /><img src="<c:url value="/images/geoImg/write/underLine_'+img_kind+'.png"/>" '+icon_css+' onclick="captionCheck(this);">';
		}
		
		img_kind = 'off';
		check_html += '<input type="checkbox" id="bubble_link" style="display:none;"';
		if(href == 'true'){
			check_html += ' checked="checked" ';
			img_kind = 'on'; 
		}else{
			check_html += ' /><img src="<c:url value="/images/geoImg/write/link_'+img_kind+'.png"/>" '+icon_css+' onclick="captionCheck(this);">';
		}
		
// 		if(bold == 'true') check_html += '<input type="checkbox" id="bubble_bold" class="bubble_bold" checked="checked" /><label for="bubble_bold" style="width:30px; height:30px;">Bold</label>';
// 		else check_html += '<input type="checkbox" id="bubble_bold" class="bubble_bold" /><label for="bubble_bold" style="width:30px; height:30px;">Bold</label>';
// 		if(italic == 'true') check_html += '<input type="checkbox" id="bubble_italic" class="bubble_italic" checked="checked" /><label for="bubble_italic" style="width:30px; height:30px;">Italic</label>';
// 		else check_html += '<input type="checkbox" id="bubble_italic" class="bubble_italic" /><label for="bubble_italic" style="width:30px; height:30px;">Italic</label>';
// 		if(underline == 'true') check_html += '<input type="checkbox" id="bubble_underline" class="bubble_underline" checked="checked" /><label for="bubble_underline" style="width:30px; height:30px;">Underline</label>';
// 		else check_html += '<input type="checkbox" id="bubble_underline" class="bubble_underline" /><label for="bubble_underline" style="width:30px; height:30px;">Underline</label>';
// 		if(href == 'true') check_html += '<input type="checkbox" id="bubble_link" class="bubble_link" checked="checked" /><label for="bubble_link" style="width:30px; height:30px;">HyperLink</label>';
// 		else check_html += '<input type="checkbox" id="bubble_link" class="bubble_link" /><label for="bubble_link" style="width:30px; height:30px;">HyperLink</label>';
		$('#bubble_check').html(check_html);
		text = text.replace(/@line@/g, "\r\n");
		$('#bubble_text').val(text);
		
		createBubble();
		var obj = $('#'+auto_bubble_str);
		obj.attr('style', 'position:absolute; left:'+left+'px; top:'+top+'px; display:block;');
	}
}

function loadXML() {
	var file_arr = file_url.split(".");   		// ["/upload/20141201_140526", "jpg"]
	var xml_file_name = file_arr[0] + '.xml';  		// "/upload/20141201_140526.xml"
	
	$.ajax({
		type: "GET",
		url: base_url + upload_url + xml_file_name,
// 		url: "<c:url value='/"+ xml_file_name +"'/>",
		dataType: "xml",
		cache: false,
		success: function(xml) {
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
			//alert('XML 호출 오류! 관리자에게 문의하여 주세요.');
		}
	});
}

/* exit_start ----------------------------------- 종료 버튼 설정 ------------------------------------- */
function closeImageWrite() {
// 	jConfirm('저작을 종료하시겠습니까?', '정보', function(type){
	jConfirm('Do you want to end authoring?', 'Info', function(type){
		if(type) { top.window.opener = top; top.window.open('','_parent',''); top.window.close(); }
	});
}

/* map_start ----------------------------------- 맵 버튼 설정 ------------------------------------- */
function reloadMap(type) {
	var arr = readMapData();
	$('#googlemap').get(0).contentWindow.setCenter(arr[0], arr[1], 2);
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

/* ------------------- 공통 기능 ----------------- */
//컴포넌트 숨기기
function compHide() {
	document.getElementById('caption_dialog').style.display='none';
	document.getElementById('bubble_dialog').style.display='none';
	document.getElementById('icon_dialog').style.display='none';
	document.getElementById('geometry_dialog').style.display='none';
	document.getElementById('data_dialog').style.display='none';
	cancelGeometry();
}
//맵 크기 조절
var resize_map_state = 1;
var resize_scale = 400;
var init_map_left, init_map_top, init_map_width, init_map_height;
function resizeMap() {
	if(resize_map_state==1) {
		init_map_left = 801;
		init_map_top = 580;
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
//객체 테이블
function insertTableObject(data_arr) {
	var html_text = "";
	html_text += "<tr id='obj_tr"+data_arr[0]+"' bgcolor='#e3e3e3' style='font-size:12px; height:18px; color:rgb(21, 74, 119);'>";
	html_text += "<td align='center'><label>"+data_arr[0]+"</label></td>";
	html_text += "<td align='center'><label>"+data_arr[1]+"</label></td>";
	html_text += "<td id='obj_td"+data_arr[0]+"'><label>"+data_arr[2]+"</label></td>";
	html_text += "</tr>";
	
	$('#object_table tr:last').after(html_text);
	$('.ui-widget-content').css('fontSize', 12);
}
function replaceTableObject(data_arr) {
	$('#obj_td'+data_arr[0]).html(data_arr[2]);
}
function removeTableObject(id) {
	$('#obj_tr'+id).remove();
}

/* util_start ----------------------------------- Util ------------------------------------- */
rgb2hex = function(rgb) 
		  {
				rgb = rgb.match(/^rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*(\d+))?\)$/);
    			
				function hex(x) 
    			{
        			return ("0" + parseInt(x).toString(16)).slice(-2);
    			}
    		
			return "#" + hex(rgb[1]) + hex(rgb[2]) + hex(rgb[3]);
		  };
		  
hex_to_decimal = function(hex) 
				{
					return Math.max(0, Math.min(parseInt(hex, 16), 255));
				};
css3color = function(color, opacity) {
	if(color.length==3) { var c1, c2, c3; c1 = color.substring(0, 1); c2 = color.substring(1, 2); c3 = color.substring(2, 3); color = c1 + c1 + c2 + c2 + c3 + c3; }
	return 'rgba('+hex_to_decimal(color.substr(0,2))+','+hex_to_decimal(color.substr(2,2))+','+hex_to_decimal(color.substr(4,2))+','+opacity+')';
};

function sendMail() {
	$('#e_dialog').dialog('open');
}

</script>
</head>
<body onload='imageWriteInit();'>

<!------------------------------------------------------ 화면 영역 ----------------------------------------------------------->
<!-- 저작 버튼 영역 -->
<div class='image_write_function col_gray3' style='position:absolute; left:10px; top:2px; width:1125px; height:65px; display:block;'>	
	<div style="width: 18%; float: left;" class="menuIcon"><img src="<c:url value='/images/geoImg/write/caption_btn.png'/>" onclick='inputCaption(0,"");' style="cursor: pointer; width: 150px; height: 40px; margin-top: 10px; margin-left:3%;"></div>
	<div style="width: 18%; float: left;" class="menuIcon"><img src="<c:url value='/images/geoImg/write/speech_btn.png'/>" onclick='inputBubble(0,"");' style="cursor: pointer; width: 150px; height: 40px; margin-top: 10px; margin-left:3%;"></div>
	<div style="width: 18%; float: left;" class="menuIcon"><img src="<c:url value='/images/geoImg/write/image_btn.png'/>" onclick='inputIcon();' style="cursor: pointer; width: 150px; height: 40px; margin-top: 10px; margin-left:3%;"></div>
	<div style="width: 18%; float: left;" class="menuIcon"><img src="<c:url value='/images/geoImg/write/geo_btn.png'/>" onclick='inputGeometry();' style="cursor: pointer; width: 150px; height: 40px; margin-top: 10px; margin-left:3%;"></div>
	<div style="width: 18%; float: left; display: none;" class="menuIcon menuIconData"><img src="<c:url value='/images/geoImg/write/data_btn.png'/>" onclick='dataChangeClick();' style="cursor: pointer; width: 30px; height: 40px; margin-top: 10px; margin-left:25%;"></div>
	<input type="button" onclick='closeImageWrite();' class='close_btn' value="Close">
	<input type="button" onclick='saveSetting();' class='save_btn' value="Save">
</div>

<!-- 저작 영역 -->
<div id='image_main_area' style='position:absolute; left:10px; top:70px; width:780px; height:580px; display:block; border:1px solid #999999;'>
	<img id='image_write_canvas'></img>
</div>

<!-- 탭 , 공유 우저 영역 -->
<div id="showInfoDiv" style="position:absolute; left:805px; top:13px; color:white; display: none; font-size:13px;">
	<div> TabName : <label id="showKindLabel"></label></div>
	<div style="margin-top: 5px;"> Sharing settings : <label id="shareKindLabel"></label></div>
</div>

<!-- 객체추가리스트 -->
<div id="ioa_title" style='position:absolute; left:800px; top:73px; width:330px; height:245px;'><img src="<c:url value='/images/geoImg/title_02.jpg'/>" alt="Object added list"></div>
<div id='image_object_area' style='position:absolute; left:800px; top:92px; width:330px; height:225px; display:block; border:1px solid #999999; overflow-y:scroll;'>
	<table id='object_table'>
		<tr style='font-size:12px; height:20px;' class='col_black'>
			<td width=50 class='anno_head_tr'>ID</td>
			<td width=80 class='anno_head_tr'>Type</td>
			<td width=180 class='anno_head_tr'>Data</td>
		</tr>
	</table>
</div>

<!-- 저작 설정 영역 -->
<div id='image_sub_area' style='position:absolute; left:10px; top:653px; width:780px; height:195px; display:block; border:1px solid #999999;'>
</div>

<!-- EXIF 영역 -->
<div id="ex_title"><img src="<c:url value='/images/geoImg/title_03.gif'/>" style='position:absolute; left:800px; top:325px;' alt="Image Information"></div>
<div id='image_exif_area' style='position:absolute; left:800px; top:345px; width:330px; height:185px; display:block; /*border:1px solid #999999;*/'>
</div>

<!-- 지도 영역 -->
<div id="ima_title"><img src="<c:url value='/images/geoImg/write/title_04.gif'/>" style='position:absolute; left:802px; top:557px;' alt="Map"></div>
<div id='image_map_area' style='position:absolute; left:800px; top:580px; width:330px; height:270px; display:block;'>
	<iframe id='googlemap' src='<c:url value="/geoPhoto/image_googlemap.do"/>' style='width:100%; height:100%; margin:1px; border:none;'></iframe>
	<div id='resize_map_btn' onclick='resizeMap();' style='position:absolute; left:0px; top:0px; width:30px; height:30px; cursor:pointer; background-image:url(<c:url value="/images/geoImg/icon_map_max.jpg"/>)'>
	</div>
</div>



<!----------------------------------------------------- 서브 영역 ------------------------------------------------------------->

<!-- Caption 삽입 다이얼로그 객체 -->
<div id='caption_dialog' style='position:absolute; left:150px; top:670px; width:500px; height:150px; border:1px solid #999999; display:none;'>
	<div style='display:table; width:100%; height:100%;'>
		<div align="center" style='display:table-cell; vertical-align:middle;'>
			<table border='0'>
				<tr><td width=65><label style="font-size:12px;">Font Size : </label></td>
				<td><select id="caption_font_select" style="font-size:12px;"><option>Normal<option>H3<option>H2<option>H1</select></td>
				<td><label style="font-size:12px;">Font Color : </label></td>
				<td><input id="caption_font_color" type="text" class="iColorPicker" value="#FFFFFF" style="width:50px;"/></td>
				<td><label style="font-size:12px;">BG Color : </label></td>
				<td><input id="caption_bg_color" type="text" class="iColorPicker" value="FFFFFF" style="width:50px;"/></td>
				<td id='caption_checkbox_td'><input type="checkbox" name="caption_bg_checkbok" onclick="checkCaption();"/><label style="font-size:12px;">Transparent</label></td></tr>
				<tr><td colspan='7' id='caption_check'></td></tr>
				<tr class='lineTr'><td colspan='7'><hr/></td></tr>
				<tr><td colspan='5'><input id="caption_text" type="text" style="width:90%; font-size:12px; border:solid 2px #777;"/></td>
				<td colspan='2' align='center' id='caption_button'></td></tr>
			</table>
		</div>
	</div>
</div>

<!-- Bubble 삽입 다이얼로그 객체 -->
<div id='bubble_dialog' style='position:absolute; left:150px; top:660px; width:500px; height:180px; border:1px solid #999999; display:none;'>
	<div style='display:table; width:100%; height:100%;'>
		<div align="center" style='display:table-cell; vertical-align:middle;'>
			<table border='0'>
				<tr><td width=65><label style="font-size:12px;">Font Size : </label></td>
				<td><select id="bubble_font_select" style="font-size:12px;"><option>Normal<option>H3<option>H2<option>H1</select></td>
				<td><label style="font-size:12px;">Font Color : </label></td>
				<td><input id="bubble_font_color" type="text" class="iColorPicker" value="#FFFFFF" style="width:50px;"/></td>
				<td><label style="font-size:12px;">BG Color : </label></td>
				<td><input id="bubble_bg_color" type="text" class="iColorPicker" value="#000000" style="width:50px;"/></td>
				<td id='bubble_checkbox_td'><input type="checkbox" name="bubble_bg_checkbok" onclick="checkBubble();"/><label style=" font-size:12px;">Transparent</label></td></tr>
				<tr><td colspan='7' id='bubble_check'></td></tr>
				<tr class='lineTr'><td colspan='7'><hr/></td></tr>
				<tr><td colspan='5'><textarea id="bubble_text" rows="3" style="width:90%; font-size:12px; border:solid 2px #777;"></textarea></td>
				<td colspan='2' align='center' id='bubble_button'></td></tr>
			</table>
		</div>
	</div>
</div>

<!-- 아미지 삽입 다이얼로그 객체 -->
<div id='icon_dialog' style='position:absolute; left:150px; top:670px; width:500px; height:175px; border:1px solid #999999; display:none;'>
	<div style='position:absolute; left:5px; top:-15px;'>
		<button class="ui-state-default" style="width:80px; height:30px; font-size:12px;" onclick="tabImage(1);">Icon</button>
<!-- 		<button class="ui-state-default" style="width:80px; height:30px; font-size:12px;" onclick="tabImage(2);">Image</button> -->
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

	<div id='icon_div2' style='position:absolute; left:15px; top:20px; width:465px; height:150px; background-color:#999; border:1px solid #999999; overflow-y:scroll; display:none;'>
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
<div id='geometry_dialog' style='position:absolute; left:150px; top:670px; width:500px; height:140px; border:1px solid #999999; display:none;'>
	<div style='display:table; width:100%; height:100%;'>
		<div align="center" style='display:table-cell; vertical-align:middle;'>
			<table id='geometry_table' border="0">
				<tr>
					<td><label style="font-size:12px;">Shape Style : </label>
					<input type='radio' name='geo_shape' value='circle'><label style="font-size:12px;">Circle</label>
					<input type='radio' name='geo_shape' value='rect'><label style="font-size:12px;">Rect</label>
					<input type='radio' name='geo_shape' value='point' checked><label style="font-size:12px;">Point</label></td>
					<td width='20'></td>
					<td rowspan='3'><button class="ui-state-default ui-corner-all" style="width:80px; height:30px; font-size:12px;" onclick="setGeometry();">OK</button></td>
				</tr>
				<tr><td><hr/></td><td width='20'></td></tr>
				<tr>
					<td><label style="font-size:12px;">Line Color : </label>
					<input id="geometry_line_color" type="text" class="iColorPicker" value="#959595" style="width:50px;"/>
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
<div id='exif_dialog' style='position:absolute; left:800px; top:345px; width:330px; height:204px; border:1px solid #999999; display:block; font-size:13px;'>
	<div class='accordionButton col_black'>&nbsp;EXIF</div>
	<div class='accordionContent' style='height:164px; overflow-y:scroll;'>
		<table id='normal_exif_table'>
			<tr><td width='15'><td width='100'><label style='font-size:12px;'>Make</label></td><td width='150'><input id='make_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
			<tr><td width='15'><td><label style='font-size:12px;'>Model</label></td><td><input id='model_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
			<tr><td width='15'><td><label style='font-size:12px;'>Date Time</label></td><td><input id='date_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
			<tr><td width='15'><td><label style='font-size:12px;'>Flash</label></td><td><input id='flash_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
			<tr><td width='15'><td><label style='font-size:12px;'>Shutter Speed</label></td><td><input id='shutter_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
			<tr><td width='15'><td><label style='font-size:12px;'>Aperture</label></td><td><input id='aperture_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
			<tr><td width='15'><td><label style='font-size:12px;'>Max Aperture</label></td><td><input id='m_aperture_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
			<tr><td width='15'><td><label style='font-size:12px;'>Focal Length</label></td><td><input id='focal_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
			<tr><td width='15'><td><label style='font-size:12px;'>Digital Zoom</label></td><td><input id='zoom_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
			<tr><td width='15'><td><label style='font-size:12px;'>White Balance</label></td><td><input id='white_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
			<tr><td width='15'><td><label style='font-size:12px;'>Brightness</label></td><td><input id='bright_text' name='text' type='text' style='font-size:12px;' readonly/></td></tr>
			<tr><td width='15'><td><label style='font-size:12px;'>User Comment</label></td><td><input id='comment_text' name='text' type='text' style='font-size:12px;'/></td></tr>
		</table>
	</div>
	
	<div class='accordionButton col_black'>&nbsp;EXIF-GPS</div>
	<div class='accordionContent' style='height:162px; overflow-y:scroll;'>
		<table id='gps_exif_table' style="margin-top:7px;">
			<tr><td width='15'></td><td width='100'><label style='font-size:12px;'>Speed</label></td><td width='150'><input id='speed_text' name='text' type='text' style='font-size:12px;' disabled /></td></tr>
			<tr><td width='15'></td><td><label style='font-size:12px;'>Altitude</label></td><td><input id='alt_text' name='text' type='text' style='font-size:12px;' disabled /></td></tr>
			<tr><td width='15'></td><td><label style='font-size:12px;'>GPS Direction</label></td><td><input id='gps_direction_text' name='text' type='text' style='font-size:12px;' disabled/></td></tr>
			<tr><td width='15'></td><td><label style='font-size:12px;'>Longitude</label></td><td><input id='lon_text' name='text' type='text' style='font-size:12px;' disabled /></td></tr>
			<tr><td width='15'></td><td><label style='font-size:12px;'>Latitude</label></td><td><input id='lat_text' name='text' type='text' style='font-size:12px;' disabled /></td></tr>
		</table>
	</div>
	
	<!-- <button class="ui-state-default ui-corner-all" style="position:absolute; left:248px; top:205px; width:80px; height:25px; font-size:11px;" onclick="saveExif();">저장</button> -->
</div>

<div id='data_dialog' style='position:absolute; left:150px; top:670px; width:500px; height:165px; border:1px solid #999999; display:none; font-size:13px;'>
	<div style='display:table; width:100%; height:100%;'>
		<div align="center" style='display:table-cell; vertical-align:middle;'>
			<table id="upload_table" border='0'>
				<tr>
					<td colspan="2" width="450">
						<div><input type="radio" value="0" name="shareRadio">Nondisclosure</div>
						<div><input type="radio" value="1" name="shareRadio">Full disclosure</div>
						<div><input type="radio" value="2" name="shareRadio" onclick="imgGetShareUser();">Selective disclosure</div>
<!-- 						<div><input type="radio" value="0" name="shareRadio">비공개</div> -->
<!-- 						<div><input type="radio" value="1" name="shareRadio">전체공개</div> -->
<!-- 						<div><input type="radio" value="2" name="shareRadio" onclick="imgGetShareUser();">특정인 공개</div> -->
						<select id="showKind"></select>
					</td>
				</tr>
				<tr class='tr_line'><td colspan='2'><hr/></td></tr>
				<tr>
					<td width="40">TITLE</td>
					<td>
						<input id="title_area" type="text">
					</td>
				</tr>
				<tr class='tr_line'><td colspan='2'><hr/></td></tr>
				<tr>
					<td>CONTENT</td>
					<td>
						<textarea id="content_area" style="height:60px;"></textarea>
					</td>
				</tr>
			</table>
		</div>
	</div>
</div>

<input type="hidden" id="shareAdd"/>
<input type="hidden" id="shareRemove"/>
<input type="hidden" id="editYes"/>
<input type="hidden" id="editNo"/>
<div id="clonSharUser" style="display:none;"></div>

<!-- 오른클릭 Context Menu -->
<div id="context1" class="contextMenu">
	<ul>
		<!-- <li id="modify"><img src="abcd.png" />Modify</li> -->
		<li id="context_modify">Modify</li>
		<li id="context_delete">Delete</li>
	</ul>
</div>
<div id="context2" class="contextMenu">
	<ul>
		<li id="context_delete">Delete</li>
	</ul>
</div>
<div id="context3" class="contextMenu">
	<ul>
		<li id="context_add">Add Object</li>
		<li id="context_delete">Delete</li>
	</ul>
</div>

<!-- 저장 버튼 다이얼로그 객체 -->
<div id='save_dialog' class='save_dialog' title='SAVE AREA'>
	<button class='ui-state-default ui-corner-all' style='width:300px; height:40px; font-size:11px;' onclick='saveImageWrite(1);'>SAVE TO EXIF</button><br/><br/>
	<button class='ui-state-default ui-corner-all' style='width:300px; height:40px; font-size:11px;' onclick='saveImageWrite(2);'>SAVE TO XML</button><br/><br/>
	<button class='ui-state-default ui-corner-all' style='width:300px; height:40px; font-size:11px;' onclick='saveImageWrite(3);'>VIEW XML</button><br/><br/>
	<button class='ui-state-default ui-corner-all' style='width:300px; height:40px; font-size:11px;' onclick='sendMail()'>SEND EMAIL</button>
</div>

<!-- 이메일공유 다이얼로그 객체 -->
<div id="e_dialog" class='e_dialog' title='EMAIL'>
	<span>E-mail </span><input type='text' id="eml" style="width:200px; height: 20px; margin-left:15px; margin-top:10px;"><br>
	<button class='ui-state-default ui-corner-all' style='width:300px; height:40px; font-size:11px; margin-top:10px;' onclick='saveImageWrite(4);'>SEND EMAIL</button>
</div>

</body>
<style>
.ui-tabs .ui-tabs-nav a
{
   background-color: #4374D9;
}
</style>
</html>
