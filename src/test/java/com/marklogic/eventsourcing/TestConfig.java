package com.marklogic.eventsourcing;

import com.marklogic.junit.spring.BasicTestConfig;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;

@Configuration
@PropertySource({"file:gradle.properties", "file:gradle-local.properties"})
public class TestConfig extends BasicTestConfig {
}
