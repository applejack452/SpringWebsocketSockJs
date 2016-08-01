<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<head>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<!-- <link href="assets/css/bootstrap-responsive.css" rel="stylesheet">  -->
	<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css">
	<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap-theme.min.css">
	<script src="//code.jquery.com/jquery.min.js"></script>
	<script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.2/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="<c:url value="/js/sockjs-0.3.4.js"/>"></script>
	
	<style>
		.contentDiv{
			width:100%;
			height:350px;
			border-color:pink;
			border-width:thin;
			border-style:solid;
			border-radius:5px;
			overflow: auto;
		}
		
		.username{
			color:purple;
			font-weight:bold;
		}
		
		.myUsername{
			color:blue;
			font-weight:bold;		
		}
		
		#textMessage{
			border-color:pink;
		}
		
		@media screen and (min-width: 480px) {
			.container {
    			max-width: 768px;
  		}
	}		
	</style>
	
	<script>
		var socket;
	
		$(document).ready(function(){
			$("#login_modal").modal({keyboard:false, backdrop:'static'});
			
			$('#login_modal').on('shown.bs.modal', function () {
				  $('#nickname').focus();
			});
			
			$("#nickname").keyup(function(e){
				if(e.keyCode == 13){
					if($("#nickname").val()){
						$("#login_modal").modal("hide");
						
						chatClient();
					}
				}
			});
			
			$("#btnLogin").click(function(){
				if($("#nickname").val()){
					$("#login_modal").modal("hide");
					
					chatClient();
				}
			});
			
			
		});	
		
		function chatClient(){
			socket = new SockJS("/chat/echo");
			
			socket.onopen = function(){
				console.log("onopen socket");
				var nickname = $("#nickname").val();
			    socket.send(nickname);			    
			};
						
			socket.onmessage = function(a) {
			      
			      console.log("received message: " + a.data);
			      var message = JSON.parse(a.data);
			     
			      if (message.addUser) {
			        var d = document.createElement('div');
			        
			        if($("#nickname").val() == message.addUser){
			        	$(d).addClass("username user").text(message.addUser+"(나)").attr("data-user", message.addUser).appendTo($("#nicknamesBox"));
			        }
			        else
			        {
			        	$(d).addClass("myUsername user").text(message.addUser).attr("data-user", message.addUser).appendTo($("#nicknamesBox"));	
			        }
			        /* $("#chatBox").append("<div>" + message.addUser + "님이 참가 하셨습니다. </div>"); */
			      } else if (message.removeUser) {
			        $(".user[data-user="+message.removeUser+"]").remove();
			        $("#chatBox").append("<div><b>" + message.removeUser + "</b> 님이 퇴장 하셨습니다.</div>");
			        $("#chatBox").scrollTop($("#chatBox")[0].scrollHeight);
			      } else if (message.message) {
			        var d = document.createElement('div');
			        var suser = document.createElement('span');
			        var smessage = document.createElement('span');
			        
			        if($("#nickname").val() == message.nickname){
			        	$(suser).addClass("username").text(message.nickname + " : ").appendTo($(d));
			        }
			        else {
			        	$(suser).addClass("myUsername").text(message.nickname + " : ").appendTo($(d));
			        }
			        
			        $(smessage).text(message.message).appendTo($(d));
			        $(d).appendTo("#chatBox");			  
			        $("#chatBox").scrollTop($("#chatBox")[0].scrollHeight);
			      }			      
			};
			
			$("#textMessage").keyup(function(e){
				if(e.keyCode == 13){
					sendMessage();
				}
			});
			
			$("#btnSend").click(function(){
				sendMessage();
			});
			   
		}
		
		function sendMessage(){
			var textMessage = $("#textMessage").val();
			if(textMessage){
				socket.send(textMessage);
				$("#textMessage").val("");
			}
		}
	</script>
	
</head>
<body>
	<div class="container">
		<div class="row">
			<div class="col-xs-9">
				<h4>( Spring 4.2.4, WebSocket, SockJs 0.3.4 )</h4>
			</div>
		</div>	
		<div class="row">
			<div class="col-xs-9">
				<div><h3>채팅</h3></div>
				<div class="contentDiv" id="chatBox"><!-- 채팅 내용 --></div>
			</div>
			<div class="col-xs-3">
				<div><h3>유저</h3></div>
				<div class="contentDiv" id="nicknamesBox"><!-- 유저 별명 목록 --></div>
			</div>
		</div>
		
		<div class="row" style="margin-top:10px;">
			<div class="col-xs-9"><input type="text" id="textMessage" class="form-control" placeholder="메세지를 입력하세요"/></div>
			<div class="col-xs-3"><button id="btnSend" class="btn btn-primary">입력</button></div>
		</div>
	</div>
	
	<!-- 별명 입력 모달창 -->
	<div class="modal fade" id="login_modal">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<h4 class="modal-title">별명을 입력하세요</h4>
				</div>			
				<div class="modal-body">					
					<div><input type="text" id="nickname" class="form-control" style="width:200px" placeholder="입력......"></div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-primary" id="btnLogin">만들기</button>
				</div>
			</div>
		</div>
	</div>
</body>
</html>
