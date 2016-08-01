
package com.spring.chat.handler;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import com.spring.chat.service.ChatService;

@Component
public class ChatWebSocketHandler extends TextWebSocketHandler {
	Logger log = Logger.getLogger(this.getClass());
	
	@Autowired
	private ChatService chatService;
  
	@Override
	public void afterConnectionEstablished(WebSocketSession session) throws Exception {
	    chatService.registerOpenConnection(session);
	    
	}
	
	@Override
	public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
		chatService.registerCloseConnection(session);
		
	}
	
	@Override
	public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
		chatService.registerCloseConnection(session);
		
	}
	
	@Override
	protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
		chatService.processMessage(session, message.getPayload());
		
	}
}
