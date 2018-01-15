<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">

<jsp:include page="page_common.jsp"></jsp:include>

<title>GeoCMS</title>

<script type="text/javascript">
var typeShape ="marker";
var LocationData = []; 	//마커용
var projectBoard = 0;	//GeoCMS 연동여부		0:연동안됨, 1:연동됨
var projectVideo = 0;	//GeoCMS_video 연동여부		0:연동안됨, 1:연동됨
var request = null;		//request;

$(function() {
	var mapWidth = $(window).width()- $('#image_list').width()-10;	//화면 크기에 따라 이미지 크기 조정
	$('#image_map').css('width', mapWidth);
	
	//GeoCMS conn check
	callRequest("SetCheckBoardServlet");
});

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
		if(request.readyState == 4 && request.status != 200){
			$.cookie('id', 'null');
			$.cookie('status', 'login', {expires: 1});
			$.cookie('type', 'MODIFY', {expires: 1});
		}
	}
}

//GeoCMS 연결여부 확인 function
function callRequest(textUrl){
	httpRequest(textUrl);
	request.open("POST", "http://"+location.host + "/GeoCMS/" + textUrl, true);
	request.send();
}

</script>
</html>