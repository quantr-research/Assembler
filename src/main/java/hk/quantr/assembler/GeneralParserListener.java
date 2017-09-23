package hk.quantr.assembler;

import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.tree.ErrorNode;
import org.antlr.v4.runtime.tree.ParseTreeListener;
import org.antlr.v4.runtime.tree.TerminalNode;

/**
 *
 * @author Peter <peter@quantr.hk>
 */
public class GeneralParserListener implements ParseTreeListener {

	@Override
	public void enterEveryRule(ParserRuleContext ctx) {
		System.out.println(ctx.getText());

//		for (int x = ctx.getStart().getTokenIndex(); x < ctx.getStop().getTokenIndex(); x++) {
//			System.out.println(ctx.get);
//		}
	}

	@Override
	public void visitTerminal(TerminalNode tn) {
		System.out.println("tn=" + tn.getText());
	}

	@Override
	public void visitErrorNode(ErrorNode en) {
		System.out.println("en=" + en.getText());
	}

	@Override
	public void exitEveryRule(ParserRuleContext prc) {
	}

}
