package kr.co.turbosoft.image.controller;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.Authenticator;
import java.net.HttpURLConnection;
import java.net.PasswordAuthentication;
import java.net.URL;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FileUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import kr.co.turbosoft.image.util.ExifRW;

@Controller
public class ImageSaveController {
	
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
	
	
	@RequestMapping(value = "/ImageSaveInit.do", method = RequestMethod.POST)
	public void ImageSave(HttpServletRequest request, HttpServletResponse response) throws IOException {
		request.setCharacterEncoding("utf-8");
		String resultStr = "";
		String file_name = request.getParameter("file_name");
		String file_name_pre = "";
		if(file_name != null && !"".equals(file_name)){
			file_name = file_name.replace("\\/", "/");
			file_name_pre = file_name.substring(0,file_name.lastIndexOf("."));
		}
		
		String file_dir = "http://"+ serverUrlStr + "/shares/"+saveFilePathStr +"/GeoPhoto/"+file_name;
		System.out.println("file_dir = "+file_dir);
		
		String tmpFileDir = request.getSession().getServletContext().getRealPath("/")+ "upload";
		File file = new File(tmpFileDir);
		if(!file.exists()) file.mkdir();
		file = new File(tmpFileDir+"//"+ file_name_pre +"_tmp.jpg");
		
		try {
			URL gamelan = new URL(file_dir);
			Authenticator.setDefault(new Authenticator()
			{
			  @Override
			  protected PasswordAuthentication getPasswordAuthentication()
			  {
			    return new PasswordAuthentication(userIdStr, userPassStr.toCharArray());
			  }
			});
			HttpURLConnection urlConnection = (HttpURLConnection)gamelan.openConnection();
			
            urlConnection.connect();
            FileUtils.copyURLToFile(gamelan, file);
            resultStr ="../upload/"+ file_name_pre +"_tmp.jpg";
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			if(file.exists()){file.delete();}
			resultStr = "ERROR";
		}
		
		//setContentType	
		response.setContentType("text/html;charset=utf-8");
		PrintWriter out = response.getWriter();
		out.print(resultStr);
	}
}
