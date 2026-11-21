package com.stark.vms_backend;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

@SpringBootTest
@TestPropertySource(properties = {
		"spring.datasource.url=jdbc:h2:mem:vms-test",
		"spring.datasource.username=sa",
		"spring.datasource.password=",
		"spring.datasource.driver-class-name=org.h2.Driver",
		"spring.jpa.hibernate.ddl-auto=create-drop",
		"app.jwt.secret=test-only-secret-key-at-least-32-chars-long",
		"app.admin.username=test-admin",
		"app.admin.password=test-password"
})
class VmsBackendApplicationTests {

	@Test
	void contextLoads() {
	}

}
