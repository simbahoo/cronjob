<!DOCTYPE html>
<html lang="zh-CN">

<head>
    <title>WebConsole</title>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1.0,maximum-scale=1.0, user-scalable=no">
    <meta name="renderer" content="webkit">

    <script src="/js/metro-ui/js/metro.min.js" type="text/javascript"></script>
    <script src="/js/termjs/term.min.js" type="text/javascript"></script>
    <script src="/js/console.js" type="text/javascript"></script>
    <script src="/js/bowser.min.js" type="text/javascript"></script>

    <!--[if lt IE 9]>
    <script src="/js/html5/json/json2.min.js" type="text/javascript"></script>
    <script src="/js/html5/html5shiv/html5shiv.min.js" type="text/javascript"></script>
    <script src="/js/html5/respond/respond.min.js" type="text/javascript"></script>
    <![endif]-->
    <style type="text/css">
    .terminal {
        width: 100%;
    }
    </style>
</head>

<body class="bg-steel">
    <div class="page-content">
        <div id="console_div"></div>
    </div>
</body>
<script type="text/javascript">
var bowserVerErrMsg = "WebClonsole 工具使用了 HTML5 的核心相关技术，为了更好的体验该工具，请升级您的浏览器到IE9、Chrome 40、Firefox 38、Safari 9或更高版本。";

var bowserVer = Number(bowser.version);

var bowserVerFunc = function() {
    var bowserBody = document.getElementsByTagName("body")[0];
    bowserBody.innerHTML = "";

    var errDiv = document.createElement("div");
    errDiv.innerHTML = bowserVerErrMsg;
    errDiv.style.display = "inline-block";
    errDiv.style.position = "absolute";
    errDiv.style.zIndex = "1500";
    errDiv.style.top = "40%";
    errDiv.style.width = "100%";
    errDiv.style.textAlign = "center";
    errDiv.style.color = "#FFFFFF";

    bowserBody.appendChild(errDiv);
};


if (bowser.msie && bowserVer < 9) {
    bowserVerFunc();
    alert(bowserVerErrMsg);
}

if (bowser.firefox && bowserVer < 38) {
    bowserVerFunc();
    alert(bowserVerErrMsg);
}

if (bowser.chrome && bowserVer < 40) {
    bowserVerFunc();
    alert(bowserVerErrMsg);
}

if (bowser.safari && bowserVer < 9) {
    bowserVerFunc();
    alert(bowserVerErrMsg);
}
</script>

<script type="text/javascript">
$(function() {
    $("#console_div").OpenTerminal({
        "wsaddr": "<abc% .WS_Addr %>"
    });
});
</script>

</html>
