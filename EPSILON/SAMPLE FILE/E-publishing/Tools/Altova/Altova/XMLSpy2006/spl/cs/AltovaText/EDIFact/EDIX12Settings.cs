[call GenerateFileHeader("EDIX12Settings.cs")]
namespace Altova.TextParser.EDIFACT
{
	/// <summary>
	/// Encapsulates settings specific to EDIX12.
	/// </summary>
	public class EDIX12Settings : EDISettings
	{
		#region Implementation Detail:
		char mSubElementSeparator = '!';
		string mInterchangeControlVersionNumber = "05012";
		bool mRequestAcknowledgement = true;
		#endregion
		#region Implementation Detail:
		/// <summary>
		/// See X12 specifications for the definition of this.
		/// </summary>
		public char SubElementSeparator
		{
			get
			{
				return mSubElementSeparator;
			}
			set
			{
				mSubElementSeparator = value;
			}
		}
		/// <summary>
		/// See X12 specifications for the definition of this.
		/// </summary>
		public string InterchangeControlVersionNumber
		{
			get
			{
				return mInterchangeControlVersionNumber;
			}
			set
			{
				mInterchangeControlVersionNumber = value;
			}
		}
		/// <summary>
		/// See X12 specifications for the definition of this.
		/// </summary>
		public bool RequestAcknowledgement
		{
			get
			{
				return mRequestAcknowledgement;
			}
			set
			{
				mRequestAcknowledgement = value;
			}
		}
		#endregion
	}
}