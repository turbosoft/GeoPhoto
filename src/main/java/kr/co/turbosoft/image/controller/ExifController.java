package kr.co.turbosoft.image.controller;

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
	
	@Value("#{props['file.serverUrl']}")
	private String serverUrlStr;
	
	@Value("#{props['file.userId']}")
	private String userIdStr;
	
	@Value("#{props['file.userPass']}")
	private String userPassStr;
	
	@Value("#{props['file.portNum']}")
	private String portNumStr;
	
	@Value("#{props['file.saveFilePath']}")
	private String saveFilePathStr;
	
	@RequestMapping(value = "/geoExif.do", method = RequestMethod.POST)
	public void geoPhotoExif(HttpServletRequest request, HttpServletResponse response) throws IOException {
		request.setCharacterEncoding("utf-8");
		
		String file_name = request.getParameter("file_name");
		String type = request.getParameter("type");
		if(file_name != null && !"".equals(file_name)){
			file_name = file_name.replace("\\/", "/");
		}
		file_name = URLEncoder.encode(file_name,"utf-8");
		
		String file_dir = "http://"+ serverUrlStr + "/shares/"+saveFilePathStr;
		String fileSavePathStr = request.getSession().getServletContext().getRealPath("/");
		fileSavePathStr = fileSavePathStr.replace("GeoPhoto/", "");
		fileSavePathStr = fileSavePathStr+"GeoCMS_Gateway/upload";
		
		System.out.println("file_dir = "+file_dir);
		
		ExifRW exifRW = new ExifRW();
		String result = "";
		
		if(type.equals("init") || type.equals("load")) {
			result = exifRW.read(fileSavePathStr, file_dir, file_name, type);
			System.out.println(result);
		}
		else if(type.equals("save")){
			String data = request.getParameter("data");
			String[] split_data = exifRW.parseData(data);
			exifRW.write(file_dir+"/"+ file_name, split_data);
		}
		else {}
		
		//setContentType	
		response.setContentType("text/html;charset=utf-8");
		PrintWriter out = response.getWriter();
		out.print(result);
	}
}
