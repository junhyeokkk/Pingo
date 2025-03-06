package com.pingo.service.communityService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.springframework.stereotype.Service;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.net.URL;

@Slf4j
@RequiredArgsConstructor
@Service
public class PlaceCrawlingService {

    private static final String CHROME_DRIVER_PATH = "src/main/resources/chromDriver/chromedriver64.exe";

    public byte[] crawlingPlaceImage(String placeUrl) {
        System.setProperty("webdriver.chrome.driver", CHROME_DRIVER_PATH);

        // 크롬 옵션 설정 (헤드리스 모드 실행)
        ChromeOptions options = new ChromeOptions();
        options.addArguments("--headless");
        options.addArguments("--disable-gpu");
        options.addArguments("--no-sandbox");
        options.addArguments("--disable-dev-shm-usage");

        // WebDriver 실행
        WebDriver driver = new ChromeDriver(options);
        byte[] imageBytes = null;

        try {
            driver.get(placeUrl);
            Thread.sleep(3000); // 페이지 로딩 대기

            // 대표 이미지가 포함된 `img` 태그 찾기
            WebElement imageElement = driver.findElement(By.cssSelector("img.img-thumb.img_cfit"));

            // 이미지 URL(src 속성) 가져오기
            String imageUrl = imageElement.getAttribute("src");

            // 🔥 URL이 "//"로 시작하는 경우, "https:" 추가
            if (imageUrl.startsWith("//")) {
                imageUrl = "https:" + imageUrl;
            }

            if (imageUrl != null) {
                log.info("장소 대표 이미지 URL: " + imageUrl);

                // 이미지 URL에서 BufferedImage 로드
                BufferedImage bufferedImage = ImageIO.read(new URL(imageUrl));

                // BufferedImage를 ByteArray로 변환
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                ImageIO.write(bufferedImage, "jpg", baos);
                imageBytes = baos.toByteArray();
            }
        } catch (Exception e) {
            log.error("크롤링 중 오류 발생", e);
        } finally {
            driver.quit();
        }

        return imageBytes;
    }
}
