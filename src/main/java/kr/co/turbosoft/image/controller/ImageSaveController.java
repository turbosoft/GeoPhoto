package kr.co.turbosoft.image.controller;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.Authenticator;
import java.net.HttpURLConnection;
import java.net.PasswordAuthentication;
import java.net.URL;
import java.net.URLEncoder;

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
	private String serverIdStrP;
	private String serverPassStrP;
	
	public void ImageSaveCon(String serverIdStrP, String serverPassStrP) {
		this.serverIdStrP = serverIdStrP;
        this.serverPassStrP = serverPassStrP;
    }
	
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
		String serverTypeStr = request.getParameter("serverType");
		String serverUrlSrt = request.getParameter("serverUrl");
		String serverViewPortStr = request.getParameter("serverViewPort");
		String serverPathStr = request.getParameter("serverPath");
		String serverIdStr = request.getParameter("serverId");
		String serverPassStr = request.getParameter("serverPass");
		
		String fileSavePathStr = request.getSession().getServletContext().getRealPath("/") + "mailPhoto";
		File file = new File(fileSavePathStr);
		if(!file.exists()) file.mkdir();
		file = new File(fileSavePathStr + File.separator + file_name_pre +"_tmp.jpg");
		
		String file_dir = "";
		if(serverTypeStr != null && "URL".equals(serverTypeStr)){
			file_name = URLEncoder.encode(file_name,"utf-8");
			file_dir = "http://"+ serverUrlSrt +":"+ serverViewPortStr +"/shares/"+serverPathStr +"/GeoPhoto/"+file_name;
			ImageSaveCon(serverIdStr, serverPassStr);
			try {
				URL gamelan = new URL(file_dir);
				Authenticator.setDefault(new Authenticator()
				{
				  @Override
				  protected PasswordAuthentication getPasswordAuthentication()
				  {
				    return new PasswordAuthentication(serverIdStrP, serverPassStrP.toCharArray());
				  }
				});
				
				HttpURLConnection urlConnection = (HttpURLConnection)gamelan.openConnection();
				
	            urlConnection.connect();
	            FileUtils.copyURLToFile(gamelan, file);
	            resultStr ="../mailPhoto/"+ file_name_pre +"_tmp.jpg";
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				resultStr = "ERROR";
			}
		}else{
			try {
				String fileOnePathStr = request.getSession().getServletContext().getRealPath("/");
				fileOnePathStr = fileOnePathStr.substring(0, fileOnePathStr.lastIndexOf("GeoPhoto")) + "GeoCMS"+ 
						fileOnePathStr.substring(fileOnePathStr.lastIndexOf("GeoPhoto")+8) +
						File.separator + serverPathStr + File.separator + "GeoPhoto"+ File.separator + file_name;
//				fileOnePathStr = fileOnePathStr.substring(0, fileOnePathStr.lastIndexOf("GeoPhoto")) + "GeoCMS"+ File.separator + serverPathStr + File.separator + "GeoPhoto"+ File.separator + file_name;
				
				FileInputStream fis = new FileInputStream(new File(fileOnePathStr));
				FileOutputStream fos = new FileOutputStream(file);
			   
				int data = 0;
				while((data=fis.read())!=-1) {
					fos.write(data);
				}
				fis.close();
				fos.close();
				resultStr ="../mailPhoto/"+ file_name_pre +"_tmp.jpg";
			  	}catch (Exception e) {
			  		// TODO Auto-generated catch block
			  		e.printStackTrace();
			  		resultStr = "ERROR";
			 	}
		}
		
		System.out.println("ImageSaveController file_dir = "+file_dir);
		
		
		//setContentType	
		response.setContentType("text/html;charset=utf-8");
		PrintWriter out = response.getWriter();
		out.print(resultStr);
	}
}
