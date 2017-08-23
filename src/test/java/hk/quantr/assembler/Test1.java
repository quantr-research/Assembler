package hk.quantr.assembler;

import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTreeWalker;
import org.junit.Test;
import hk.quantr.assembler.antlr.*;

public class Test1 {

	@Test
	public void test() throws Exception {
		AssemblerLexer lexer = new AssemblerLexer(new ANTLRInputStream(getClass().getResourceAsStream("1.asm")));

//		Token token = lexer.nextToken();
//		while (token.getType() != Lexer.EOF) {
//			System.out.println(token + "=" + ANTLRv4Lexer.VOCABULARY.getSymbolicName(token.getType()));
//			token = lexer.nextToken();
//		}
		CommonTokenStream tokenStream = new CommonTokenStream(lexer);
		AssemblerParser parser = new AssemblerParser(tokenStream);
//		parser.addParseListener(listener);

		AssemblerParser.GrammarSpecContext context = parser.grammarSpec();

		ParseTreeWalker walker = new ParseTreeWalker();
		MyANTLRv4ParserListener listener = new MyANTLRv4ParserListener(parser);
		walker.walk(listener, context);

	}
}
