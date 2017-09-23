package hk.quantr.assembler;

import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTreeWalker;
import org.junit.Test;
import hk.quantr.assembler.antlr.*;
import org.antlr.v4.runtime.CharStreams;

public class TestAssembler {
	
	@Test
	public void test() throws Exception {
		AssemblerLexer lexer = new AssemblerLexer(CharStreams.fromStream(getClass().getResourceAsStream("4.asm")));
		
		CommonTokenStream tokenStream = new CommonTokenStream(lexer);
		AssemblerParser parser = new AssemblerParser(tokenStream);
//		parser.addErrorListener(new MyErrorListener());
//		parser.addParseListener(new GeneralParserListener());
		AssemblerParser.AssembleContext context = parser.assemble();
		
		ParseTreeWalker walker = new ParseTreeWalker();
		MyAssemblerListener listener = new MyAssemblerListener();
		walker.walk(listener, context);
		
	}
}
