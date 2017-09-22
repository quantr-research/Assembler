package hk.quantr.assembler;

import java.util.BitSet;
import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.Parser;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.atn.ATNConfigSet;
import org.antlr.v4.runtime.dfa.DFA;

/**
 *
 * @author Peter <peter@quantr.hk>
 */
public class MyErrorListener extends BaseErrorListener {

	@Override
	public void syntaxError(final Recognizer<?, ?> recognizer, final Object offendingSymbol, final int line, final int position, final String msg, final RecognitionException e) {
		Token offendingToken = (Token) offendingSymbol;
		int start = offendingToken.getStartIndex();
		int stop = offendingToken.getStopIndex();
		System.err.println("ERROR " + line + ":" + position + ", " + start + ", " + stop + ": " + msg);
	}

	public void reportAmbiguity(Parser recognizer, DFA dfa, int startIndex, int stopIndex, boolean exact, BitSet ambigAlts, ATNConfigSet configs) {
		System.err.println("reportAmbiguity " + startIndex + ", " + stopIndex);
	}

	public void reportAttemptingFullContext(Parser recognizer, DFA dfa, int startIndex, int stopIndex, BitSet conflictingAlts, ATNConfigSet configs) {
		System.err.println("reportAttemptingFullContext" + startIndex + ", " + stopIndex);
	}

	public void reportContextSensitivity(Parser recognizer, DFA dfa, int startIndex, int stopIndex, int prediction, ATNConfigSet configs) {
		System.err.println("reportContextSensitivity" + startIndex + ", " + stopIndex);
	}
}
