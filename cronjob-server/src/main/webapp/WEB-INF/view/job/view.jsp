<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="ben"  uri="ben-taglib"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <jsp:include page="/WEB-INF/common/resource.jsp"/>

    <script type="text/javascript">

        function showCronExp(){$(".cronExpDiv").show()}
        function hideCronExp(){$(".cronExpDiv").hide()}
        function showCountDiv(){$(".countDiv").show()}
        function hideCountDiv(){$(".countDiv").hide()}

        function editSingle(id){
            $.ajax({
                url:"/job/canrun",
                data:{"id":id},
                success:function(data){
                    if ( !eval("("+data+")") ){

                        $.ajax({
                            url:"/job/editsingle",
                            data:{"id":id},
                            success : function(obj) {
                                $("#jobform")[0].reset();
                                if(obj!=null){
                                    $("#checkJobName").html("");
                                    $("#checkcronExp").html("");
                                    $("#id").val(obj.jobId);
                                    $("#mworkerId").val(obj.workerId);
                                    $("#jobName").val(obj.jobName);
                                    $("#worker").val(obj.workerName+"   "+obj.ip);
                                    $("#cronExp").val(obj.cronExp);
                                    $("#cmd").val(obj.command);
                                    if(obj.execType==1){
                                        $("#execType1").prop("checked",true);
                                        $("#execType1").parent().removeClass("checked").addClass("checked");
                                        $("#execType1").parent().attr("aria-checked",true);
                                        $("#execType0").parent().removeClass("checked");
                                        $("#execType0").parent().attr("aria-checked",false);
                                        hideCronExp();
                                    }else {
                                        $("#execType0").prop("checked",true);
                                        $("#execType0").parent().removeClass("checked").addClass("checked");
                                        $("#execType0").parent().attr("aria-checked",true);
                                        $("#execType1").parent().removeClass("checked");
                                        $("#execType1").parent().attr("aria-checked",false);
                                        showCronExp();
                                    }
                                    if(obj.cronType==1){
                                        $("#cronType1").prop("checked",true);
                                        $("#cronType1").parent().removeClass("checked").addClass("checked");
                                        $("#cronType1").parent().attr("aria-checked",true);
                                        $("#cronType0").parent().removeClass("checked");
                                        $("#cronType0").parent().attr("aria-checked",false);
                                    }else {
                                        $("#cronType0").prop("checked",true);
                                        $("#cronType0").parent().removeClass("checked").addClass("checked");
                                        $("#cronType0").parent().attr("aria-checked",true);
                                        $("#cronType1").parent().removeClass("checked");
                                        $("#cronType1").parent().attr("aria-checked",false);
                                    }
                                    if(obj.redo==1){
                                        $("#redo1").prop("checked",true);
                                        $("#redo1").parent().removeClass("checked").addClass("checked");
                                        $("#redo1").parent().attr("aria-checked",true);
                                        $("#redo0").parent().removeClass("checked");
                                        $("#redo0").parent().attr("aria-checked",false);
                                        showCountDiv();
                                    }else {
                                        $("#redo0").prop("checked",true);
                                        $("#redo0").parent().removeClass("checked").addClass("checked");
                                        $("#redo0").parent().attr("aria-checked",true);
                                        $("#redo1").parent().removeClass("checked");
                                        $("#redo1").parent().attr("aria-checked",false);
                                        hideCountDiv();
                                    }
                                    $("#runCount").val(obj.runCount);
                                    $('#jobModal').modal('show');
                                    return;
                                }
                            },
                            error : function() {
                                alert("网络繁忙请刷新页面重试!");
                            }
                        });
                    } else {
                        alert("当前任务正在运行中,暂时不能编辑!");
                    }
                },
                error : function() {
                    alert("网络异常，请刷新页面重试!");
                }
            });
        }

        function editFlow(id){
            $.ajax({
                url:"/job/canrun",
                data:{"id":id},
                success:function(data){
                    if ( !eval("("+data+")") ){
                        window.location.href = "/job/editflow?id=" + id;
                    } else {
                        alert("当前任务或其子任务正在运行中,暂时不能编辑!");
                    }
                },
                error : function() {
                    alert("网络异常，请刷新页面重试!");
                }
            });
        }

        function save(){
            var jobName = $("#jobName").val();
            if (!jobName){
                alert("请填写任务名称!");
                return false;
            }
            var jobId = $("#id").val();
            if (!jobId){
                alert("页面异常，请刷新重试!");
                return false;
            }

            var workerId = $("#mworkerId").val();
            if (!workerId){
                alert("页面异常，请刷新重试!");
                return false;
            }

            var execType = $('input[type="radio"][name="execType"]:checked').val();
            if (!execType){
                alert("页面错误，请刷新重试!");
                return false;
            }
            var cronType = $('input[type="radio"][name="cronType"]:checked').val();
            if (!cronType){
                alert("页面错误，请刷新重试!");
                return false;
            }
            var cronExp = $("#cronExp").val();
            if (execType == 0){
                if(!cronExp){
                    alert("请填写时间规则!");
                    return false;
                }
            }
            var command= $("#cmd").val();
            if (!command){
                alert("执行命令不能为空!");
                return false;
            }
            var redo = $('input[type="radio"][name="redo"]:checked').val();
            var runCount = $("#runCount").val();
            if (!redo){
                alert("页面错误，请刷新重试!");
                return false;
            }
            if (redo == 1){
                if (!runCount){
                    alert("请填写重跑次数!");
                    return false;
                }
                if(!cronjob.testNumber(runCount)){
                    alert("截止重跑次数必须为正整数!");
                    return false;
                }
            }

            $.ajax({
                url:"/validation/cronexp",
                data:{
                    "cronType":cronType,
                    "cronExp":cronExp
                },
                success:function(data){
                    if (data == "success"){
                        $.ajax({
                            url:"/job/checkname",
                            data:{
                                "id":jobId,
                                "name":jobName
                            },
                            success:function(data){
                                if (data == "yes"){
                                    $.ajax({
                                        url:"/job/edit",
                                        data:{
                                            "jobId":jobId,
                                            "cronType":cronType,
                                            "cronExp":cronExp,
                                            "workerId":workerId,
                                            "command":command,
                                            "execType":execType,
                                            "jobName":jobName,
                                            "redo":redo,
                                            "runCount":runCount
                                        },
                                        success:function(data){
                                            if (data == "success"){
                                                $('#jobModal').modal('hide');
                                                alertMsg("修改成功");

                                                $("#jobName_"+jobId).html(jobName);
                                                $("#cronType_"+jobId).html(cronType == "0" ? "crontab" : "quartz");
                                                $("#cronExp_"+jobId).html(cronExp);
                                                if (execType == "0"){
                                                    $("#execType_"+jobId).html('<font color="green">自动</font>');
                                                    $("#execButton_"+jobId).hide();
                                                }else {
                                                    $("#execType_"+jobId).html('<font color="red">手动</font>');
                                                    $("#execButton_"+jobId).show();
                                                }
                                                if (redo == "0"){
                                                    $("#redo_"+jobId).html('<font color="green">否</font>');
                                                }else {
                                                    $("#redo_"+jobId).html('<font color="red">是</font>');
                                                }
                                                $("#runCount_"+jobId).html(runCount);
                                                return false;
                                            }else {
                                                alert("修改失败");
                                            }
                                        },
                                        error : function() {
                                            alert("网络繁忙请刷新页面重试!");
                                            return false;
                                        }
                                    });
                                    return false;
                                }else {
                                    alert("任务名已存在!");
                                    return false;
                                }
                            },
                            error : function() {
                                alert("网络繁忙请刷新页面重试!");
                                return false;
                            }
                        });
                    }
                    else {
                        alert("时间规则语法错误!");
                        return false;
                    }
                },
                error : function() {
                    alert("网络异常，请刷新页面重试!");
                    return false;
                }
            });


        }

        $(document).ready(function(){

            $("#execType0").next().attr("onclick","showCronExp()");
            $("#execType1").next().attr("onclick","hideCronExp()");
            $("#redo1").next().attr("onclick","showCountDiv()");
            $("#redo0").next().attr("onclick","hideCountDiv()");

            $("#size").change(function(){doUrl();});
            $("#workerId").change(function(){doUrl();});
            $("#execType").change(function(){doUrl();});
            $("#redo").change(function(){doUrl();});
            $("#jobName").focus(function(){
                $("#checkJobName").html("");
            });
            $("#cronExp").focus(function(){
                $("#checkcronExp").html("");
            });

            $("#jobName").blur(function(){
                if(!$("#jobName").val()){
                    $("#checkJobName").html("<font color='red'>" + '<i class="glyphicon glyphicon-remove-sign"></i>&nbsp;请填写任务名称' + "</font>");
                    return false;
                }
                $.ajax({
                    url:"/job/checkname",
                    data:{
                        "id":$("#id").val(),
                        "name":$("#jobName").val()
                    },
                    success:function(data){
                        if (data == "yes"){
                            $("#checkJobName").html("<font color='green'>" + '<i class="glyphicon glyphicon-ok-sign"></i>&nbsp;任务名称可用' + "</font>");
                            return false;
                        }else {
                            $("#checkJobName").html("<font color='red'>" + '<i class="glyphicon glyphicon-remove-sign"></i>&nbsp;任务名称已存在' + "</font>");
                            return false;
                        }
                    },
                    error : function() {
                        alert("网络繁忙请刷新页面重试!");
                        return false;
                    }
                });
            });

            $("#cronExp").blur(function(){
                var cronType = $('input[type="radio"][name="cronType"]:checked').val();
                if (!cronType){
                    alert("页面错误，请刷新重试!");
                    return false;
                }
                var cronExp= $("#cronExp").val();
                if (!cronExp){
                    $("#checkcronExp").html("<font color='red'>" + '<i class="glyphicon glyphicon-remove-sign"></i>&nbsp;请填写时间规则' + "</font>");
                    return false;
                }
                $.ajax({
                    url:"/validation/cronexp",
                    data:{
                        "cronType":cronType,
                        "cronExp":cronExp
                    },
                    success:function(data){
                        if (data == "success"){
                            $("#checkcronExp").html("<font color='green'>" + '<i class="glyphicon glyphicon-ok-sign"></i>&nbsp;语法正确' + "</font>");
                            return;
                        }else {
                            $("#checkcronExp").html("<font color='red'>" + '<i class="glyphicon glyphicon-remove-sign"></i>&nbsp;语法错误' + "</font>");
                            return;
                        }
                    },
                    error : function() {
                        alert("网络异常，请刷新页面重试!");
                    }
                });
            });
        });

        function doUrl(){
            var pageSize = $("#size").val();
            var workerId = $("#workerId").val();
            var execType = $("#execType").val();
            var redo = $("#redo").val();
            window.location.href = "/job/view?workerId="+workerId+"&execType="+execType+"&redo="+redo+"&pageSize="+pageSize;
        }

        function executeJob(id){
            $.ajax({
                url:"/job/canrun",
                data:{"id":id},
                success:function(data){
                    if ( !eval("("+data+")") ){
                        swal({
                            title: "",
                            text: "您确定要执行这个任务吗？",
                            type: "warning",
                            showCancelButton: true,
                            closeOnConfirm: false,
                            confirmButtonText: "执行"
                        }, function() {
                            $.ajax({
                                url:"/job/execute",
                                data:{"id":id}
                            });
                            alertMsg( "该任务已启动,正在执行中.");
                        });
                    } else {
                        alert("当前任务已在运行中,不能重复执行!");
                    }
                },
                error : function() {
                    alert("网络异常，请刷新页面重试!");
                }
            });

        }

        function showChild(id,flowId){
            var open = $("#job_"+id).attr("childOpen");
            if (open == "off"){
                $("#icon"+id).removeClass("glyphicon-circle-arrow-down").addClass("glyphicon-circle-arrow-up");
                $(".child"+id).show();
                $(".trGroup"+flowId).css("background-color","rgba(0,0,0,0.1)");
                $("#job_"+id).attr("childOpen","on");
                $(".name_"+id+"_1").hide();
                $(".name_"+id+"_2").show();
            }else {
                $(".trGroup"+flowId).css("background-color","");
                $("#icon"+id).removeClass("glyphicon-circle-arrow-up").addClass("glyphicon-circle-arrow-down");
                $(".child"+id).hide();
                $("#job_"+id).attr("childOpen","off");
                $(".name_"+id+"_2").hide();
                $(".name_"+id+"_1").show();
            }
        }

    </script>
