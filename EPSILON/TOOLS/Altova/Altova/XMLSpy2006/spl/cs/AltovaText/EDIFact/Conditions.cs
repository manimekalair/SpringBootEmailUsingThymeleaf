[call GenerateFileHeader("Conditions.cs")]
using System.Collections;

namespace Altova.TextParser.EDIFACT
{
	/// <summary>
	/// Defines a condition to be evaluated for a <see cref="TextDocument"/>.
	/// </summary>
	public interface ICondition
	{
		/// <summary>
		/// Evaluates the condition represented by the concrete instance on a text parser.
		/// </summary>
		/// <param name="parser">the document to evaluate the condition for</param>
		/// <returns>true if the condition is met, otherwise false</returns>
		bool Evaluate(TextDocument parser);
	}

	/// <summary>
	/// Encapsulates a condition looking for a certain separator token.
	/// </summary>
	public class ConditionSeparator : ICondition
	{
		#region Implementation Detail:
		string mSeparator;
		bool mNegate = false;
		#endregion
		#region Public Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="separator">the separator token to look for</param>
		public ConditionSeparator(string separator)
		{
			mSeparator = separator;
		}
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="separator">the separator token to look for</param>
		/// <param name="negate">whether to negate the condition</param>
		public ConditionSeparator(string separator, bool negate) : this(separator)
		{
			mNegate = negate;
		}
		#endregion
		#region Implementing ICondition:
		/// <summary>
		/// See <see cref="ICondition.Evaluate"/>().
		/// </summary>
		/// <param name="parser">See <see cref="ICondition.Evaluate"/>().</param>
		/// <returns>See <see cref="ICondition.Evaluate"/>().</returns>
		public bool Evaluate(TextDocument parser)
		{
			bool result = (mSeparator == parser.Scanner.SeparatorToken);
			return mNegate ? !result : result;
		}
		#endregion
	}

	/// <summary>
	/// Encapsulates a condition looking for a certain token value.
	/// </summary>
	public class ConditionValue : ICondition
	{
		#region Implementation Detail:
		string mValue;
		bool mNegate = false;
		#endregion
		#region Public Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="val">the token value to look for</param>
		public ConditionValue(string val)
		{
			mValue = val;
		}
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="val">the token value to look for</param>
		/// <param name="negate">whether to negate the condition</param>
		public ConditionValue(string val, bool negate) : this(val)
		{
			mNegate = negate;
		}
		#endregion
		#region Implementing ICondition:
		/// <summary>
		/// See <see cref="ICondition.Evaluate"/>().
		/// </summary>
		/// <param name="parser">See <see cref="ICondition.Evaluate"/>().</param>
		/// <returns>See <see cref="ICondition.Evaluate"/>().</returns>
		public bool Evaluate(TextDocument parser)
		{
			bool result = (mValue == parser.Scanner.Value);
			return mNegate ? !result : result;
		}
		#endregion
	}

	/// <summary>
	/// Encapsulates a condition checking for a certain named node in the generated parse tree.
	/// </summary>
	public class ConditionFollowCharacter : ICondition
	{
		#region Implementation Detail:
		string mValue;
		bool mNegate = false;
		#endregion
		#region Public Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="value">the name of the node to check for</param>
		public ConditionFollowCharacter(string @value)
		{
			mValue = @value;
		}
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="value">the name of the node to check for</param>
		/// <param name="negate">whether to negate the condition</param>
		public ConditionFollowCharacter(string @value, bool negate) : this(@value)
		{
			mNegate = negate;
		}
		#endregion
		#region Implementing ICondition:
		/// <summary>
		/// See <see cref="ICondition.Evaluate"/>().
		/// </summary>
		/// <param name="parser">See <see cref="ICondition.Evaluate"/>().</param>
		/// <returns>See <see cref="ICondition.Evaluate"/>().</returns>
		public bool Evaluate(TextDocument parser)
		{
			Scanner scanner = parser.Scanner;
			Scanner.Indicator scanChar = scanner.ScanChar();
			string check = scanner.Separator;
			if (check == string.Empty) check = scanner.CurrentChar.ToString();
			Scanner.Indicator backChar = scanner.BackChar();
			bool result = (check == mValue);
			return mNegate ? !result : result;
		}
		#endregion
	}

