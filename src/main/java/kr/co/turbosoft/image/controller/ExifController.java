package kr.co.turbosoft.image.controller;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import kr.co.turbosoft.image.util.ExifRW;

@Controller
public class ExifController {
	@RequestMapping(value = "/geoExif.do", method = RequestMethod.POST)
	public void geoPhotoExif(HttpServletRequest request, HttpServletResponse response) throws IOException {
		request.setCharacterEncoding("utf-8");
		
		String file_name = request.getParameter("file_name");
		String type = request.getParameter("type");
		if(file_name != null && !"".equals(file_name)){
			file_name = file_name.replace("\\/", "/");
		}
		
		String file_dir = request.getSession().getServletContext().getRealPath("/")+file_name;
		
		System.out.println("file_dir = "+file_dir);
		
		ExifRW exifRW = new ExifRW();
		String result = "";
		
		if(type.equals("init") || type.equals("load")) {
			result = exifRW.read(file_dir, type);
			System.out.println(result);
		}
		else if(type.equals("save")){
			String data = request.getParameter("data");
			String[] split_data = exifRW.parseData(data);
			exifRW.write(file_dir, split_data);
		}
		else {}
		
		//setContentType �� ���� �����ϰ� getWriter		
		response.setContentType("text/html;charset=utf-8");
		PrintWriter out = response.getWriter();
		out.print(result);
	}
}
