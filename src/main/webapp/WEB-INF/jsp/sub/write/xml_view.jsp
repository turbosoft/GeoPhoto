<%@ page language="java" contentType="text/html; charset=EUC-KR"
	import="java.net.*"
    pageEncoding="EUC-KR"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>XML Viewer</title>

<jsp:include page="../../page_common.jsp"></jsp:include>

<%
String xml_data = URLDecoder.decode(request.getParameter("xml_data"), "utf-8");
%>

<script type="text/javascript">

var xml_data = '<%= xml_data %>';

function init() {
	$('#xml_textarea').val(xml_data);
}


</script>

</head>
<body onload='init();'>

<div>
<textarea id='xml_textarea' style='width:500px; height:600px; font-family:Fixedsys;'  wrap='off'></textarea>
</div>

</body>
</html>