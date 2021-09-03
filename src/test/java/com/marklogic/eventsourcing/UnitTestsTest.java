package com.marklogic.eventsourcing;

import com.marklogic.client.DatabaseClient;
import com.marklogic.client.ext.helper.DatabaseClientProvider;
import com.marklogic.test.unit.TestManager;
import com.marklogic.test.unit.TestModule;
import com.marklogic.test.unit.TestResult;
import com.marklogic.test.unit.TestSuiteResult;
import org.junit.AfterClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

import java.util.List;

/**
 * Parameterized test that reuses TestConfig to construct a DatabaseClient, and then runs each of the ml-unit-test
 * modules as a separate JUnit test.
 */
@RunWith(Parameterized.class)
public class UnitTestsTest extends AbstractTest {

	private TestModule testModule;

	private static TestManager testManager;
	private static DatabaseClient databaseClient;

	public UnitTestsTest(TestModule testModule) {
		this.testModule = testModule;
	}

	@AfterClass
	public static void releaseDatabaseClient() {
		if (databaseClient != null) {
			databaseClient.release();
		}
	}

	/**
	 * This sets up the parameters for our test by getting a list of the test modules.
	 *
	 * @return
	 */
	@Parameterized.Parameters(name = "{index}: {0}")
	public static List<TestModule> getTestModules() {
		AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(TestConfig.class);
		databaseClient = context.getBean(DatabaseClientProvider.class).getDatabaseClient();
		testManager = new TestManager(databaseClient);
		return testManager.list();
	}

	@Test
	public void test() {
		TestSuiteResult result = testManager.run(this.testModule);
		for (TestResult testResult : result.getTestResults()) {
			String failureXml = testResult.getFailureXml();
			if (failureXml != null) {
				fail(String.format("Test %s in suite %s failed, cause: %s", testResult.getName(), testModule.getSuite(), failureXml));
			}
		}
	}
}
