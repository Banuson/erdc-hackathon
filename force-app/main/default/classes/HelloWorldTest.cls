@isTest
private class HelloWorldTest {
    @isTest static void testHelloWorld() {
        System.assertequals('HelloWorld!',HelloWorld.getHelloWorld(),'Bye bye world!');
    }
}
    