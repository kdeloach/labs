import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.LinkedList;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

import particledsl.*;

public class Main
{
    public static void main(String[] argv)
    {
        String[] samplePrograms = new String[] {
            "random() * 0x55 + 0x33",
            "random(1, 360) * pi / 180"
            //"toDegrees(random(1, 360) * pi / 180)"
        };
        for (String input : Arrays.asList(samplePrograms)) {
            System.out.println(input);
            Parser parser = new Parser(new Tokenizer(input));
            System.out.println(parser.expression(0));
        }
    }
}
