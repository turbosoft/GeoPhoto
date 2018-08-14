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
String projectUserId = request.getParameter("projectUserId");	//project User id
String linkView = request.getParameter("link");	//project User id
%>

<script type="text/javascript" charset="utf-8">
var loginId = '<%= loginId %>';				// 로그인 아이디
var loginType = '<%= loginType %>';			// 로그인 타입
var loginToken = '<%= loginToken %>';		// 로그인 token
var projectUserId = '<%= projectUserId %>';	//project User id
var linkView = '<%= linkView %>';			//링크로 가기

var idx = '<%= idx %>';
var user_id = '<%= user_id %>';
var request = null;		//request;
var projectBoard = 0;	//GeoCMS 연동여부		0:연동안됨, 1:연동됨

var file_url = '<%= file_url %>';
var base_url = '';
var upload_url = '';
var editUserYN  = 0;						//편집가능여부
var imageSelectMode = 0;
var nowX = 0;
var nowY = 0;
var imgWidth = 0;
var imgHeight = 0;
var imgDroneType = '';
var isPanorama = false;

var projectList = null;
var nowViewList = new Array();				//현재 리스트
var projectIdx = 0;
var nowIndexType = 'GeoPhoto';
var imgEditMode = 0;						//편집모드 : 1, 아니면 0;
var moveWidthNum = 135;						//imageWidth + margin + border
var moveWidthNum2 = 150;						//imageWidth + margin + border
var nowSelectIdx = 0;

var dMarkerLat = 0;		//default marker latitude
var dMarkerLng = 0;		//default marker longitude
var dMapZoom = 10;		//defalut map zoom

var setNewMarkerLat = 0;	//new Marker latitude
var setNewMarkerLng = 0;	//new Marker logitude

$(function() {
	$("#exif_dialog .accordionButton:eq(1)").trigger('click');
	
	if(linkView == 'Y'){
		$('#image_view_group').parent().remove();	
	}
	
	$('html').mousemove(function(e) {
		var container = $('#image_main_area');
		if(container.has(e.target).length == 0){
			imageSelectMode = 0;
		}
	}); 
	
	$('#image_main_area').mousemove(function(event){
		if(imageSelectMode == 1){
			var x = event.pageX;
			var y = event.pageY;
			
			var tmpX = x - nowX;
			var tmpY = y - nowY;
			
			nowX = x;
			nowY = y;
			
			var tmpLeft = $('#image_viewer_canvas_div').css("left").replace('px','');
			var tmptop = $('#image_viewer_canvas_div').css("top").replace('px','');
			
			var tmpML = Number(tmpLeft) + Number(tmpX);
			var tmpMT = Number(tmptop) + Number(tmpY);
			
			if(tmpML > 0){
				tmpML = 0;
				$('.viewerMoreR').css('display','block');
				$('.viewerMoreL').css('display','none');
			}else if(-(imgWidth - $('#image_main_area').width()) > tmpML){
				tmpML = -(imgWidth - $('#image_main_area').width());
				$('.viewerMoreR').css('display','none');
				$('.viewerMoreL').css('display','block');
			}else{
				$('.viewerMoreR').css('display','block');
				$('.viewerMoreL').css('display','block');
			}
			
			if(tmpMT > 0){
				tmpMT = 0;
			}else if(-(imgHeight - $('#image_main_area').height()) > tmpMT){
				tmpMT = -(imgHeight - $('#image_main_area').height());
			}
			
			$('#image_viewer_canvas_div').css("left", tmpML +'px');
			$('#image_viewer_canvas_div').css("top", tmpMT + 'px');
			
		}
		
		event.preventDefault();
	});
	
	$('#image_main_area').mouseup(function(event){
		if(imageSelectMode == 1){
			imageSelectMode = 0;
		}
		event.preventDefault();
	});
	
	$('.image_write_button').button();
	$('.image_write_button').width(80);
	$('.image_write_button').height(25);
	$('.image_write_button').css('fontSize', 12);
	
	$('.image_setting_button').button();
	$('.image_setting_button').width(80);
	$('.image_setting_button').height(25);
	$('.image_setting_button').css('fontSize', 12);

	$('#image_map_area').maxZIndex({inc:1});
	
// 	callRequest();

	if(linkView == 'Y'){
		$('#viewerColstBtn').css('display','none');
	}
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
				upload_url = '/GeoPhoto/';
				
				btnViewCheck();
				getBasePhoto();
				getServer("", "");
				getOneImageData();
			}else{
				base_url = '<c:url value="/"/>';
				upload_url = '/upload/';
				$('body').append('<button style="position:absolute; left:380px; top:780px; width:140px; height:35px; display:block; cursor: pointer;" onclick="imageWrite();" id="makeImageBtn">Write</button>');
				$('#viewerColstBtn').css('display','block');
				loadExif(null);
			}
			//이미지 그리기
			changeImageNomal();
		}
	}
}

function btnViewCheck(){
	$('#makeImageBtn').remove();
	$('#viewerColstBtn').css('display','none');
	
	if(loginId != null && loginId != '' && loginId != 'null' && ((loginId == user_id && loginType != 'WRITE') || loginType == 'ADMIN')){
		$('body').append('<button style="position:absolute; left:380px; top:780px; width:140px; height:35px; display:block; cursor: pointer;" onclick="imageWrite();" id="makeImageBtn">Write</button>');
		$('#viewerColstBtn').css('display','block');
	}else{
		if(editUserCheck() == 1 ||  (loginId != null && loginId != '' && loginId != 'null' && projectUserId == loginId)){
			$('body').append('<button style="position:absolute; left:380px; top:780px; width:140px; height:35px; display:block; cursor: pointer;" onclick="imageWrite();" id="makeImageBtn">Write</button>');
			$('#viewerColstBtn').css('display','block');
		}
	}
}

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
				if(response != null && response != ''){
					response = response[0];
					loadExif(response);
					
					projectIdx = response.projectidx;
					getProjectGroupViewList();
					addImageMoveList();
				}
			}else{
				jAlert(data.Message, 'Info getOneImageData');
			}
		}
	});
}

//초기 설정 데이터 불러오기
function getBasePhoto() {
	var Url			= baseRoot() + "cms/getbase";
	var callBack	= "?callback=?";
	
	$.ajax({
		type	: "get"
		, url	: Url + callBack
		, dataType	: "jsonp"
		, async	: false
		, cache	: false
		, success: function(data) {
			if(data.Code == '100'){
				var result = data.Data;
				if(result != null && result.length > 0){
					dMarkerLat = result[0].latitude;
					dMarkerLng = result[0].longitude;
					dMapZoom = result[0].mapzoom;
					$('#googlemap').get(0).contentWindow.setDefaultData(dMarkerLat, dMarkerLng, dMapZoom);
				}
			}else{
				jAlert(data.Message, 'Info getBasePhoto');
			}
		}
	});
}

