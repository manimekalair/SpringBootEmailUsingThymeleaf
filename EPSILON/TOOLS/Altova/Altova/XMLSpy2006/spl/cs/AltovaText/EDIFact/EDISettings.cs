[call GenerateFileHeader("EDISettings.cs")]
namespace Altova.TextParser.EDIFACT
{
	/// <summary>
	/// Encapsulates all settings relevant for exporting to EDI files in general.
	/// </summary>
	public class EDISettings
	{
		#region Implementation Detail:
		ServiceStringAdvice mServiceStringAdvice = new ServiceStringAdvice();
		bool mTerminateSegmentsWithLinefeed = false;
		bool mAutoCompleteData = true;
		#endregion
		#region Public Interface:
		/// <summary>
		/// Get/sets whether an extra linefeed should be used to terminate segments for better readability.
		/// </summary>
		public bool TerminateSegmentsWithLinefeed
		{
			get
			{
				return mTerminateSegmentsWithLinefeed;
			}
			set
			{
				mTerminateSegmentsWithLinefeed = value;
			}
		}
		/// <summary>
		/// Get/sets whether auto completion of data should be used.
		/// </summary>
		public bool AutoCompleteData
		{
			get
			{
				return mAutoCompleteData;
			}
			set
			{
				mAutoCompleteData = value;
			}
		}
		/// <summary>
		/// Get the service string advice to be used.
		/// </summary>
		public ServiceStringAdvice ServiceStringAdvice
		{
			get
			{
				return mServiceStringAdvice;
			}
		}
		#endregion
	}
}