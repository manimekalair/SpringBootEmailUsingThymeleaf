[call GenerateFileHeader("BaseFunction.cs")]
namespace Altova.TextParser.EDIFACT
{
	/// <summary>
	/// Serves as a base class for the generation function classes.
	/// </summary>
	public class BaseFunction
	{
		#region Implementation Detail:
		CommandBlock mCommands = new CommandBlock();
		#endregion
		#region Public Interface.
		/// <summary>
		/// Tries to execute all contained commands.
		/// </summary>
		/// <param name="parser">the parser instance upon which to execute</param>
		/// <returns>true if execution succeeded, otherwise false</returns>
		public bool Execute(TextDocument parser)
		{
			return mCommands.Execute(parser);
		}
		#endregion
		#region Descendant Interface:
		/// <summary>
		/// Adds a command to this instance.
		/// </summary>
		/// <param name="command">the command to add</param>
		protected void AddCommand(Command command)
		{
			mCommands.AddCommand(command);
		}
		#endregion
	}
}