//get server
function getServer(rObj, tmpFileType){
	var Url			= baseRoot() + "cms/selectServerList/";
	var param		= loginToken + "/" + loginId +"/" +"Y";
	var callBack	= "?callback=?";
	$.ajax({
		type	: "get"
		, url	: Url + param + callBack
		, dataType	: "jsonp"
		, async	: false
		, cache	: false
		, success: function(data) {
			var response = data.Data;
			var tmpServerId = '';
			var tmpServerPass = '';
			var tmpServerPort = '';
			
			if(data.Code == '100'){
				b_serverUrl = response[0].serverurl;
				b_serverViewPort = response[0].serverviewport;
				b_serverPath = response[0].serverpath;
				if(b_serverUrl != null && b_serverUrl != "" && b_serverUrl != undefined){
					b_serverType = "URL";
				}else{
					b_serverType = "LOCAL";
				}
				tmpServerId = response[0].serverid;
				tmpServerPass = response[0].serverpass;
				tmpServerPort = response[0].serverport;
				
			}else if(data.Code != '200'){
				b_serverPath = "upload";
				jAlert(data.Message, 'Info getServer');
			}else{
				b_serverPath = "upload";
			}
			
			if(tmpFileType != null){
				if(tmpFileType == 'EXIF'){
					getServerExif(rObj, tmpServerId, tmpServerPass, tmpServerPort);
				}else if(tmpFileType == 'XML'){
					loadXML2(tmpServerId, tmpServerPass, tmpServerPort);
				}
			}
		}
	});
}

function getServerExif(rObj, tmpServerId, tmpServerPass, tmpServerPort){
	if(rObj != null && rObj != ''){
		imgDroneType = rObj.dronetype;
		
		var encode_file_name = encodeURIComponent('GeoPhoto/'+ rObj.filename);
		$.ajax({
			type: 'POST',
			url: '<c:url value="/geoExif.do"/>',
			data: 'file_name='+encode_file_name+'&type=load&serverType='+b_serverType+'&serverUrl='+b_serverUrl+
			'&serverPath='+b_serverPath+'&serverPort='+tmpServerPort+'&serverViewPort='+ b_serverViewPort +'&serverId='+tmpServerId+'&serverPass='+tmpServerPass,
			success: function(data) {
				var response = data.trim();
				exifSetting(response, rObj.longitude, rObj.latitude);
			}
		});
	}else{
		var encode_file_name = upload_url + file_url;
		encode_file_name = encode_file_name.substring(1);
		encode_file_name = encodeURIComponent(encode_file_name);
		
		$.ajax({
			type: 'POST',
			url: base_url + '/geoExif.do',
			data: 'file_name='+encode_file_name+'&type=load&serverType='+b_serverType+'&serverUrl='+b_serverUrl+
			'&serverPath='+b_serverPath+'&serverPort='+tmpServerPort+'&serverViewPort='+ b_serverViewPort +'&serverId='+tmpServerId+'&serverPass='+tmpServerPass,
			success: function(data) {
				var response = data.trim();
				exifSetting(response, null, null);
			}
		});
	}
}

//get projectList
function getProjectGroupViewList(){
	var tmpOIdx = '&nbsp';
	var tmpSEdit = '&nbsp';
	
	var Url			= baseRoot() + "cms/getProjectList/";
	var param		= loginToken + "/" + loginId +"/" +tmpOIdx + "/" +tmpSEdit;
	var callBack	= "?callback=?";
	
	$.ajax({
		type	: "get"
		, url	: Url + param + callBack
		, dataType	: "jsonp"
		, async	: false
		, cache	: false
		, success: function(data) {
			var response = data.Data;
			if(data.Code == '100'){
				projectList = response;
			}
// 			else if(data.Code != '203'){
// 				jAlert(data.Message, 'Info getProjectGroupViewList');
// 			}
		}
	});
}

