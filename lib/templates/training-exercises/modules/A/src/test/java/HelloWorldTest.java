#set( $symbol_pound = '#' )
#set( $symbol_dollar = '$' )
#set( $symbol_escape = '\' )
package ${package};

import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import static org.junit.Assert.*;

/**
 * GPE Training :Unit test
 */
public class HelloWorldTest {

    @BeforeClass public static void setUpOnce() {
        System.out.println("@BeforeClass: set up once");
    }

    @Before public void setUp() {
        System.out.println("@Before: set up ");
    }

    @Test public void testCopy() {
        assertTrue(1 == 1);
    }

}