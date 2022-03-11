[call GenerateFileHeader("EDIFactSettings.cs")]
namespace Altova.TextParser.EDIFACT
{
	/// <summary>
	/// Encapsulates EDIFact specific settings
	/// </summary>
	public class EDIFactSettings : EDISettings
	{
		#region Implementation Detail:
		long mSyntaxVersionNumber = 2;
		char mSyntaxLevel = 'A';
		string mControllingAgency = "UNO";
		bool mWriteUNA = true;
		#endregion
		#region Public Interface:
		/// <summary>
		/// Get/sets the syntax version number.
		/// </summary>
		public long SyntaxVersionNumber
		{
			get
			{
				return mSyntaxVersionNumber;
			}
			set
			{
				mSyntaxVersionNumber = value;
			}
		}
		/// <summary>
		/// Get/sets the syntax level.
		/// </summary>
		public char SyntaxLevel
		{
			get
			{
				return mSyntaxLevel;
			}
			set
			{
				mSyntaxLevel = value;
			}
		}
		/// <summary>
		/// Get/sets the controlling agency.
		/// </summary>
		public string ControllingAgency
		{
			get
			{
				return mControllingAgency;
			}
			set
			{
				mControllingAgency = value;
			}
		}
		/// <summary>
		/// Get/sets whether to write out the UNA segment when exporting or not.
		/// </summary>
		public bool WriteUNA
		{
			get
			{
				return mWriteUNA;
			}
			set
			{
				mWriteUNA = value;
			}
		}
		#endregion
	}
}