function addImageMoveList(){
	var tmpCnt = 0;
	nowViewList = new Array();
	editContentArr = new Array();
	$('#img_move_list_long').empty();
	$('#moveSelectDiv').empty();
	
	var pageNum = '&nbsp';
	var contentNum = '&nbsp';
	
	var Url			= baseRoot() + "cms/getProjectContent/";
	var param		= loginToken + "/" + loginId + "/list/" + projectIdx + "/" + pageNum + '/' + contentNum;
	var callBack	= "?callback=?";
	
	$.ajax({
		  type	: "get"
		, url	: Url + param + callBack
		, dataType	: "jsonp"
		, async	: false
		, cache	: false
		, success: function(response) {
			if(response.Code == 100){
				var data = response.Data;
				var tmpLeft = 0;

				if(data != null && data.length > 0){
					nowViewList = data;
					var innerHTMLStr = '';
					var beforeGpsChk = false;
					var tmpDataLen = 0;
					
					for(var i=0; i<data.length;i++){
						var localAddress = imageBaseUrl() + "/"+ data[i].datakind +"/";
						if(data[i].filename != undefined){
							var tmpFileN = data[i].filename.substring(0,data[i].filename.lastIndexOf('.'));
							tmpFileN += '_thumbnail.png';
							if(data[i].datakind == "GeoPhoto"){
								localAddress += tmpFileN;
							}else if(data[i].datakind == "GeoVideo"){
								localAddress += data[i].thumbnail;
								if(imgEditMode == 2){
									continue;
								}
							}
						}
						
						innerHTMLStr += "<a class='imageTag' id='Pro_"+ data[i].datakind +"_"+data[i].idx +"' href='javascript:;' onclick="+'"';
						var tempArr = new Array; //mapCenterChange에 넘길 객체 생성
						tempArr.push(data[i].latitude);
						tempArr.push(data[i].longitude);
						tempArr.push(data[i].filename);
						tempArr.push(data[i].idx);
						tempArr.push(data[i].datakind);
						tempArr.push(data[i].originname);
						tempArr.push(data[i].thumbnail);
						tempArr.push(data[i].id);
						tempArr.push(data[i].projectuserid);
						if(data[i].markericon != null){
							data[i].markericon = data[i].markericon.replace('_','&ubsp');
						}
						tempArr.push(data[i].markericon);
						tempArr.push(data[i].u_date);
						tempArr.push(data[i].projectidx);
						tempArr.push(data[i].dronetype);
						if(imgEditMode == 2){
							innerHTMLStr += "imgMapCenterChangeGpsMode('"+ tempArr +"');";
						}else{
							innerHTMLStr += "imgMapCenterChange('"+ tempArr +"');";
						}
						
						innerHTMLStr += '"'+" title='TITLE : "+ data[i].title +"\nCONTENT : "+ data[i].content +"\nWRITER : "+ data[i].id +"\nDATE : "+ data[i].u_date;
						innerHTMLStr += " title=latitude : "+ data[i].latitude +"\nlongitude : "+ data[i].longitude;
						innerHTMLStr += "' border='0'>";

						var tmpMarginTop = '0';
						
						//이미지 자름
						innerHTMLStr += "<div ";
						var tmpViewId = "MOVE_"+ data[i].datakind + "_" + data[i].idx;

						if((idx == data[i].idx && data[i].datakind == 'GeoPhoto') || (nowIndexType == '&empty' && idx == '&empty' && i == 0 )){
							innerHTMLStr += " style='border:2px solid #00b8b0;";
						}else{
							innerHTMLStr += " style='border:2px solid #888888;";
						}

						innerHTMLStr += " background: url(\""+ localAddress +"\") no-repeat center; display: inline-block; width: 110px; height:110px; background-size: 110px 110px; ";
						if(beforeGpsChk){
							innerHTMLStr += " margin:10px 0 10px -21px;'> ";
						}else{
							innerHTMLStr += " margin:10px 0 10px 0;'> ";
						}
						innerHTMLStr += "</div>";
						
						//이미지 및 동영상 아이콘
						if(data[i].datakind == 'GeoPhoto'){
							innerHTMLStr += '<div style="position:relative; width:30px; height:30px; top:-146px;left:-163px; display:inline-block;  background-image:url(../images/geoImg/GeoPhoto_marker.png); zoom:0.7;"></div>';
						}else if(data[i].datakind == 'GeoVideo'){
							innerHTMLStr += '<div style="position:relative; width:30px; height:30px; top:-146px;left:-163px; display:inline-block;  background-image:url(../images/geoImg/GeoVideo_marker.png); zoom:0.7;"></div>';
							
							//동영상은 좌표 설정하지 못하도록
// 							if(imgEditMode == 2){
// 								var tmpLeft = i*moveWidthNum;
// 								var tmpDiv = '<div class="noSelectAreaClass" style="position:absolute; width:112px; height:112px; background-image: url(../images/geoImg/viewer/select_photo_btn_pop.png); background-repeat:no-repeat;cursor:pointer; top:10px; left:'+ tmpLeft +'px;" ></div>';
// 								innerHTMLStr += tmpDiv;
// 							}
						}
						
						beforeGpsChk = false;
						if(imgEditMode == 2 && data[i].datakind == 'GeoPhoto'){
							//좌표 여부
							if(data[i].latitude != null && data[i].latitude != '' && data[i].latitude != undefined && 
									data[i].longitude != null && data[i].longitude != '' && data[i].longitude != undefined){
								beforeGpsChk = true;
								innerHTMLStr += '<div style="position:relative; width:36px; height:36px; top:-16px;left:-67px; display:inline-block;  background-image:url(../images/geoImg/sample_marker.png); zoom:0.7;" class="sampleMarkerClass"></div>';
							}
						}
						
						innerHTMLStr += "</a>";

						if((idx == data[i].idx && data[i].datakind == 'GeoPhoto') || (nowIndexType == '&empty' && idx == '&empty' && i == 0 )){
							if(nowIndexType == '&empty' && idx == '&empty' && i == 0 ){
								imgMapCenterChange("'"+ tempArr + "'");
							}
							tmpLeft  = totalMoveWidth;
							tmpCnt = i;
							idx = data[i].idx;
							
							imgDataSetting(data[i]);
						}

						totalMoveWidth += moveWidthNum;
						tmpDataLen++;
					}//end for
					
					$('#img_move_list_long').css('width', moveWidthNum2*tmpDataLen +"px");
					$('#img_move_list_long').append(innerHTMLStr);
					

					//9개 이상일 경우 move btn 
					if(tmpDataLen > 8){
						$('#img_move_list').css('width','1035px');
						$('#img_move_list').css('left','40px');
						$('#img_move_list').css('top','0');
						$('.imgMoveBtn').css('display','block');
						
						if(tmpCnt > 4){
							var tmpNowIdx1 = -1;
							$.each(nowViewList, function(idxv, valv){
								if(valv.idx == idx){
									tmpNowIdx1 = idxv;
								}
							});
							if(tmpNowIdx1 > 4){
								var offset = 0;
								offset = $("#Pro_" + nowViewList[tmpNowIdx1].datakind +"_"+ nowViewList[tmpNowIdx1].idx).offset();
								var tmpMoveLeft1 = offset.left - (moveWidthNum*4);
								$('#img_move_list').animate({scrollLeft : tmpMoveLeft1});
							}
						}
					}

					//좌우 move btn
					if(tmpCnt > 0){
						$('#bigImgMoveL').css('display','block');
					}

					if(tmpCnt < data.length-1){
						$('#bigImgMoveR').css('display','block');
					}
					
				}else{
					$('.edit_btn_bottom').css('display','none');
				}
			}
		}
	});
	
	return editUserYN;
}

//data setting
function imgDataSetting(obj){
	projectIdx = obj.projectidx;
	user_id = obj.id;
	projectUserId = obj.projectuserid;
	nowIndexType = obj.datakind;

	$('#image_view_group').empty();
	var tmpGroup = '';
	var tmpGroupHTML = '';
	var projectNameTxt = '';
	var proShare = '';
	if(obj.sharetype == '1'){
// 		proShare = '공개';
		proShare = 'FULL';
	}else if(obj.sharetype == '0'){
// 		proShare = '비공개';
		proShare = 'NON';
	}else{
// 		proShare = '선택공개';
		proShare = 'SELECTIVE';
	}

	tmpGroup = obj.projectname;
	projectNameTxt = tmpGroup.length>18? tmpGroup.substring(0,18)+'...' : tmpGroup;
	var tmpLeft1 = '50px';
	
	tmpGroupHTML += '<div class="view_folderClass" style="margin:4px 5px;"></div>';
	tmpGroupHTML += '<div class="m_l_15" style="float:left; margin: 12px 0 0 10px; font-size:10px; color:#00b8b0;">'+ proShare +'</div>';
	tmpLeft1 = '10px';
	tmpGroupHTML += "<div class='titleLabel' style='float:left; margin: 8px 0 0 "+ tmpLeft1 +";' title='"+ tmpGroup +"'>"+ projectNameTxt +"</div>";
	
	tmpGroupHTML += "<img src='<c:url value='/images/geoImg/viewer/setting_btn_pop.png'/>' style='float:right; margin:8px 0 0 20px; width:30px; height:26px; display: none; cursor:pointer;' id='mv_setting' onclick='imageControllView(\"Y\")'>";
	
	//좌표 설정 버튼
	tmpGroupHTML += "<div style='float: right;margin: 8px 0px 0px 20px;width: 120px;height: 26px;display: none;cursor: pointer;color: #0c9b95;font-size: 12px;background-color: #4f3639;border-radius: 3px;font-weight: bold;text-align: center;line-height: 26px;' id='gps_setting' onclick='imageControllView(\"G\")'>Coordinate setting</div>";
	
	tmpGroupHTML += "<img src='<c:url value='/images/geoImg/viewer/close_btn_pop.png'/>' style='float:right; margin:8px 0 0 20px; width:30px; height:26px; display: none; cursor:pointer;' class='mv_setting_on' onclick='imageControllView(\"N\")'>";
	tmpGroupHTML += "<img src='<c:url value='/images/geoImg/viewer/picdel_btn_viewer.png'/>' style='float:right; margin:8px 0 0 20px; width:47px; height:27px; display: none; cursor:pointer;' class='mv_setting_on' onclick='removeMoveList()'>";
	tmpGroupHTML += "<img src='<c:url value='/images/geoImg/viewer/picmove_btn_viewer.png'/>' style='float:right; margin:8px 0 0 20px; width:47px; height:27px; display: none; cursor:pointer;' id='view_category' class='mv_setting_on' onclick='getMoveList()'>";
	
	//좌표 저장 및 닫기
	tmpGroupHTML += "<img src='<c:url value='/images/geoImg/viewer/close_btn_pop.png'/>' style='float:right; margin:8px 0 0 20px; width:30px; height:26px; display: none; cursor:pointer;' class='gps_setting_on' onclick='imageControllView(\"N\")'>";
	tmpGroupHTML += "<div style='float: right;margin: 8px 0px 0px 20px;width: 120px;height: 26px;display: none;cursor: pointer;color: #0c9b95;font-size: 12px;background-color: #4f3639;border-radius: 3px;font-weight: bold;text-align: center;line-height: 26px;' class='gps_setting_on' onclick='newMarkerSave()'>Save coordinates</div>";
	
	$('#image_view_group').append(tmpGroupHTML);

	if(imgEditMode == 1){
		$('.mv_setting_on').css('display','block');
		$('#moveSelectDiv').empty();
	}else if(imgEditMode == 2){
		$('.gps_setting_on').css('display','block');
		$('#moveSelectDiv').empty();
	}
	
	if(loginId != null && loginId != '' && ((loginId == user_id && loginType != 'WRITE') || loginType == 'ADMIN' || (user_id == null || user_id == '' || user_id == 'null'))){
		$('.edit_btn_bottom').css('display', 'block');
		if(imgEditMode != 1 && imgEditMode != 2){
			$('#mv_setting').css('display', 'block');
			$('#gps_setting').css('display', 'block');
		}
	}else if(editUserCheck() == 1 ||  projectUserId == loginId){
		$('.edit_btn_bottom').css('display', 'block');
		if(imgEditMode != 1 && imgEditMode != 2 && projectUserId == loginId){
			$('#mv_setting').css('display', 'block');
			$('#gps_setting').css('display', 'block');
		}
	}else{
		$('.edit_btn_bottom').css('display', 'none');
		$('#mv_setting').css('display', 'none');
		$('#gps_setting').css('display', 'none');
	}
}

