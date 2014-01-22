import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.LinkedList;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

import particledsl.Parser;
import particledsl.Tokenizer;
import particledsl.tokens.Token;

public class Main
{
    public static void main(String[] argv)
    {
        String[] samplePrograms = new String[] {
            "random() * 0x55 + 0x33",
            "random(1, 360) * pi / 180",
            "toDegrees(toRadians(45))",
            "toDegrees(1, test(22))",
            "pi/3 + random() * (hi-lo)+lo"
        };
        for (String input : Arrays.asList(samplePrograms)) {
            System.out.println(input);
            Parser parser = new Parser(new Tokenizer(input));
            System.out.println(parser.expression(0));
        }
    }
}
