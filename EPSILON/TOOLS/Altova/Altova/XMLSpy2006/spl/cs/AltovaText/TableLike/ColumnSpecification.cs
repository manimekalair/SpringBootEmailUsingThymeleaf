[call GenerateFileHeader("ColumnSpecification.cs")]
namespace Altova.TextParser.TableLike
{
	/// <summary>
	/// Encapsulates data needed to describe/specify a column in a table.
	/// The information contained is used by implementations of <see cref="ISerializer"/>.
	/// Note that not all the properties will be used by all serializers.
	/// </summary>
	public class ColumnSpecification
	{
		#region Implementation Detail:
		string mName = "";
		int mLength = 0;
		#endregion
		#region Public Interface:
		/// <summary>
		/// Constructs an instance of this class and initializes <see cref="Name"/>to an empty string and 
		/// <see cref="Length"/> to zero.
		/// </summary>
		public ColumnSpecification()
		{}
		/// <summary>
		/// Constructs an instance of this class initializing <see cref="Length"/> to zero and 
		/// <see cref="Name"/> to the value provided.
		/// </summary>
		/// <param name="name">the name of the column</param>
		public ColumnSpecification(string name)
		{
			mName = name;
		}
		/// <summary>
		/// Constructs an instance of this class initializing <see cref="Length"/> and <see cref="Name"/>
		/// to values provided.
		/// </summary>
		/// <param name="name">the name of the column</param>
		/// <param name="length">the length of the column</param>
		public ColumnSpecification(string name, int length)
		{
			mName = name;
			mLength = length;
		}
		/// <summary>
		/// Get/sets the name of this column.
		/// </summary>
		public string Name
		{
			get
			{
				return mName;
			}
			set
			{
				mName = value;
			}
		}
		/// <summary>
		/// Get/sets the length of this column.
		/// </summary>
		public int Length
		{
			get
			{
				return mLength;
			}
			set
			{
				mLength = value;
			}
		}
		#endregion
	}
}