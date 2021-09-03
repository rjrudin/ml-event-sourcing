This project provides an implementation of the Event Sourcing pattern as described at https://project.marklogic.com/jira/browse/MLPATTERNS-6, 
along with https://martinfowler.com/eaaDev/EventSourcing.html on the web.

To try it out, first deploy the application via Gradle (make sure ports 8833 and 8834 are open):

    gradle -i mlDeploy
    
You can then examine the unit tests under src/test/ml-modules and the integration tests under src/test/java. The
ml-unit-test UI is available at http://localhost:8834/test/default.xqy . The unit tests are helpful for understanding
how events are described and applied, while the integration tests are useful for seeing replay in action.
