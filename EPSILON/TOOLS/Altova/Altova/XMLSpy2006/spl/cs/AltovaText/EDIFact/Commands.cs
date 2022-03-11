[call GenerateFileHeader("Commands.cs")]
using System.Collections;

namespace Altova.TextParser.EDIFACT
{
	/// <summary>
	/// Defines a command.  Commands are used like semantical actions
	/// while parsing.
	/// </summary>
	public interface ICommand
	{
		/// <summary>
		/// Tries to execute the command.
		/// </summary>
		/// <param name="parser">the parser instance upon which to execute</param>
		/// <returns>true if execution succeeded, otherwise false</returns>
		bool Execute(TextDocument parser);
	}

	/// <summary>
	/// Serves as a base class for all commands.
	/// </summary>
	public abstract class Command : ICommand
	{
		#region Implementation Detail:
		ConditionChain mConditions = new ConditionChain();
		CommandBlock mOtherwise = new CommandBlock();
		#endregion
		#region Public Interface:
		/// <summary>
		/// Adds a new condition to the command. Conditions are ORed.
		/// </summary>
		/// <param name="condition">the condition to add</param>
		public void AddCondition(ICondition condition)
		{
			mConditions.AddCondition(condition);
		}
		/// <summary>
		/// Adds a new command to the otherwise.
		/// </summary>
		/// <param name="command">the command to add</param>
		public void AddOtherwise(ICommand command)
		{
			mOtherwise.AddCommand(command);
		}
		/// <summary>
		/// Gets the conditions needed to be met to execute this command.
		/// </summary>
		public ConditionChain Conditions
		{
			get
			{
				return mConditions;
			}
		}
		/// <summary>
		/// Gets the conditions needed for the otherwise branch.
		/// </summary>
		public CommandBlock Otherwise
		{
			get
			{
				return mOtherwise;
			}
		}
		#endregion
		#region Implementing ICommand:
		/// <summary>
		/// Tries to execute the command. First evaluates whether the contained conditions are met, then
		/// executes the concrete command.
		/// </summary>
		/// <param name="parser">the parser upon which to execute</param>
		/// <returns>true if the conditions were met and execution was successful, otherwise false</returns>
		public bool Execute(TextDocument parser)
		{
			if (mConditions.Evaluate(parser))
				return this.DoExecute(parser);
			else
				mOtherwise.Execute(parser);
			return false;
		}
		#endregion
		#region Descendant Obligations:
		/// <summary>
		/// GOF-template method. Tries to execute the concrete command which is delegated to the
		/// concrete descendant.
		/// </summary>
		/// <param name="parser">the parser upon which to execute</param>
		/// <returns>true if execution succeeded, otherwise false</returns>
		protected abstract bool DoExecute(TextDocument parser);
		#endregion
	}

	/// <summary>
	/// Encapsulates a command for entering a hierarchy tree node.
	/// </summary>
	public class CommandEnter : Command
	{
		#region Implementation Detail:
		string mName;
		NodeClass mClass;
		#endregion
		#region Public Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="name">the name of the node to enter upon execution</param>
		/// <param name="eClass">the name of the node's class</param>
		public CommandEnter(string name, NodeClass eClass)
		{
			mName = name;
			mClass = eClass;
		}
		#endregion
		#region Implementing Command:
		/// <summary>
		/// See <see cref="Command.DoExecute"/>().
		/// </summary>
		/// <param name="parser">See <see cref="Command.DoExecute"/>().</param>
		/// <returns>See <see cref="Command.DoExecute"/>().</returns>
		protected override bool DoExecute(TextDocument parser)
		{
			parser.Generator.EnterElement(mName, mClass);
			return true;
		}
		#endregion
	}

	/// <summary>
	/// Encapsulates a command for leaving a hierarchy tree node.
	/// </summary>
	public class CommandLeave : Command
	{
		#region Implementation Detail:
		string mName;
		#endregion
		#region Public Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="name">the name of the node to leave upon execution</param>
		public CommandLeave(string name)
		{
			mName = name;
		}
		#endregion
		#region Implementing Command:
		/// <summary>
		/// See <see cref="Command.DoExecute"/>().
		/// </summary>
		/// <param name="parser">See <see cref="Command.DoExecute"/>().</param>
		/// <returns>See <see cref="Command.DoExecute"/>().</returns>
		protected override bool DoExecute(TextDocument parser)
		{
			parser.Generator.LeaveElement(mName);
			return true;
		}
		#endregion
	}

