﻿<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="ben"  uri="ben-taglib"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<c:forEach var="m" items="${message}" varStatus="index">

    <div class="media">
        <div class="pull-left">
            <i class="icon" style="font-size: 28px;color:rgba(255,255,255,0.75)">${m.type eq 0?"&#61880;":"&#61704;"}</i>
        </div>
        <div class="media-body">
            <small class="text-muted">cronjob告警 - <fmt:formatDate value="${m.sendTime}" pattern="yyyy-MM-dd HH:mm:ss"/></small><br>
            <a class="t-overflow" href="/notice/detail?logId=${m.logId}">${m.message}</a>
        </div>
    </div>

</c:forEach>