//img modify mode
function imageControllView(type){
	$('.checkAreaClass').remove();
	setNewMarkerLat = 0;
	setNewMarkerLng = 0;
	
	if(type == 'Y'){
		imgEditMode = 1;
		addImageMoveList();
		
		$('#mv_setting').css('display','none');
		$('#gps_setting').css('display','none');
		$('.mv_setting_on').css('display','block');

		var tmpDiv = '<div id="grayDivArea" style="position:absolute; width:1135px; height:569px; background:gray; opacity:0.5; left:0; top:0;z-index:1;" ></div>';
		$('body').append(tmpDiv);
		
		$('#image_view_group').maxZIndex({inc:1});
		$('#img_move_area').maxZIndex({inc:1});
		$('#moveSelectDiv').maxZIndex({inc:1});
		
	}else if(type == 'N'){
		if(imgEditMode == 2){
			$('#googlemap_gray').get(0).contentWindow.grayMarkerSet('cancel');
			$('#image_map_area_gray').css('display','none');
		}else{
			$('#image_map_area_gray').css('display','none');
			$('#grayDivArea').remove();
		}
		
		imgEditMode = 0;
		addImageMoveList();
		$('.mv_setting_on').css('display','none');
		$('#moveSelectDiv').empty();
		$('#moveSelectDiv').css('display','none');
		$('.gps_setting_on').css('display','none');
	}else if(type == 'G'){
		imgEditMode = 2;
		addImageMoveList();
		
		$('#mv_setting').css('display','none');
		$('#gps_setting').css('display','none');
		$('.mv_setting_on').css('display','none');
		$('.gps_setting_on').css('display','block');
		
		$('#image_map_area_gray').css('display','block');

// 		var tmpDiv = "<div id='grayMapDivArea' style='position:absolute; left:0; top:0; z-index:1; width:1135px; height:569px; display:block; background-color:#999;'>";
// 		tmpDiv += "<iframe id='grayGooglemap' src='<c:url value='/geoPhoto/image_googlemap.do'/>' style='width:100%; height:100%; margin:1px; border:none;'></iframe>";
// 		tmpDiv += "</div>";
// 		$('body').append(tmpDiv);
		
		$('#googlemap_gray').get(0).contentWindow.graySetCenter();
		var dMarkerLat = 0;		//default marker latitude
		var dMarkerLng = 0;		//default marker longitude
		var dMapZoom = 10;		//defalut map zoom

		$('#image_map_area_gray').maxZIndex({inc:1});
		$('#image_view_group').maxZIndex({inc:1});
		$('#img_move_area').maxZIndex({inc:1});
		$('#moveSelectDiv').maxZIndex({inc:1});
	}
	
}

//new marker setting
function newMarkerSave(){
	$('#googlemap_gray').get(0).contentWindow.grayMarkerSet('ok');
	
	if(setNewMarkerLat == 0 || setNewMarkerLng == 0){
// 		jAlert('이동할 컨텐츠를 선택해 주세요', '정보');
		jAlert('Please select gps.', 'Info');
		$('#popup_container').maxZIndex({inc:1});
		return;
	}
	
	if(editContentArr == null || editContentArr.length <= 0){
// 		jAlert('이동할 컨텐츠를 선택해 주세요', '정보');
		jAlert('Please select content.', 'Info');
		$('#popup_container').maxZIndex({inc:1});
		return;
	}
	
	var gpsSaveUrl = 'cms/updateGpsData/'+ loginToken +'/'+ loginId +'/'+ setNewMarkerLat + "/"+  setNewMarkerLng + "/" + editContentArr;
	
	var Url			= baseRoot() + gpsSaveUrl;
	var callBack	= "?callback=?";
	
	$.ajax({
		  type	: "POST"
		, url	: Url + callBack
		, dataType	: "jsonp"
		, async	: false
		, cache	: false
		, success: function(response) {
			if(response.Code == 100){
				addImageMoveList();
			}
		}
	});
}