	/// <summary>
	/// Encapsulates a command for calling a function.
	/// </summary>
	public class CommandCallFunction : Command
	{
		#region Implementation Detail:
		string mName;
		#endregion
		#region Public Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="name">the name of the function to call upon execution</param>
		public CommandCallFunction(string name)
		{
			mName = name;
		}
		#endregion
		#region Implementing Command:
		/// <summary>
		/// See <see cref="Command.DoExecute"/>().
		/// </summary>
		/// <param name="parser">See <see cref="Command.DoExecute"/>().</param>
		/// <returns>See <see cref="Command.DoExecute"/>().</returns>
		protected override bool DoExecute(TextDocument parser)
		{
			BaseFunction function = parser.Functions\[mName\];
			if (null != function) return function.Execute(parser);
			else return true;
		}
		#endregion
	}

	/// <summary>
	/// Encapsulates a command for storing a token value in a new node.
	/// </summary>
	public class CommandStoreValue : Command
	{
		#region Implementation Detail:
		string mName;
		#endregion
		#region Public Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="name">the name of the node where the value will be stored</param>
		public CommandStoreValue(string name)
		{
			mName = name;
		}
		#endregion
		#region Implementing Command:
		/// <summary>
		/// See <see cref="Command.DoExecute"/>().
		/// </summary>
		/// <param name="parser">See <see cref="Command.DoExecute"/>().</param>
		/// <returns>See <see cref="Command.DoExecute"/>().</returns>
		protected override bool DoExecute(TextDocument parser)
		{
			Scanner scanner = parser.Scanner;
			Scanner.Indicator indicator = scanner.Scan(); // shift to the next data element and store the value
			string sValue = scanner.Value; // gather the current content 
			parser.Generator.InsertElement(mName, sValue, NodeClass.DataElement);
			return (indicator!=Scanner.Indicator.End);
		}
		#endregion
	}

	/// <summary>
	/// Encapsulates a command for storing a character into a node.
	/// </summary>
	public class CommandStoreChar : Command
	{
		#region Implementation Detail:
		string mName;
		#endregion
		#region Public Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="name">the name of the node where the character will be stored</param>
		public CommandStoreChar(string name)
		{
			mName = name;
		}
		#endregion
		#region Implementing Command:
		/// <summary>
		/// See <see cref="Command.DoExecute"/>().
		/// </summary>
		/// <param name="parser">See <see cref="Command.DoExecute"/>().</param>
		/// <returns>See <see cref="Command.DoExecute"/>().</returns>
		protected override bool DoExecute(TextDocument parser)
		{
			Scanner scanner = parser.Scanner;
			scanner.ScanChar(); // shift to the next char and store the value
			string sValue = scanner.Value; // gather the current content 
			parser.Generator.InsertElement(mName, sValue, NodeClass.DataElement);
			return true; // keep on parsing
		}
		#endregion
	}

	/// <summary>
	/// Encapsulates a command for ignoring a token value.
	/// </summary>
	public class CommandIgnoreValue : Command
	{
		#region Implementing Command:
		/// <summary>
		/// See <see cref="Command.DoExecute"/>().
		/// </summary>
		/// <param name="parser">See <see cref="Command.DoExecute"/>().</param>
		/// <returns>See <see cref="Command.DoExecute"/>().</returns>
		protected override bool DoExecute(TextDocument parser)
		{
			parser.Scanner.Scan();
			return true;
		}
		#endregion
	}

	/// <summary>
	/// Encapsulates a command for ignoring a character
	/// </summary>
	public class CommandIgnoreChar : Command
	{
		#region Implementing Command:
		/// <summary>
		/// See <see cref="Command.DoExecute"/>().
		/// </summary>
		/// <param name="parser">See <see cref="Command.DoExecute"/>().</param>
		/// <returns>See <see cref="Command.DoExecute"/>().</returns>
		protected override bool DoExecute(TextDocument parser)
		{
			parser.Scanner.ScanChar();
			return true;
		}
		#endregion
	}

	/// <summary>
	/// Encapsulates a command for moving backwards one character in the scanner.
	/// </summary>
	public class CommandBackChar : Command
	{
		#region Implementing Command:
		/// <summary>
		/// See <see cref="Command.DoExecute"/>().
		/// </summary>
		/// <param name="parser">See <see cref="Command.DoExecute"/>().</param>
		/// <returns>See <see cref="Command.DoExecute"/>().</returns>
		protected override bool DoExecute(TextDocument parser)
		{
			parser.Scanner.BackChar();
			return true;
		}
		#endregion
	}