</head>

<jsp:include page="/WEB-INF/common/top.jsp"/>

<section id="content" class="container">

    <!-- Messages Drawer -->
    <jsp:include page="/WEB-INF/common/message.jsp"/>

    <!-- Breadcrumb -->
    <ol class="breadcrumb hidden-xs">
        <li class="icon">&#61753;</li>
        当前位置：
        <li><a href="">CronJob</a></li>
        <li><a href="">作业管理</a></li>
    </ol>
    <h4 class="page-title"><i class="fa fa-tasks" aria-hidden="true"></i>&nbsp;作业管理</h4>

    <!-- Deafult Table -->
    <div class="block-area" id="defaultStyle">
        <div>
            <div style="float: left">
                <label>
                    每页 <select size="1" class="select-self" id="size" style="width: 50px;">
                    <option value="15">15</option>
                    <option value="30" ${page.pageSize eq 30 ? 'selected' : ''}>30</option>
                    <option value="50" ${page.pageSize eq 50 ? 'selected' : ''}>50</option>
                    <option value="100" ${page.pageSize eq 100 ? 'selected' : ''}>100</option>
                </select> 条记录
                </label>
            </div>

            <div style="float: right;margin-top: -10px">
                <label for="workerId">执行器：</label>
                <select id="workerId" name="workerId" class="select-self" style="width: 110px;">
                    <option value="">全部</option>
                    <c:forEach var="d" items="${workers}">
                        <option value="${d.workerId}" ${d.workerId eq workerId ? 'selected' : ''}>${d.name}</option>
                    </c:forEach>
                </select>
                &nbsp;&nbsp;&nbsp;
                <label for="execType">模式：</label>
                <select id="execType" name="execType" class="select-self" style="width: 80px;">
                    <option value="">全部</option>
                    <option value="1" ${execType eq 1 ? 'selected' : ''}>手动</option>
                    <option value="0" ${execType eq 0 ? 'selected' : ''}>自动</option>
                </select>
                &nbsp;&nbsp;&nbsp;

                <label for="redo">重跑：</label>
                <select id="redo" name="redo" class="select-self" style="width: 80px;">
                    <option value="">全部</option>
                    <option value="1" ${redo eq 1 ? 'selected' : ''}>是</option>
                    <option value="0" ${redo eq 0 ? 'selected' : ''}>否</option>
                </select>

                <a href="/job/addpage" class="btn btn-sm m-t-10" style="margin-left: 50px;margin-bottom: 8px"><i class="icon">&#61943;</i>添加</a>
            </div>
        </div>

        <table class="table tile" style="font-size: 13px;">
            <thead>
            <tr>
                <th>名称</th>
                <th>类型</th>
                <th>执行器</th>
                <th>任务人</th>
                <th>规则类型</th>
                <th>时间规则</th>
                <th>模式</th>
                <th>重跑</th>
                <th>重跑次数</th>
                <th><center>
                    <i class="icon-time bigger-110 hidden-480"></i>
                    操作
                </center></th>
            </tr>
            </thead>
            <tbody>
            <%--父任务--%>
            <c:forEach var="r" items="${page.result}" varStatus="index">
                <tr class="trGroup${r.flowId}">
                    <c:if test="${r.category eq 0}">
                        <td id="jobName_${r.jobId}">${r.jobName}</td>
                        <td>单一任务</td>
                    </c:if>
                    <c:if test="${r.category eq 1}">
                        <td  class="name_${r.flowId}_1">${r.jobName}</td>
                        <td style="display: none;" class="name_${r.flowId}_2" rowspan="${fn:length(r.children)+1}">
                                ${r.jobName}
                            <c:forEach var="c" items="${r.children}" varStatus="index">
                                <div class="down"><img src="/img/down.png" width="15px" height="12px"></div>${c.jobName}
                            </c:forEach>
                        </td>
                        <td>流程任务</td>
                    </c:if>
                    <td><a href="/worker/detail?id=${r.workerId}">${r.workerName}</a></td>
                    <c:if test="${permission eq true}"><td><a href="/user/self?id=${r.operateId}">${r.operateUname}</a></td></c:if>
                    <c:if test="${permission eq false}"><td>${r.operateUname}</td></c:if>
                    <td id="cronType_${r.jobId}">
                        <c:if test="${r.cronType eq 0}">crontab</c:if>
                        <c:if test="${r.cronType eq 1}">quartz</c:if>
                    </td>
                    <td id="cronExp_${r.jobId}">${r.cronExp}</td>
                    <td id="execType_${r.jobId}">
                        <c:if test="${r.execType eq 1}"><font color="red">手动</font></c:if>
                        <c:if test="${r.execType eq 0}"><font color="green">自动</font></c:if>
                    </td>
                    <td id="redo_${r.jobId}">
                        <c:if test="${r.redo eq 0}"><font color="green">否</font></c:if>
                        <c:if test="${r.redo eq 1}"><font color="red">是</font></c:if>
                    </td>
                    <td id="runCount_${r.jobId}">${r.runCount}</td>
                    <td >
                        <center>
                            <div class="visible-md visible-lg hidden-sm hidden-xs action-buttons">
                                <c:if test="${r.category eq 1}">
                                    <a href="#" title="流程任务" id="job_${r.jobId}" childOpen="off" onclick="showChild('${r.jobId}','${r.flowId}')">
                                        <i class="glyphicon glyphicon-circle-arrow-down" id="icon${r.jobId}"></i>
                                    </a>&nbsp;&nbsp;
                                </c:if>
                                <c:if test="${r.category eq 0}">
                                    <a href="#" title="编辑" onclick="editSingle('${r.jobId}')">
                                        <i class="glyphicon glyphicon-pencil"></i>
                                    </a>
                                </c:if>
                                <c:if test="${r.category eq 1}">
                                    <a title="编辑" onclick="editFlow('${r.jobId}')">
                                        <i class="glyphicon glyphicon-pencil"></i>
                                    </a>
                                </c:if>
                                &nbsp;&nbsp;
                                    <span id="execButton_${r.jobId}" style="display: ${r.execType eq 1 ? 'inline' : 'none'}">
                                        <a href="#" title="执行" onclick="executeJob('${r.jobId}')">
                                           <i aria-hidden="true" class="fa fa-play-circle"></i>
                                        </a>&nbsp;&nbsp;
                                    </span>
                                <a href="/job/detail?id=${r.jobId}" title="查看详情">
                                    <i class="glyphicon glyphicon-eye-open"></i>
                                </a>
                            </div>
                        </center>
                    </td>
                </tr>
                <%--子任务--%>
                <c:if test="${r.category eq 1}">
                    <c:forEach var="c" items="${r.children}" varStatus="index">
                        <tr class="child${r.jobId} trGroup${r.flowId}" style="display: none;">
                            <td>流程任务</td>
                            <td><a href="/worker/detail?id=${c.workerId}">${c.workerName}</a></td>
                            <c:if test="${permission eq true}"><td><a href="/user/self?id=${c.operateId}">${c.operateUname}</a></td></c:if>
                            <c:if test="${permission eq false}"><td>${c.operateUname}</td></c:if>
                            <td>
                                <c:if test="${c.cronType eq 0}">crontab</c:if>
                                <c:if test="${c.cronType eq 1}">quartz</c:if>
                            </td>
                            <td>${c.cronExp}</td>
                            <td>
                                <c:if test="${c.execType eq 1}"><font color="red">手动</font></c:if>
                                <c:if test="${c.execType eq 0}"><font color="green">自动</font></c:if>
                            </td>
                            <td>
                                <c:if test="${c.redo eq 0}"><font color="green">否</font></c:if>
                                <c:if test="${c.redo eq 1}"><font color="red">是</font></c:if>
                            </td>
                            <td>${c.runCount}</td>
                            <td>
                                <center>
                                    <div class="visible-md visible-lg hidden-sm hidden-xs action-buttons">
                                        <a href="/job/detail?id=${c.jobId}" title="查看详情">
                                            <i class="glyphicon glyphicon-eye-open"></i>
                                        </a>
                                    </div>
                                </center>
                            </td>
                        </tr>
                    </c:forEach>
                </c:if>
            </c:forEach>
            </tbody>
        </table>

        <ben:pager href="/job/view?workerId=${workerId}&execType=${execType}&redo=${redo}" id="${page.pageNo}" size="${page.pageSize}" total="${page.totalCount}"/>

    </div>

    <!-- 修改任务弹窗 -->
    <div class="modal fade" id="jobModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <h4>修改任务</h4>
                </div>
                <div class="modal-body">
                    <form class="form-horizontal" role="form" id="jobform">
                        <input type="hidden" id="id">
                        <input type="hidden" name="workerId" id="mworkerId">
                        <div class="form-group">
                            <label for="worker" class="col-lab control-label" title="要执行此任务的机器名称和IP地址">执&nbsp;&nbsp;行&nbsp;&nbsp;器：</label>
                            <div class="col-md-8">
                                <input type="text" class="form-control pop-sm" id="worker" readonly>&nbsp;
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="jobName" class="col-lab control-label" title="任务名称必填">任务名称：</label>
                            <div class="col-md-8">
                                <input type="text" class="form-control pop-sm" id="jobName">&nbsp;&nbsp;<label id="checkJobName"></label>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-lab control-label" title="1.手动模式: 管理员手动执行 2.自动模式: 执行器自动执行">运行模式：</label>&nbsp;&nbsp;
                            <label for="execType1" onclick="hideCronExp()" class="radio-label"><input type="radio" name="execType" value="1" id="execType1">手动&nbsp;&nbsp;&nbsp;</label>
                            <label for="execType0" onclick="showCronExp()" class="radio-label"><input type="radio" name="execType" value="0" id="execType0">自动</label>
                        </div>
                        <div class="form-group cronExpDiv">
                            <label class="col-lab control-label" title="1.crontab: unix/linux的时间格式表达式&nbsp;&nbsp;2.quartz: quartz框架的时间格式表达式">规则类型：</label>&nbsp;&nbsp;
                            <label for="cronType0" class="radio-label" class="radio-label"><input type="radio" name="cronType" value="0" id="cronType0">crontab&nbsp;&nbsp;&nbsp;</label>
                            <label for="cronType1" class="radio-label" class="radio-label"><input type="radio" name="cronType" value="1" id="cronType1">quartz</label>
                        </div><br>
                        <div class="form-group cronExpDiv">
                            <label for="cronExp" class="col-lab control-label" title="请采用对应类型的时间格式表达式">时间规则：</label>
                            <div class="col-md-8">
                                <input type="text" class="form-control pop-sm" id="cronExp"/>&nbsp;&nbsp;<label id="checkcronExp"></label>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="cmd" class="col-lab control-label" title="请采用unix/linux的shell支持的命令">执行命令：</label>
                            <div class="col-md-8">
                                <textarea class="form-control pop-sm" id="cmd" name="cmd"></textarea>&nbsp;
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-lab control-label" title="任务失败后是否重新执行此任务">重新执行：</label>&nbsp;&nbsp;
                            <label for="redo1" onclick="showCountDiv()" class="radio-label"><input type="radio" name="redo" value="1" id="redo1"> 是&nbsp;&nbsp;&nbsp;</label>
                            <label for="redo0" onclick="hideCountDiv()" class="radio-label"><input type="radio" name="redo" value="0" id="redo0"> 否</label>
                        </div><br>
                        <div class="form-group countDiv">
                            <label for="runCount" class="col-lab control-label" title="执行失败时自动重新执行的截止次数">重跑次数：</label>
                            <div class="col-md-8">
                                <input type="text" class="form-control pop-sm" id="runCount"/>&nbsp;
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <center>
                        <button type="button" class="btn btn-sm"  onclick="save()">保存</button>&nbsp;&nbsp;
                        <button type="button" class="btn btn-sm"  data-dismiss="modal">关闭</button>
                    </center>
                </div>
            </div>
        </div>
    </div>

</section>
<br/><br/>

<jsp:include page="/WEB-INF/common/footer.jsp"/>


