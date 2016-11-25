<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- css -->
<link type="text/css" href="<c:url value='/css/content_common.css'/>" rel="Stylesheet"/>

<!-- jQuery & jQuery UI -->
<link type="text/css" href="<c:url value='/lib/jquery/css/smoothness/jquery-ui-1.8.11.custom.css'/>" rel="Stylesheet" />
<script type="text/javascript" src="<c:url value='/lib/jquery/js/jquery-1.5.1.min.js'/>"></script>
<script type="text/javascript" src="<c:url value='/lib/jquery/js/jquery-ui-1.8.11.custom.min.js'/>"></script>

<!-- jAlert -->
<link type="text/css" href="<c:url value='/lib/jalert/jquery.alerts.css'/>" rel="Stylesheet" />
<script type="text/javascript" src="<c:url value='/lib/jalert/jquery.alerts.js'/>"></script>

<!-- framedialog -->
<script type="text/javascript" src="<c:url value='/lib/framedialog/jquery.framedialog.js'/>"></script>

<!-- icolorpicker -->
<script type="text/javascript" src="<c:url value='/lib/icolorpicker/iColorPicker.js'/>"></script>

<!-- accordion -->
<link type="text/css" href="<c:url value='/lib/accordion/jquery.accordion.css" rel="Stylesheet'/>" />
<script type="text/javascript" src="<c:url value='/lib/accordion/jquery.accordion.js'/>"></script>

<!-- zindex -->
<script type="text/javascript" src="<c:url value='/lib/zindex/zindex.js'/>"></script>

<!-- contextmenu -->
<script type="text/javascript" src="<c:url value='/lib/contextmenu/jquery.contextmenu.r2.js'/>"></script>

<script type="text/javascript">
var baseRoot = function(){ 
	var br = "http://"+ location.host+"/GeoCMS_Gateway/";
	return br;
};
</script>