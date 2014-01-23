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
             //"random(1, 360) * pi / 180",
            // "toDegrees(toRadians(45))",
            // "toDegrees(1, test(22))",
            // "pi/3 + random() * (hi-lo)+lo",
            "if ((if (1 < 2) 3 else 4) == 2) 3",
            "if (false) 1 else if (true) 2 else 3",
            "if (1 < 2) random() else if (4 < 5) 1 else theta"
        };
        for (String input : Arrays.asList(samplePrograms)) {
            System.out.println(input);
            //printTokens(input);
            Parser parser = new Parser(new Tokenizer(input));
            System.out.println(parser.parse());
        }
    }

    public static void printTokens(String input)
    {
        for (Token t : new Tokenizer(input)) {
            System.out.println(t);
        }
    }
}
