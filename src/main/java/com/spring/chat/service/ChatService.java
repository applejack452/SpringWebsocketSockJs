package com.spring.chat.service;

import org.springframework.web.socket.WebSocketSession;

public interface ChatService {

	public void registerOpenConnection(WebSocketSession session);
	
	public void processMessage(WebSocketSession session, String message) throws Exception;
	
	public void registerCloseConnection(WebSocketSession session) throws Exception;
}
