package hk.quantr.assembler;

import hk.quantr.assembler.antlr.TestBaseListener;
import hk.quantr.assembler.antlr.TestParser;
import org.antlr.v4.runtime.tree.ErrorNode;

/**
 *
 * @author Peter (peter@quantr.hk)
 */
public class MyTestListener extends TestBaseListener {

//	@Override
//	public void enterEveryRule(ParserRuleContext ctx) {
//		System.out.println("\t\t\tenterEveryRule = >" + ctx.getText() + "<");
//	}
//
//	@Override
//	public void visitTerminal(TerminalNode node) {
//		System.out.println("visitTerminal = >" + node.getText() + "<");
//	}
	@Override
	public void visitErrorNode(ErrorNode node) {
		System.out.println("\t\t\tvisitErrorNode = >" + node.getText() + "<");
	}

	@Override
	public void enterAssemble(TestParser.AssembleContext ctx) {
		System.out.println("enterStatement = " + ctx.getText());
	}

	@Override
	public void enterNumber(TestParser.NumberContext ctx) {
		System.out.println("enterNumber = " + ctx.getText());
	}
}
