package com.pingo.mapper;

import com.pingo.dto.community.DatingGuideDTO;
import com.pingo.dto.community.PlaceReviewDTO;
import com.pingo.entity.community.DatingGuide;
import com.pingo.entity.community.DatingGuideCate;
import com.pingo.entity.community.PlaceReview;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Optional;

@Mapper
public interface CommunityMapper {

    public List<PlaceReviewDTO> selectPlaceReviewWithSort(@Param("cateSort") String cateSort,
                                                            @Param("searchSort") String searchSort);
    public List<PlaceReviewDTO> selectPlaceReviewWithLocation(@Param("cateSort") String cateSort,
                                                                @Param("latitude") double latitude,
                                                                @Param("longitude") double longitude);
    public List<PlaceReviewDTO> selectPlaceReviewWithKeyword(@Param("keyword") String keyword);

    public void insertPlaceReview(PlaceReview placeReview);

    public PlaceReview selectPlaceReviewForChat(@Param("placeName") String placeName,
                                                @Param("placeAddress") String placeAddress);

    public Optional<String> selectPlaceHeart(@Param("userNo") String UserNo);

    public void placeDecreaseHeart(@Param("prNo") String prNo);

    public void placeIncreaseHeart(@Param("prNo") String prNo);

    public void deletePlaceReviewHeart(@Param("userNo") String userNo);

    public void updatePlaceReviewHeart(@Param("userNo") String userNo,
                                       @Param("prNoStr") String prNoStr);

    public void insertPlaceReviewHeart(@Param("userNo") String userNo,
                                       @Param("prNoStr") String prNoStr);

    public List<DatingGuideDTO> selectDatingGuideForInit();

    public List<DatingGuideDTO> selectDatingGuideWithSort(@Param("cate") String cate,
                                                            @Param("sort") String sort);

    public void insertDatingGuide(DatingGuide datingGuide);

    public List<DatingGuideCate> selectDatingGuideCate();

    public Optional<String> selectDatingGuideHeart(@Param("userNo") String UserNo);

    public void decreaseHeart(@Param("dgNo") String dgNo);

    public void increaseHeart(@Param("dgNo") String dgNo);

    public void deleteDatingGuideHeart(@Param("userNo") String userNo);

    public void updateDatingGuideHeart(@Param("userNo") String userNo,
                                       @Param("dgNoStr") String dgNoStr);

    public void insertDatingGuideHeart(@Param("userNo") String userNo,
                                       @Param("dgNoStr") String dgNoStr);
}