var editContentArr = new Array();	//이동할 컨텐츠
//img center Change
function imgMapCenterChange(tmpArr){
	var tpAr = tmpArr.split(",");
	nowSelectIdx = tpAr[3];
	var tmpKind = tpAr[4];
	var tmpId = tpAr[7];
	var tmpProjectId = tpAr[8];
	var tmpMoveIdx = 0;
	
	$.each(nowViewList, function(idx1, val1){
		if(val1.idx == nowSelectIdx && val1.datakind == tmpKind){
			tmpMoveIdx = idx1;
		}
	});
	
	if(imgEditMode == 1){
		if(!(loginId != null && loginId != '' && (((loginId == tmpId && loginType != 'WRITE') || loginType == 'ADMIN' || (tmpId == null || tmpId == '' || tmpId == 'null')) || (editUserCheck() == 1 ||  tmpProjectId == loginId)))){
			return;
		}
		
		var tmp1 = $.inArray(tmpKind+"_"+nowSelectIdx, editContentArr);
		if(tmp1 > -1 ){
			editContentArr.splice(tmp1,1);
			$('#checkArea_'+tmpKind+"_"+nowSelectIdx).remove();
		}else{
			var tmpLeft = tmpMoveIdx*moveWidthNum;
			editContentArr.push(tmpKind+"_"+nowSelectIdx);
			var tmpDiv = '<div id="checkArea_'+ tmpKind+"_"+nowSelectIdx +'" class="checkAreaClass" style="position:absolute; width:112px; height:112px; background-image: url(../images/geoImg/viewer/select_photo_btn_pop.png); background-repeat:no-repeat;cursor:pointer; top:10px; left:'+ tmpLeft +'px;" ></div>';
			$('#Pro_'+ tmpKind +'_'+nowSelectIdx).append(tmpDiv);
		}
		return;
	}
	
	if(tmpKind != null && tmpKind == 'GeoVideo'){
		imageViewClose();
		window.parent.videoViewer(tpAr[2], tpAr[5], tmpId, nowSelectIdx, tmpProjectId);
		return;
	}
	
	if(tmpMoveIdx == 0){
		$('#bigImgMoveL').css('display','none');
	}else{
		$('#bigImgMoveL').css('display','block');
	}
	
	if(tmpMoveIdx == nowViewList.length-1){
		$('#bigImgMoveR').css('display','none');
	}else{
		$('#bigImgMoveR').css('display','block');
	}

	if(nowViewList.length > 8){
		var tmpMoveLeft1 = 0;
		if(tmpMoveIdx > 4){
			tmpMoveLeft1 = (moveWidthNum * (tmpMoveIdx-3));
		}
		$('#img_move_list').animate({scrollLeft : tmpMoveLeft1});
	}

	imgDataSetting(nowViewList[tmpMoveIdx]);
	file_url = nowViewList[tmpMoveIdx].filename;

	changeImageNomal();
	var moveObj = new Object();
	if(tpAr[0] != null && tpAr[0] != undefined){
		tpAr[0] = tpAr[0].replace("'","");
	}
	moveObj.latitude = tpAr[0];
	moveObj.longitude = tpAr[1];
	moveObj.filename = tpAr[2];
	moveObj.dronetype = tpAr[12];
	loadExif(moveObj);
	$('#Pro_'+ tmpKind +'_'+ idx + " DIV:first").css('border', '2px solid #888888');
	idx = nowViewList[tmpMoveIdx].idx;
	$('#Pro_'+ tmpKind +'_'+ idx + " DIV:first").css('border', '2px solid #00b8b0');
	
	idx = nowSelectIdx;
	btnViewCheck();
}

//check image
function imgMapCenterChangeGpsMode(tmpArr){
	var tpAr = tmpArr.split(",");
	nowSelectIdx = tpAr[3];
	var tmpKind = tpAr[4];
	var tmpId = tpAr[7];
	var tmpProjectId = tpAr[8];
	var tmpMoveIdx = 0;
	var tempVideoCnt = 0;
	var tmpSampleMarkerCnt = 0;
	
	$.each(nowViewList, function(idx1, val1){
		if(val1.datakind == "GeoVideo"){
			tempVideoCnt ++;
		}
		
		if(val1.idx == nowSelectIdx && val1.datakind == tmpKind){
			tmpMoveIdx = idx1;
			return false;
		}
		
		if(val1.datakind == "GeoPhoto" &&
				val1.latitude != null && val1.latitude != '' && val1.latitude != undefined && 
				val1.longitude != null && val1.longitude != '' && val1.longitude != undefined){
			tmpSampleMarkerCnt += 5;
		}
	});
	tmpMoveIdx = tmpMoveIdx-tempVideoCnt;
	
	if(imgEditMode == 2){
		if(!(loginId != null && loginId != '' && (((loginId == tmpId && loginType != 'WRITE') || loginType == 'ADMIN' || (tmpId == null || tmpId == '' || tmpId == 'null')) || (editUserCheck() == 1 ||  tmpProjectId == loginId)))){
			return;
		}
		
		if(imgEditMode == 2 && tmpKind == 'GeoVideo'){
			return;
		}

		var tmp1 = $.inArray(tmpKind+"_"+nowSelectIdx, editContentArr);
		if(tmp1 > -1 ){
			editContentArr.splice(tmp1,1);
			$('#checkArea_'+tmpKind+"_"+nowSelectIdx).remove();
		}else{
			var tmpLeft = tmpMoveIdx*moveWidthNum;
			editContentArr.push(tmpKind+"_"+nowSelectIdx);
			if(tmpMoveIdx > 0 ){
				tmpLeft += tmpSampleMarkerCnt;
			}
			
			var tmpDiv = '<div id="checkArea_'+ tmpKind+"_"+nowSelectIdx +'" class="checkAreaClass" style="position:absolute; width:112px; height:112px; background-image: url(../images/geoImg/viewer/select_photo_btn_pop.png); background-repeat:no-repeat;cursor:pointer; top:10px; left:'+ tmpLeft +'px;" ></div>';
			$('#Pro_'+ tmpKind +'_'+nowSelectIdx).append(tmpDiv);
		}
		return;
	}
}

function getMoveList(){
	var moveUrl = '';
	moveUrl = 'cms/getProjectList/'+ loginToken +'/'+ loginId +'/&nbsp/Y';
	
	if($('#moveSelectDiv').css('display') == 'none'){
		var Url			= baseRoot() + moveUrl;
		var callBack	= "?callback=?";
		
		$.ajax({
			  type	: "get"
			, url	: Url + callBack
			, dataType	: "jsonp"
			, async	: false
			, cache	: false
			, success: function(response) {
				if(response.Code == 100){
					var result = response.Data; 
					if(result != null && result.length>1){
						var tmpHtml = '';
						
						for(var i=0; i<result.length; i++){
							var tmpTabName = result[i].projectname;
							var proShare = '';
							if(result[i].sharetype == '1'){
// 								proShare = '공개';
								proShare = 'FULL';
							}else if(result[i].sharetype == '0'){
// 								proShare = '비공개';
								proShare = 'NON';
							}else{
// 								proShare = '선택공개';
								proShare = 'SELECTIVE';
							}
							
							if(result[i].idx != projectIdx){
								var tmpTabNameShot = tmpTabName.length>10? tmpTabName.substring(0,10)+'...' : tmpTabName;
								
								tmpHtml += '<div style="height:26px; background:#4f3639; cursor:pointer;" onclick="modifyCategory('+ result[i].idx +');" class="proNameMouseDiv">';
								tmpHtml += "<div class='m_l_15' style='float:left; margin: 6px 0 0 10px; font-size:10px; color:#00b8b0;'>"+ proShare +"</div>";
								tmpHtml += "<div style='padding: 5px 0 0 60px; font-size:12px;' title='"+ tmpTabName +"'>"+ tmpTabNameShot +"</div></div>";
							}
						}
						$('#moveSelectDiv').append(tmpHtml);
						$('.proNameMouseDiv').hover(
							function() {
								$(this).css('background','#25323c');
							}, function() {
								$(this).css('background','#4f3639');
							}
						);
						
						var  tmpLeft2 = $('#view_category').offset().left -33;
						$('#moveSelectDiv').css('display','block');
						$('#moveSelectDiv').css('left',tmpLeft2);
						var tmpToh2 = $('#view_category').offset().top - $('#moveSelectDiv').height() -16 ;
						$('#moveSelectDiv').css('top',tmpToh2);
					}else{
// 						jAlert('이동할 프로젝트 정보가 없습니다', '정보');
						jAlert('No project information to move.', 'Info');
					}
				}else if(response.Code == 200){
// 					jAlert('이동할 프로젝트 정보가 없습니다', '정보');
					jAlert('No project information to move.', 'Info');
				}
			}
		});
	}else{
		$('#moveSelectDiv').empty();
		$('#moveSelectDiv').css('display','none');
	}
}

