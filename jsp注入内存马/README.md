## servlet-api类

Servlet：servlet是一种运行服务器端的java应用程序，具有独立于平台和协议的特性，并且可以动态的生成web页面，它工作在客户端请求与服务器响应的中间层。Servlet 的主要功能在于交互式地浏览和修改数据，生成动态 Web 内容。

Filter：filter是一个可以复用的代码片段，可以用来转换HTTP请求、响应和头信息。Filter无法产生一个请求或者响应，它只能针对某一资源的请求或者响应进行修改。

Listener：通过listener可以监听web服务器中某一个执行动作，并根据其要求作出相应的响应。

### 三者的生命周期

Servlet ：Servlet 的生命周期开始于Web容器的启动时，它就会被载入到Web容器内存中，直到Web容器停止运行或者重新装入servlet时候结束。这里也就是说明，一旦Servlet被装入到Web容器之后，一般是会长久驻留在Web容器之中。

+ 装入：启动服务器时加载Servlet的实例

+ 初始化：web服务器启动时或web服务器接收到请求时，或者两者之间的某个时刻启动。初始化工作有init()方法负责执行完成

+ 调用：从第一次到以后的多次访问，都是只调用doGet()或doPost()方法

+ 销毁：停止服务器时调用destroy()方法，销毁实例



Filter：自定义Filter的实现，需要实现javax.servlet.Filter下的init()、doFilter()、destroy()三个方法。

+ 启动服务器时加载过滤器的实例，并调用init()方法来初始化实例；

+ 每一次请求时都只调用方法doFilter()进行处理；

+ 停止服务器时调用destroy()方法，销毁实例。



Listener：以ServletRequestListener为例，ServletRequestListener主要用于监听ServletRequest对象的创建和销毁,一个ServletRequest可以注册多个ServletRequestListener接口。

+ 每次请求创建时调用requestInitialized()。

+ 每次请求销毁时调用requestDestroyed()。

最后要注意的是，web.xml对于这三种组件的加载顺序是：listener -> filter -> servlet，也就是说listener的优先级为三者中最高的。

### 参考链接
https://mp.weixin.qq.com/s/YhiOHWnqXVqvLNH7XSxC9w