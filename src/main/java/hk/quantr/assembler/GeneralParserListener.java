package hk.quantr.assembler;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import org.antlr.v4.runtime.Parser;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.tree.ErrorNode;
import org.antlr.v4.runtime.tree.ParseTreeListener;
import org.antlr.v4.runtime.tree.TerminalNode;

/**
 *
 * @author Peter <peter@quantr.hk>
 */
public class GeneralParserListener implements ParseTreeListener {

	private final Map<String, Integer> rmap = new HashMap<>();

	public GeneralParserListener(Parser parser) {
		rmap.putAll(parser.getRuleIndexMap());
	}

	@Override
	public void enterEveryRule(ParserRuleContext ctx) {
		String ruleName = getRuleByKey(ctx.getRuleIndex());
		System.out.println(ruleName + "\t: " + ctx.getText().replaceAll("\n", ""));

//		for (int x = ctx.getStart().getTokenIndex(); x < ctx.getStop().getTokenIndex(); x++) {
//			System.out.println(ctx.get);
//		}
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

	public String getRuleByKey(int key) {
		return rmap.entrySet().stream()
				.filter(e -> Objects.equals(e.getValue(), key))
				.map(Map.Entry::getKey)
				.findFirst()
				.orElse(null);
	}

}