//move Content
function modifyCategory(tmpProIdx){
	if(editContentArr == null || editContentArr.length <= 0){
// 		jAlert('이동할 컨텐츠를 선택해 주세요', '정보');
		jAlert('Please select content to move.', 'Info');
		$('#popup_container').maxZIndex({inc:1});
		return;
	}
	
	$('#moveSelectDiv').css('display','none');
	var moveUrl = moveUrl = 'cms/moveProject/'+ loginToken +'/'+ loginId +'/'+ tmpProIdx + "/" + editContentArr;
	
	var Url			= baseRoot() + moveUrl;
	var callBack	= "?callback=?";
	
	$.ajax({
		  type	: "POST"
		, url	: Url + callBack
		, dataType	: "jsonp"
		, async	: false
		, cache	: false
		, success: function(response) {
			if(response.Code == 100){
				makeViewOrd();
			}
		}
	});
}

function removeMoveList(){
	if(editContentArr == null || editContentArr.length <= 0){
// 		jAlert('삭제할 사진을 선택해 주세요', '정보');
		jAlert('Please select a photo to delete.', 'Info');
		$('#popup_container').maxZIndex({inc:1});
		return;
	}
	
// 	jConfirm('정말 삭제하시겠습니까?', '정보', function(type){
	jConfirm('Are you sure you want to delete?', 'Info', function(type){
		if(type){
			var rmPhotoList = new Array();
			var rmVideoList = new Array();
			$.each(editContentArr, function(eIdx, eVal){
				if(eVal != null && eVal != '' && eVal != undefined){
					var tmpEval = eVal.split('_');
					if(tmpEval[0] == 'GeoPhoto'){
						rmPhotoList.push(tmpEval[1]);
					}else if(tmpEval[0] == 'GeoVideo'){
						rmVideoList.push(tmpEval[1]);
					}
				}
			});
			
			if(rmPhotoList != null && rmPhotoList.length > 0){
				var moveUrl = 'cms/deleteContent/'+ loginToken +'/'+ loginId +'/GeoPhoto/' + rmPhotoList;
				var Url			= baseRoot() + moveUrl;
				var callBack	= "?callback=?";
				
				$.ajax({
					  type	: "POST"
					, url	: Url + callBack
					, dataType	: "jsonp"
					, async	: false
					, cache	: false
					, success: function(response) {
						if(response.Code == 100){
							if(rmVideoList != null && rmVideoList.length > 0){
								var moveUrl = 'cms/deleteContent/'+ loginToken +'/'+ loginId +'/GeoVideo/' + rmVideoList;
								var Url			= baseRoot() + moveUrl;
								var callBack	= "?callback=?";
								
								$.ajax({
									  type	: "POST"
									, url	: Url + callBack
									, dataType	: "jsonp"
									, async	: false
									, cache	: false
									, success: function(response) {
										if(response.Code == 100){
											makeViewOrd();
										}
									}
								});
							}else{
								makeViewOrd();
							}
						}
					}
				});
			}else if(rmVideoList != null && rmVideoList.length > 0){
				var moveUrl = 'cms/deleteContent/'+ loginToken +'/'+ loginId +'/GeoVideo/' + rmVideoList;
				var Url			= baseRoot() + moveUrl;
				var callBack	= "?callback=?";
				
				$.ajax({
					  type	: "POST"
					, url	: Url + callBack
					, dataType	: "jsonp"
					, async	: false
					, cache	: false
					, success: function(response) {
						if(response.Code == 100){
							makeViewOrd();
						}
					}
				});
				
			}
		}
	});
}

function makeViewOrd(){
	var chkData = true;
	if(nowViewList.length != editContentArr.length){
		for(var i=0;i<nowViewList.length;i++){
			if(nowViewList[i] != null){
				chkData = true;
				for(var j=0;j<editContentArr.length;j++){
					if(nowViewList[i].datakind+"_"+nowViewList[i].idx == editContentArr[j]){
						chkData = false;
					}
				}
				if(chkData){
					nowIndexType = nowViewList[i].datakind;
					idx = nowViewList[i].idx;
					break;
				}
			}
		}
	}

	if(nowViewList.length == editContentArr.length){
		window.parent.viewMyProjects(null);
		
// 		jAlert('불러올 컨텐츠가 없습니다.', '정보', function(res){
		jAlert('There is no content to import.', 'Info', function(res){
			imageViewClose();
		});
	}
	
	addImageMoveList();
	
	imgEditMode = 0;
	$('.checkAreaClass').remove();
	$('#grayDivArea').remove();
	
	$.each(nowViewList, function(idx1, val1){
		if(val1.idx == idx && val1.datakind == nowIndexType){
			var tempArr = new Array; //mapCenterChange에 넘길 객체 생성
			tempArr.push(val1.latitude);
			tempArr.push(val1.longitude);
			tempArr.push(val1.filename);
			tempArr.push(val1.idx);
			tempArr.push(val1.datakind);
			tempArr.push(val1.originname);
			tempArr.push(val1.thumbnail);
			tempArr.push(val1.id);
			tempArr.push(val1.projectuserid);
			if(val1.projectmarkericon != null){
				val1.projectmarkericon = val1.projectmarkericon.replace('_','&ubsp');
			}
			tempArr.push(val1.projectmarkericon);
//				tempArr.push(val1.TITLE);
//				tempArr.push(val1.CONTENT);
			tempArr.push(val1.u_date);
			tempArr.push(val1.projectidx);
			tempArr.push(val1.dronetype);
			imgMapCenterChange("'"+ tempArr +"'");
		}
	});
	
	imageControllView('Y');
	
	window.parent.viewMyProjects(null);
}

var moveNum = 0;
var maxMoveNum = 0;
var totalMoveWidth = 0;
//하단 이미지 리스트 이동
function moveImgList(text){
	if(nowViewList.length <= 8){
		return;
	}
	
	var tmpLeft1 = 0;
	if(text == 'l'){
		tmpLeft1 = $('#img_move_list').scrollLeft() - (moveWidthNum);
	}else{
		tmpLeft1 += $('#img_move_list').scrollLeft() + (moveWidthNum);
	}
	if(tmpLeft1 < 0){
		tmpLeft1 = 0;
	}
	$('#img_move_list').animate({scrollLeft : tmpLeft1});
	
}

