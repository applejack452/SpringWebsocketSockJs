package com.spring.chat.service.impl;

import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import org.apache.log4j.Logger;
import org.json.JSONObject;
import org.springframework.stereotype.Service;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import com.spring.chat.service.ChatService;

@Service("chatService")
public class ChatServiceImpl implements ChatService{
	
	Logger log = Logger.getLogger(this.getClass());

	//private ArrayList<WebSocketSession> connList = new ArrayList<WebSocketSession>();
	private Set<WebSocketSession> connSet = new HashSet<WebSocketSession>(); // 유저 웹소켓 세션 저장... 삭제의 용이함을 위해 Set으로......
	private Map<String, String> nicknamesMap = new ConcurrentHashMap<String,String>(); // 유저 아이디 맵 (key=세션 아이디, value="유저 아이디")
	
	@Override
	public void registerOpenConnection(WebSocketSession session) {
		connSet.add(session);		
	}
	
	@Override
	public void registerCloseConnection(WebSocketSession session) throws Exception {
		String nickname = nicknamesMap.get(session.getId());
		connSet.remove(session);
		nicknamesMap.remove(session.getId());
		
		JSONObject json = new JSONObject();
		json.put("removeUser", nickname);
		
		if(nickname.isEmpty() == false) {			
			for(WebSocketSession sock : connSet) {
				sock.sendMessage(new TextMessage(json.toString()));
			}
		}
	}
	
	@Override
	public void processMessage(WebSocketSession session, String message) throws Exception {
		log.debug("Message : " + message);
		
		JSONObject json = new JSONObject();
		
		//새 유저 연결시 별명 추가
		if(!nicknamesMap.containsKey(session.getId())) {			
			//현재 접속중인 유저들 별명 가져오기
			
			for(String nickname : nicknamesMap.values()) {
				json.put("addUser", nickname);
				session.sendMessage(new TextMessage(json.toString()));
			}
			
			nicknamesMap.put(session.getId(),message); // 새 유저 별명 목록에 추가
			
			//현재 접속중인 유저들에게 새 유저 별명 보내기
			for(WebSocketSession sock : connSet) {
				json.put("addUser", message);
				sock.sendMessage(new TextMessage(json.toString()));
			}			
		} else { //별명과 메세지 보내기
			
			json.put("nickname", nicknamesMap.get(session.getId()));
			json.put("message", message);
			
			for(WebSocketSession sock : connSet) {
				sock.sendMessage(new TextMessage(json.toString()));
			}
		}
	}	
}
