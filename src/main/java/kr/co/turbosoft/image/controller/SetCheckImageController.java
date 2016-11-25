package kr.co.turbosoft.image.controller;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Controller
public class SetCheckImageController {
	@RequestMapping(value = "/geoSetChkImage.do", method = RequestMethod.POST)
	public void  geoSetChkImage(HttpServletRequest request, HttpServletResponse response) throws IOException {
		//setContentType 을 먼저 설정하고 getWriter		
		response.setContentType("text/html;charset=utf-8");
		PrintWriter out = response.getWriter();
		System.out.println("SetCheckProjectImage");
		out.print("SetCheckProjectImage");
	}
}