//큰 이미지 좌우 이동
function changeImg(text){
	var tmpMoveIdx = 0;
	var nextIdx = 0;
	var tmpKind = 'GeoPhto';
	$.each(nowViewList, function(idx1, val1){
		if(val1.idx == idx){
			tmpMoveIdx = idx1;
			tmpKind = val1.datakind;
		}
	});
	
	if(text == "l"){
		if(tmpMoveIdx == 1){
			$('#bigImgMoveL').css('display','none');
		}
		if(tmpMoveIdx == nowViewList.length-1){
			$('#bigImgMoveR').css('display','block');
		}
		nextIdx = tmpMoveIdx - 1;
	}else if(text == "r"){
		if(tmpMoveIdx == nowViewList.length-2){
			$('#bigImgMoveR').css('display','none');
		}
		if(tmpMoveIdx == 0){
			$('#bigImgMoveL').css('display','block');
		}
		nextIdx = tmpMoveIdx + 1;
	}
	
	if(nowViewList.length > 8){
		var tmpMoveLeft1 = 0;
		if(nextIdx > 4){
			tmpMoveLeft1 = (moveWidthNum * (nextIdx-3));
		}
		$('#img_move_list').animate({scrollLeft : tmpMoveLeft1});
	}

	imgDataSetting(nowViewList[nextIdx]);
	file_url = nowViewList[nextIdx].filename;
	changeImageNomal();
	
	$('#Pro_'+ tmpKind +'_'+ idx + " DIV").css('border', '2px solid #888888');
	idx = nowViewList[nextIdx].idx;
	$('#Pro_'+ tmpKind +'_'+ idx + " DIV").css('border', '2px solid #00b8b0');
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
			if(response.Code == 100 && response.Data[0].shareedit == 'Y'){
				editUserYN = 1;
			}
		}
	});
	
	return editUserYN;
}

//on load function
function imageViewerInit() {
	callRequest();
	//이미지 그리기
// 	changeImageNomal();
}

function changeImageNomal() {
	$.each($('#image_viewer_canvas_div').children(), function(idx, val){
		if(val.id != 'image_viewer_canvas'){
			val.remove();
		}
	});
	$.each($('#object_table tr'), function(idx, val){
		if(idx > 0){
			val.remove();
		}
	});
	
	var img = new Image();
	img.src = imageBaseUrl() + upload_url + file_url;

	img.onload = function() {
		//이미지 Resize
		var result_arr = null;
		var margin = 10;
		var width = $('#image_main_area').width();
		var height = $('#image_main_area').height();
		img_origin_width = img.width; img_origin_height = img.height;
		
		isPanorama = img.width/img.height > 2.5? true:false;
		$('.viewerMoreR').css('display','none');
		$('.viewerMoreL').css('display','none');

		if(isPanorama){
			result_arr = resizeImage(width, height, img.width, img.height, margin);
			
			var tmpLeft = -result_arr[0];
			var tmpTop = -result_arr[1];
			imgWidth = result_arr[2];
			imgHeight = result_arr[3];
			
			var img_element = $('#image_viewer_canvas');
			img_element.attr('style', 'background-image:url("'+ imageBaseUrl() + upload_url + file_url +'");width:'+ imgWidth +'px;height:'+ imgHeight +'px;background-repeat:no-repeat;left: 0px; top: 0px;background-size:'+ imgWidth +'px '+ imgHeight + 'px;position:absolute;');
			img_element.appendTo('#image_viewer_canvas_div');
			
			var img_element2 = $('#image_viewer_canvas_div');
			img_element2.attr('onmousedown', 'selectImageNow();');
			
			$('.viewerMoreR').css('display','block');
			
			//XML 로드
			loadXML();
			
		}else{
			result_arr = resizeImageNomal(width, height, img.width, img.height, margin);
			//canvas 의 width height 비율과 다른 이미지의 경우 축소하여도 y 축이 음수가 나오는 경우를 처리하기 위함
			while(result_arr[1] < 3) {
				margin += 10;
				result_arr = resizeImageNomal(width, height, img.width, img.height, margin);
			}

			var img_element = $('#image_viewer_canvas');
			img_element.attr('style', 'background-image:url("'+ imageBaseUrl() + upload_url + file_url +'");width:'+ result_arr[2] +'px;height:'+ result_arr[3] +'px;background-repeat:no-repeat;left: '+ result_arr[0] +'px; top: '+ result_arr[1] +'px;background-size:'+ result_arr[2] +'px '+ result_arr[3] + 'px;position:absolute;');
			img_element.appendTo('#image_viewer_canvas_div');
			
			var img_element2 = $('#image_viewer_canvas_div');
			img_element2.attr('onmousedown', null);
			
			//XML 로드
			loadXML();
		}
	};
}

function selectImageNow(){
	imageSelectMode = 1;
	nowX = event.pageX;
	nowY = event.pageY;
}

function resizeImage(canvas_width, canvas_height, img_width, img_height, margin) {
	var min; var max; var ratio;
	if(img_width > img_height) { min = img_height; max = img_width; ratio = min / canvas_height; }
	else { min = img_width; max = img_height; ratio = min / canvas_width; }
	var resize_width = Math.round(img_width / ratio); var resize_height = Math.round(img_height / ratio);
	var x = resize_width / 2; var y = resize_height / 2;
	
	var result_arr = new Array();
	result_arr.push(x); result_arr.push(y); result_arr.push(resize_width); result_arr.push(resize_height);
	return result_arr;
}

function resizeImageNomal(canvas_width, canvas_height, img_width, img_height, margin) {
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
	
	var font_size = $('#caption_font_select').val(); var font_color = $('#caption_font_color').val(); var bg_color = $('#caption_bg_color').val(); var bg_check = $('input[name=caption_bg_checkbok]').attr('checked'); var bold_check = $('#caption_bold').prop('checked'); var italic_check = $('#caption_italic').prop('checked'); var underline_check = $('#caption_underline').prop('checked'); var link_check = $('#caption_link').prop('checked'); var text = $('#caption_text').val();
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
	div_element.attr('id', auto_caption_str); div_element.attr('style', 'position:absolute; left:10px; top:10px; display:block;'); div_element.html(html_text); 
// 	div_element.appendTo('#image_main_area');
	div_element.appendTo('#image_viewer_canvas_div');
	
	auto_caption_num++;
	
	var data_arr = new Array();
	data_arr.push(auto_caption_str); data_arr.push("Caption"); data_arr.push(text);
	insertTableObject(data_arr);
}

var auto_bubble_str;
var auto_bubble_num = 0;
function createBubble() {
	auto_bubble_str = "b" + auto_bubble_num;
	var font_size = $('#bubble_font_select').val(); var font_color = $('#bubble_font_color').val(); var bg_color = $('#bubble_bg_color').val(); var bg_check = $('input[name=bubble_bg_checkbok]').attr('checked'); var bold_check = $('#bubble_bold').prop('checked'); var italic_check = $('#bubble_italic').prop('checked'); var underline_check = $('#bubble_underline').prop('checked'); var link_check = $('#bubble_link').prop('checked'); var text = $('#bubble_text').val();
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
	
	var div_element = $(document.createElement('div')); div_element.attr('id', auto_bubble_str); div_element.attr('style', 'position:absolute; left:10px; top:10px; display:block;'); div_element.html(html_text); 
	div_element.appendTo('#image_viewer_canvas_div');

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
	img_element.appendTo('#image_viewer_canvas_div');
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
// 	var left_str = $('#image_viewer_canvas').css('left'); var top_str = $('#image_viewer_canvas').css('top');
	var left_str = $('#image_viewer_canvas_div').css('left'); var top_str = $('#image_viewer_canvas_div').css('top');
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
	canvas_element.appendTo('#image_viewer_canvas_div');

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
	getServer("", 'XML');
}

