package kr.co.turbosoft.image.controller;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import kr.co.turbosoft.image.util.ExifRW;

@Controller
public class ExifController {
	
	@RequestMapping(value = "/geoExif.do", method = RequestMethod.POST)
	public void geoPhotoExif(HttpServletRequest request, HttpServletResponse response) throws IOException {
		request.setCharacterEncoding("utf-8");
		String type = request.getParameter("type");
		String[] buf = request.getParameter("file_name").split("\\/");
		String file_path = buf[0];
		String file_name = buf[1];
		
		String serverTypeStr = request.getParameter("serverType");
		String serverUrlSrt = request.getParameter("serverUrl");
		String serverViewPortStr = request.getParameter("serverViewPort");
		String serverPathStr = request.getParameter("serverPath");
		String serverIdStr = request.getParameter("serverId");
		String serverPassStr = request.getParameter("serverPass");
		
		String file_full_url = "";
		if(serverTypeStr != null && "URL".equals(serverTypeStr)){
			file_full_url = "http://"+ serverUrlSrt +":"+ serverViewPortStr +"/shares/"+serverPathStr +"/"+ file_path;
		}
		String fileSavePathStr = request.getSession().getServletContext().getRealPath("/");
		fileSavePathStr = fileSavePathStr.substring(0, fileSavePathStr.lastIndexOf("GeoPhoto")) + "GeoCMS"+ 
				fileSavePathStr.substring(fileSavePathStr.lastIndexOf("GeoPhoto")+8) +
				File.separator + file_path;
		
		System.out.println("file_full_url = "+file_full_url);
		
		ExifRW exifRW = new ExifRW();
		String result = "";
		
		exifRW.exifSettingCon(fileSavePathStr, serverUrlSrt, serverIdStr, serverPassStr, serverPathStr);
		if(type.equals("init") || type.equals("load")) {
			result = exifRW.read(file_full_url, type, file_path, file_name);
			System.out.println(result);
		}
		
		//setContentType	
		response.setContentType("text/html;charset=utf-8");
		PrintWriter out = response.getWriter();
		out.print(result);
	}
}
