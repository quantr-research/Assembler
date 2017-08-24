package hk.quantr.assembler;

import hk.quantr.assembler.antlr.TestLexer;
import hk.quantr.assembler.antlr.TestParser;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTreeWalker;
import org.junit.Test;
import org.antlr.v4.runtime.CharStreams;

public class Test1 {

//	@Test
//	public void test() throws Exception {
//		TestLexer lexer = new TestLexer(CharStreams.fromStream(getClass().getResourceAsStream("4.asm")));
//
//		CommonTokenStream tokenStream = new CommonTokenStream(lexer);
//		TestParser parser = new TestParser(tokenStream);
//
//		TestParser.AssembleContext context = parser.assemble();
//
//		ParseTreeWalker walker = new ParseTreeWalker();
//		MyTestListener listener = new MyTestListener();
//		walker.walk(listener, context);
//
//	}
}
