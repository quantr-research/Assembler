package hk.quantr.assembler;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import org.antlr.v4.Tool;
import org.antlr.v4.parse.ANTLRParser;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.LexerInterpreter;
import org.antlr.v4.runtime.ParserInterpreter;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.tree.ParseTreeWalker;
import org.antlr.v4.tool.Grammar;
import org.antlr.v4.tool.Rule;
import org.antlr.v4.tool.ast.GrammarRootAST;
import org.apache.commons.io.IOUtils;
import org.junit.Test;

/**
 *
 * @author Peter <peter@quantr.hk>
 */
public class TestDynamicParser {

	@Test
	public void test() throws FileNotFoundException, IOException {
		Tool tool = new Tool();
		GrammarRootAST ast = tool.parseGrammarFromString(IOUtils.toString(new FileReader(new File("/Users/peter/workspace/Assembler/src/main/java/hk/quantr/assembler/antlr/Assembler.g4"))));
		if (ast.grammarType == ANTLRParser.COMBINED) {
			Grammar grammar = tool.createGrammar(ast);
			tool.process(grammar, false);

			CharStream codeStream = CharStreams.fromFileName("/Users/peter/workspace/Assembler/src/test/resources/hk/quantr/assembler/4.asm");
			LexerInterpreter lexer = grammar.createLexerInterpreter(codeStream);
			lexer.removeErrorListeners();

			CommonTokenStream tokenStream = new CommonTokenStream(lexer);
			ParserInterpreter parser = grammar.createParserInterpreter(tokenStream);
//			parser.getInterpreter().setPredictionMode(PredictionMode.LL);

//			GeneralParserListener listener = new GeneralParserListener();
//			parser.addParseListener(listener);
			Rule start = grammar.getRule("assemble");
			if (start == null) {
				return;
			}
			ParserRuleContext context = parser.parse(start.index);
			System.out.println(context.toStringTree(parser));

			ParseTreeWalker walker = new ParseTreeWalker();
			GeneralParserListener listener = new GeneralParserListener(parser);
			walker.walk(listener, context);
		}
	}
}
