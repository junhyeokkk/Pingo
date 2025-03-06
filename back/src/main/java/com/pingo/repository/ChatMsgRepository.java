package com.pingo.repository;

import com.pingo.document.ChatMsgDocument;
import com.pingo.dto.chat.ChatMsgDTO;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface ChatMsgRepository extends MongoRepository<ChatMsgDocument, String> {

    // 모든 메세지 조회
    @Query(value = "{'roomId' :  ?0}", sort = "{'_id' : -1, 'msgTime' : 1}")
    List<ChatMsgDTO> findByRoomId(String roomId, Pageable pageable);


    // 100개 메세지 더 조회하기(로컬디비 사용시 필요없음)
    @Query(value = "{'roomId' : ?0, '_id' : { '$lt': ?1 }}", sort = "{'_id' : -1, 'msgTime' : 1}")
    List<ChatMsgDTO> findByMsgId(String roomId, String msgId, Pageable pageable);

}