	/// <summary>
	/// Encapsulates a command for setting the escape character of the scanner from the current token value.
	/// </summary>
	public class CommandEscapeChar : Command
	{
		#region Implementing Command:
		/// <summary>
		/// See <see cref="Command.DoExecute"/>().
		/// </summary>
		/// <param name="parser">See <see cref="Command.DoExecute"/>().</param>
		/// <returns>See <see cref="Command.DoExecute"/>().</returns>
		protected override bool DoExecute(TextDocument parser)
		{
			Scanner scanner = parser.Scanner;
			scanner.ScanChar();
			parser.Scanner.EscapeChar = scanner.Value\[0\];
			return true; // keep on parsing
		}
		#endregion
	}

	/// <summary>
	/// Encapsulates a command for adding a new separator to the scanner fromt the current token value.
	/// </summary>
	public class CommandSeparatorChar : Command
	{
		#region Implementation Detail:
		string mName;
		#endregion
		#region Public Interface:
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		/// <param name="name">the name to which to map the new separator character</param>
		public CommandSeparatorChar(string name)
		{
			mName = name;
		}
		#endregion
		#region Implementing Command:
		/// <summary>
		/// See <see cref="Command.DoExecute"/>().
		/// </summary>
		/// <param name="parser">See <see cref="Command.DoExecute"/>().</param>
		/// <returns>See <see cref="Command.DoExecute"/>().</returns>
		protected override bool DoExecute(TextDocument parser)
		{
			Scanner scanner = parser.Scanner;
			scanner.ScanChar(); // shift to the next char
			parser.Scanner.AddSeparator(scanner.Value\[0\], mName);
			return true; // keep on parsing
		}
		#endregion
	}

	/// <summary>
	/// Encapsulates a while or a counted loop.
	/// </summary>
	public class CommandWhileLoop : Command
	{
		#region Implementation Detail:
		int mCount = -1;
		CommandBlock mCommands = new CommandBlock();
		#endregion
		#region Public Interface:
		/// <summary>
		/// Adds a new command to be executed inside the loop.
		/// </summary>
		/// <param name="command">the new command</param>
		public void AddCommand(Command command)
		{
			mCommands.AddCommand(command);
		}
		#endregion
		#region Implementing Command:
		/// <summary>
		/// See <see cref="Command.DoExecute"/>().
		/// </summary>
		/// <param name="parser">See <see cref="Command.DoExecute"/>().</param>
		/// <returns>See <see cref="Command.DoExecute"/>().</returns>
		protected override bool DoExecute(TextDocument parser)
		{
			if (-1 == mCount) this.DoWhileLoop(parser);
			else this.DoCountedLoop(parser);
			return true; // keep on parsing
		}
		void DoWhileLoop(TextDocument parser)
		{
			bool noteof = true;
			bool continuewhile = true;
			while (continuewhile && noteof)
			{
				continuewhile = mCommands.Execute(parser);
				noteof = !parser.Scanner.IsEndOfText;
			}
		}
		void DoCountedLoop(TextDocument parser)
		{
			for (int i = 0; i < mCount; ++i)
				mCommands.Execute(parser);
		}
		#endregion
	}

	/// <summary>
	/// Encapsulates a command block containing subcommands.
	/// </summary>
	public class CommandBlock : ICommand
	{
		#region Implementation Detail:
		ArrayList mCommands = new ArrayList();
		#endregion
		#region Public Interface:
		/// <summary>
		/// Adds a new subcommand to this instance.
		/// </summary>
		/// <param name="command">the new command</param>
		public void AddCommand(ICommand command)
		{
			mCommands.Add(command);
		}
		/// <summary>
		/// Gets the number of subcommands contained in this instance.
		/// </summary>
		public int Count
		{
			get
			{
				return mCommands.Count;
			}
		}
		#endregion
		#region Implementing ICommand:
		/// <summary>
		/// Executes all subcommands as long as there is still text available to work on.
		/// </summary>
		/// <param name="parser">the parser instance upon which to execute the commands</param>
		/// <returns>always true</returns>
		public bool Execute(TextDocument parser)
		{
			foreach (ICommand com in mCommands)
			{
				if (parser.Scanner.IsEndOfText) break;
				com.Execute(parser);
			}
			return true;
		}
		#endregion
	}
}