package hk.quantr.assembler;

import hk.quantr.assembler.antlr.AssemblerBaseListener;
import hk.quantr.assembler.antlr.AssemblerParser;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.tree.ErrorNode;

/**
 *
 * @author Peter (peter@quantr.hk)
 */
public class MyAssemblerListener extends AssemblerBaseListener {

	@Override
	public void enterEveryRule(ParserRuleContext ctx) {
		System.out.println("\t\t\tenterEveryRule = >" + ctx.getText() + "<");
	}
//
//	@Override
//	public void visitTerminal(TerminalNode node) {
//		System.out.println("visitTerminal = >" + node.getText() + "<");
//	}

	@Override
	public void visitErrorNode(ErrorNode node) {
		System.out.println("\t\t\tvisitErrorNode = >" + node.getText() + "<");
	}

//	@Override
//	public void enterStatement(AssemblerParser.StatementContext ctx) {
//		System.out.println("enterStatement = " + ctx.getText());
//	}
//
//	@Override
//	public void enterComment(AssemblerParser.CommentContext ctx) {
//		System.out.println("enterComments = " + ctx.getText());
//	}

//	@Override
//	public void enterData(AssemblerParser.DataContext ctx) {
//		System.out.println("enterData  a1 = " + ctx.a1);
//		System.out.println("enterData  a2 = " + ctx.a2);
//		System.out.println("enterData  a3 = " + ctx.a3);
//		System.out.println("enterData  a4 = " + ctx.a4);
//		System.out.println("enterData  a5 = " + ctx.a5);
//		System.out.println("enterData = " + ctx.getText());
//	}
}