	/// <summary>
	/// Encapsulates a condition checking for a certain named child in the generated parse tree.
	/// </summary>
	public class ConditionCurrentContext : ICondition
	{
		#region Implementation Detail:
		string mName;
		bool mNegate = false;
		#endregion
		#region Public Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="name">the name of the context</param>
		public ConditionCurrentContext(string name)
		{
			mName = name;
		}
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="name">the name of the context</param>
		/// <param name="negate">whether to negate the condition</param>
		public ConditionCurrentContext(string name, bool negate) : this(name)
		{
			mNegate = negate;
		}
		#endregion
		#region Implementing ICondition:
		/// <summary>
		/// See <see cref="ICondition.Evaluate"/>().
		/// </summary>
		/// <param name="parser">See <see cref="ICondition.Evaluate"/>().</param>
		/// <returns>See <see cref="ICondition.Evaluate"/>().</returns>
		public bool Evaluate(TextDocument parser)
		{
			bool result = parser.Generator.DoesNameEqual(mName);
			return mNegate ? !result : result;
		}
		#endregion
	}

	/// <summary>
	/// Encapsulates a condition checking for a certain named child in the generated parse tree.
	/// </summary>
	public class ConditionSiblingContext : ICondition
	{
		#region Implementation Detail:
		string mName;
		bool mNegate = false;
		#endregion
		#region Public Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="name">the name of the child node to check for</param>
		public ConditionSiblingContext(string name)
		{
			mName = name;
		}
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="name">the name of the child node to check for</param>
		/// <param name="negate">whether to negate the condition</param>
		public ConditionSiblingContext(string name, bool negate) : this(name)
		{
			mNegate = negate;
		}
		#endregion
		#region Implementing ICondition:
		/// <summary>
		/// See <see cref="ICondition.Evaluate"/>().
		/// </summary>
		/// <param name="parser">See <see cref="ICondition.Evaluate"/>().</param>
		/// <returns>See <see cref="ICondition.Evaluate"/>().</returns>
		public bool Evaluate(TextDocument parser)
		{
			bool result = parser.Generator.DoesNamedChildExist(mName);
			return mNegate ? !result : result;
		}
		#endregion
	}

	/// <summary>
	/// Encapsulates a set of subconditions being ORed or ANDed.
	/// </summary>
	public class ConditionChain : ICondition
	{
		#region Nested Types:
		/// <summary>
		/// Encapsulates how subconditions in a <see cref="ConditionChain"/> are tied together.
		/// </summary>
		public enum BooleanOperator
		{
			/// <summary>the subconditons are ORed</summary>
			Or,
			/// <summary>the subconditons are ANDed</summary>
			And
		} ;
		#endregion
		#region Implementation Detail:
		BooleanOperator mOperator = BooleanOperator.Or;
		ArrayList mConditions = new ArrayList();
		#endregion
		#region Public Interface:
		/// <summary>
		/// Get/sets the boolean operator linking all the contained subconditions.
		/// </summary>
		public BooleanOperator Operator
		{
			get
			{
				return mOperator;
			}
			set
			{
				mOperator = value;
			}
		}
		/// <summary>
		/// Adds a subcondition to this instance.
		/// </summary>
		/// <param name="condition">the subcondition</param>
		public void AddCondition(ICondition condition)
		{
			mConditions.Add(condition);
		}
		#endregion
		#region Implementing ICondition:
		/// <summary>
		/// See <see cref="ICondition.Evaluate"/>().
		/// </summary>
		/// <param name="parser">See <see cref="ICondition.Evaluate"/>().</param>
		/// <returns>See <see cref="ICondition.Evaluate"/>().</returns>
		public bool Evaluate(TextDocument parser)
		{
			if (0 == mConditions.Count) return true;

			foreach (ICondition con in mConditions)
			{
				bool subresult = con.Evaluate(parser);
				switch (mOperator)
				{
				case BooleanOperator.Or:
					if (subresult) return true;
					break;
				case BooleanOperator.And:
					if (!subresult) return false;
					break;

				}
			}
			return (BooleanOperator.And == mOperator);
		}
		#endregion
	}
}