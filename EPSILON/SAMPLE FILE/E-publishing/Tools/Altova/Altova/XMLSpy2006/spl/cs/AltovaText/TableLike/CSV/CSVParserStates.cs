[call GenerateFileHeader("CSVParserStates.cs")]
namespace Altova.TextParser.TableLike.CSV
{
	internal abstract class ParserState
	{
		#region Implementation Detail:
		CSVParser mOwner = null;
		ParserStates mStates = null;
		#endregion
		#region Descendant Interface:
		protected CSVParser Owner
		{
			get
			{
				return mOwner;
			}
		}
		protected ParserStates States
		{
			get
			{
				return mStates;
			}
		}
		protected ParserState(CSVParser owner, ParserStates states)
		{
			mOwner = owner;
			mStates = states;
		}
		#endregion
		#region Descendant Obligations:
		public abstract ParserState Process(char current);
		public abstract ParserState ProcessFieldDelimiter(char current);
		public abstract ParserState ProcessRecordDelimiter(char current);
		public abstract ParserState ProcessQuoteCharacter(char current);
		#endregion
	}

	internal class ParserStateWaitingForField : ParserState
	{
		#region Overriding ParserState:
		public override ParserState Process(char current)
		{
			return States.InsideField;
		}
		public override ParserState ProcessFieldDelimiter(char current)
		{
			if (!Owner.WasLastCharacterQuote) Owner.NotifyAboutTokenComplete();
			Owner.MoveNext();
			return this;
		}
		public override ParserState ProcessQuoteCharacter(char current)
		{
			Owner.MoveNext();
			return States.InsideQuotedField;
		}
		public override ParserState ProcessRecordDelimiter(char current)
		{
			if (Owner.WasLastCharacterFieldDelimiter) Owner.NotifyAboutTokenComplete();
			Owner.NotifyAboutEndOfRecord();
			Owner.MoveNext();
			return this;
		}
		#endregion
		#region Public Interface:
		public ParserStateWaitingForField(CSVParser owner, ParserStates states) : base(owner, states)
		{}
		#endregion
	}

	internal class ParserStateInsideField : ParserState
	{
		#region Overriding ParserState:
		public override ParserState Process(char current)
		{
			Owner.Token += current;
			Owner.MoveNext();
			return this;
		}
		public override ParserState ProcessFieldDelimiter(char current)
		{
			Owner.NotifyAboutTokenComplete();
			Owner.MoveNext();
			return States.WaitingForField;
		}
		public override ParserState ProcessQuoteCharacter(char current)
		{
			return this.Process(current);
		}
		public override ParserState ProcessRecordDelimiter(char current)
		{
			Owner.NotifyAboutTokenComplete();
			Owner.NotifyAboutEndOfRecord();
			Owner.MoveNext();
			return States.WaitingForField;
		}
		#endregion
		#region Public Interface:
		public ParserStateInsideField(CSVParser owner, ParserStates states) : base(owner, states)
		{}
		#endregion
	}

	internal class ParserStateInsideQuotedField : ParserState
	{
		#region Overriding ParserState:
		public override ParserState Process(char current)
		{
			Owner.Token += current;
			Owner.MoveNext();
			return this;
		}
		public override ParserState ProcessFieldDelimiter(char current)
		{
			Owner.Token += current;
			Owner.MoveNext();
			return this;
		}
		public override ParserState ProcessQuoteCharacter(char current)
		{
			ParserState result = this;

			Owner.MoveNext();
			if (Owner.IsEndOfBuffer)
			{
				Owner.NotifyAboutTokenComplete();
				result = States.WaitingForField;
			}
			else if (Owner.CurrentCharacter == current)
			{
				Owner.Token += current;
				Owner.MoveNext();
			}
			else
				result = States.InsideField;

			return result;
		}
		public override ParserState ProcessRecordDelimiter(char current)
		{
			Owner.Token += current;
			Owner.MoveNext();
			return this;
		}
		#endregion
		#region Public Interface:
		public ParserStateInsideQuotedField(CSVParser owner, ParserStates states) : base(owner, states)
		{}
		#endregion
	}

	internal class ParserStates
	{
		#region Implementation Detail:
		ParserStateWaitingForField mWaitingForFieldState = null;
		ParserStateInsideField mInsideFieldState = null;
		ParserStateInsideQuotedField mInsideQuotedFieldState = null;
		#endregion
		#region Public Interface:
		public ParserStates(CSVParser owner)
		{
			mWaitingForFieldState = new ParserStateWaitingForField(owner, this);
			mInsideFieldState = new ParserStateInsideField(owner, this);
			mInsideQuotedFieldState = new ParserStateInsideQuotedField(owner, this);
		}
		public ParserStateWaitingForField WaitingForField
		{
			get
			{
				return mWaitingForFieldState;
			}
		}
		public ParserStateInsideField InsideField
		{
			get
			{
				return mInsideFieldState;
			}
		}
		public ParserStateInsideQuotedField InsideQuotedField
		{
			get
			{
				return mInsideQuotedFieldState;
			}
		}
		#endregion
	}
}