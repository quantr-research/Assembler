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
	}

	@Override
	public void visitTerminal(TerminalNode tn) {
	}

	@Override
	public void visitErrorNode(ErrorNode en) {
	}

	@Override
	public void exitEveryRule(ParserRuleContext prc) {
	}

}
