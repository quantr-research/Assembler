package hk.quantr.assembler;

import hk.quantr.assembler.antlr.AssemblerBaseListener;
import hk.quantr.assembler.antlr.AssemblerParser;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.tree.TerminalNode;

/**
 *
 * @author Peter (peter@quantr.hk)
 */
public class MyAssemblerListener extends AssemblerBaseListener {

//	@Override
//	public void enterEveryRule(ParserRuleContext ctx) {
//		System.out.println("enterEveryRule = >" + ctx.getText() + "<");
//	}
//
//	@Override
//	public void visitTerminal(TerminalNode node) {
//		System.out.println("visitTerminal = >" + node.getText() + "<");
//	}

	@Override
	public void enterStatement(AssemblerParser.StatementContext ctx) {
		System.out.println("enterStatement = " + ctx.getText());
	}

	@Override
	public void enterComment(AssemblerParser.CommentContext ctx) {
		System.out.println("enterComments = " + ctx.getText());
	}
}
