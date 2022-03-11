[call GenerateFileHeader("AlwaysEmptyTextNodeCollection.cs")]
namespace Altova.TextParser
{
	/// <summary>
	/// An implementation of <see cref="ITextNodeCollection"/> staying always empty.
	/// Needed for <see cref="NullTextNode"/>.
	/// </summary>
	public class AlwaysEmptyTextNodeCollection : TextNodeCollection
	{
		/// <summary>
		/// Constructs an instance of this class.
		/// </summary>
		public AlwaysEmptyTextNodeCollection() : base(null)
		{}
		/// <summary>
		/// See <see cref="ITextNodeCollection.Add"/>().
		/// </summary>
		/// <param name="rhs"></param>
		/// <returns></returns>
		public override bool Add(ITextNode rhs)
		{
			return true;
		}
		/// <summary>
		/// See <see cref="ITextNodeCollection.Insert"/>().
		/// </summary>
		/// <param name="rhs"></param>
		/// <param name="index"></param>
		public override void Insert(ITextNode rhs, int index)
		{} // no-op
		/// <summary>
		/// See <see cref="ITextNodeCollection"/>.
		/// </summary>
		/// <param name="index"></param>
		/// <returns></returns>
		public override ITextNode this\[int index\]
		{
			get
			{
				return base\[index\];
			}
			set
			{} // no-op
		}
	}
}