function loadXML2(tmpServerId, tmpServerPass, tmpServerPort) {
	var file_arr = file_url.split(".");   		// ["/upload/20141201_140526", "jpg"]
	var xml_file_name = file_arr[0] + '.xml';  		// "/upload/20141201_140526.xml"
	xml_file_name = upload_url + xml_file_name;
	xml_file_name = xml_file_name.substring(1);
	
	$.ajax({
		type: "POST",
		url: base_url + '/geoXml.do',
		data: 'file_name='+xml_file_name+'&type=load&serverType='+b_serverType+'&serverUrl='+b_serverUrl+
		'&serverPath='+b_serverPath+'&serverPort='+tmpServerPort+'&serverViewPort='+ b_serverViewPort +'&serverId='+tmpServerId+'&serverPass='+tmpServerPass,
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
function loadExif(rObj) {
	getServer(rObj, 'EXIF');
}

function exifSetting(data, rLon, rlat) {
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
	if(rLon == null){
		line_data_buf_arr = line_buf_arr[15].split("\<Separator\>"); $('#lon_text').val(line_data_buf_arr[1]);
	}else{
		$('#lon_text').val(rLon);
	}
	
	//GPS Latitude
	if(rlat == null){
		line_data_buf_arr = line_buf_arr[16].split("\<Separator\>"); $('#lat_text').val(line_data_buf_arr[1]);
	}else{
		$('#lat_text').val(rlat);
	}
	
	//맵설정
	reloadMap(2);
}

/* map_start ----------------------------------- 맵 버튼 설정 ------------------------------------- */
function reloadMap(type) {
	var arr = readMapData();
	$('#googlemap').get(0).contentWindow.setCenter(arr[0], arr[1], 1);
	if(type==2) {
		if(imgDroneType != null && imgDroneType == 'Y'){
			$('#googlemap').get(0).contentWindow.drawCircleOnMap(arr[0], arr[1], 100);
		}else{
			$('#googlemap').get(0).contentWindow.setAngle(arr[2], arr[3]);
		}
	}
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
		init_map_top = 530;
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
			imageViewClose();
			openImageWrite();
		}
	});
}

//뷰어 닫기
function imageViewClose(){
	var iframes = window.parent.document.getElementsByTagName("IFRAME");
	for (var i = 0; i < iframes.length; i++) {
		var id = iframes[i].id || iframes[i].name || i;
		if (window.parent.frames[id] == window && jQuery.type( id ) != 'number') {
			var tmpID = id.replace("-VIEW", "");
			window.parent.jQuery("#" + tmpID).dialog('close');
		}
	}
// 	$.FrameDialog.closeDialog();	
}

//새창 띄우기 (저작)
function openImageWrite() {
	if(editUserYN == 0 && (projectUserId == loginId && projectUserId != user_id)){
		editUserYN = 1;
	}
	window.open('', 'image_write_page', 'width=1150, height=830');
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

<body onload='imageViewerInit();' style="overflow: hidden;">
<!---------------------------------------------------- 메인 영역 시작 ------------------------------------------------>

<!-- 이미지 영역 -->
<div id='image_main_area' style='position:absolute; left:10px; top:15px; width:780px; height:545px; display:block; border:1px solid #999999; overflow: hidden;'>
	<div id="image_viewer_canvas_div" style="width:780px; height: 545px; left:0px; top:0px;position:absolute;"><img id='image_viewer_canvas'></img></div>
	<div class="viewerMoreL" style="display: none;"></div>
	<div class="viewerMoreR" style="display: none;"></div>
</div>

<!-- 이미지 리스트 영역 -->
<div style="width:102%; height: 205px; margin: 565px 0 0 -10px;background:#25323c;">
	<div id="image_view_group" style="color:#ffffff; font-size: 16px; position: absolute; top:562px; left:10px; width:1110px; height: 38px;"></div>
	<div id="moveSelectDiv" style="position: absolute; left:410px; top:600px; width:200px; max-height: 76px; border:1px solid #00b8b0; overflow-y:auto; display:none; color:gray;"></div>
	
	<div id='img_move_area' style='position:absolute; left:10px; top:600px; width:1115px; height:160px; display:block; overflow-y:hidden;'>
		<img src='<c:url value='/images/geoImg/viewer/next_photo_pop.png'/>' style='float:right; display: none; margin-top: 10px;cursor: pointer;' class="imgMoveBtn" onclick="moveImgList('r')"> 
		<div id='img_move_list' style='position:absolute; height:100%; left:20px; top:10px; width: 1075px; display:block;overflow-x:auto; overflow-y:hidden;'>
			<div id='img_move_list_long' style='position:absolute; height:100%; display:block;'></div>
		</div>
		<img src='<c:url value='/images/geoImg/viewer/back_photo_pop.png'/>' style='float:left; display: none; margin-top: 10px; cursor: pointer;' class="imgMoveBtn" onclick="moveImgList('l')"> 
	</div>
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
<div id='image_map_area' style='position:absolute; left:765px; top:530px; width:30px; height:30px; display:block; background-color:#999;'>
	<iframe id='googlemap' src='<c:url value="/geoPhoto/image_googlemap.do"/>' style='width:100%; height:100%; margin:1px; border:none;'></iframe>
	<div id='resize_map_btn' onclick='resizeMap();' style='position:absolute; left:0px; top:0px; width:30px; height:30px; cursor:pointer; background-image:url(<c:url value='/images/geoImg/icon_map_max.jpg'/>);'>
	</div>
</div>

<!-- 좌표 설정 지도 영역 -->
<div id='image_map_area_gray' style='position:absolute; left:0px; top:0px; width:1135px; height:560px; display:none; background-color:#999;'>
	<iframe id='googlemap_gray' src='<c:url value="/geoPhoto/image_googlemap.do"/>' style='width:100%; height:100%; margin:1px; border:none;'></iframe>
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
				<td id='caption_checkbox_td'><input type="checkbox" name="caption_bg_checkbok" onclick="checkCaption();"/><label style="font-size:12px;">Transparency</label></td></tr>
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
				<td id='bubble_checkbox_td'><input type="checkbox" name="bubble_bg_checkbok" onclick="checkBubble();"/><label style=" font-size:12px;">Transparency</label></td></tr>
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
					<td rowspan='3'><button class="ui-state-default ui-corner-all" style="width:80px; height:30px; font-size:12px;" onclick="setGeometry();">Confirm</button></td>
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
	<button style="position:absolute; left:580px; top:780px; width:140px; height:35px; display:none; cursor: pointer;" onclick="imageViewClose();" id="viewerColstBtn">Close</button>
</body>

</html>
