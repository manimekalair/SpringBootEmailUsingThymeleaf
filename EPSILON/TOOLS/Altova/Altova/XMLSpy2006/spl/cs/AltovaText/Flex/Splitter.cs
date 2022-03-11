[call GenerateFileHeader("Splitter.cs")]
using Altova.TextParser;
using System;
using System.Text;

namespace Altova.TextParser.Flex
{
	/// <summary>
	/// A range inside a string
	/// </summary>
	public class Range
	{
		/// <summary>
		/// start offset of this range in content
		/// </summary>
		public int start;
		/// <summary>
		/// end offset of this range in content
		/// </summary>
		public int end;
		private string content;
		
		/// <summary>
		/// constructor to create a range for a substring
		/// </summary>
		public Range(String text, int contentStart, int contentEnd)
		{
			content = text;
			start = contentStart;
			end = contentEnd;
		}
		/// <summary>
		/// constructor to create a range for complete string
		/// </summary>
		public Range(String text)
		{
			content = text;
			start = 0;
			end = content.Length;
		}
		
		/// <summary>
		/// copy constructor
		/// </summary>
		public Range(Range r) : this(r.GetContent(), r.start, r.end) {}
		
		/// <summary>
		/// returns true if range is valid and not empty, false otherwise
		/// </summary>
		public bool IsValid()
		{
			return (start < end);
		}
		/// <summary>
		/// returns text "contained" in this range
		/// </summary>
		public override string ToString()
		{
			return content.Substring(start, end - start);
		}
		/// <summary>
		/// returnes content used in this range
		/// </summary>
		public string GetContent()
		{
			return content;
		}
		
		/// <summary>
		/// Length of range
		/// </summary>
		public int Length
		{
			get
			{
				return end - start;
			}
		}
		
		/// <summary>
		/// returns nth character of content
		/// </summary>
		public char At(int i)
		{
			return content\[i\];
		}

		/// <summary>
		/// returns true if range is not empty and starts with ch
		/// </summary>
		public bool StartsWith(char ch)
		{
			return (IsValid() && content\[start\] == ch);
		}

		/// <summary>
		/// returns true if range is not empty and ends with ch
		/// </summary>
		public bool EndsWith(char ch)
		{
			return (IsValid() && content\[end-1\] == ch);
		}

		/// <summary>
		/// returns true if range starts with str
		/// </summary>
		public bool StartsWith(string str)
		{
			return (Length >= str.Length && GetContent().Substring(start, str.Length) == str);
		}
		
		/// <summary>
		/// returns true if range contains str
		/// </summary>
		public bool Contains(string str)
		{
			return (Length >= str.Length && GetContent().IndexOf(str, start, end-start) != -1);
		}
		
		/// <summary>
		/// append range to a string
		/// </summary>
		public void AppendTo(StringBuilder str)
		{
			str.Append(content.Substring(start, end - start));
		}
	}
	
	/// <summary>
	/// Interface to append some text
	/// </summary>
	public interface Appender
	{
		/// <summary>
		/// Append text to output
		/// </summary>
		void AppendText(string addtext);
	}
	/// <summary>
	///  base class for splitter
	/// </summary>
	public abstract class Splitter
	{
		/// <summary>CR character constant</summary>
		protected const char CR = '\\r';
		/// <summary>LF character constant</summary>
		protected const char LF = '\\n';
		/// <summary>TAB character constant</summary>
		protected const char TAB = '\\t';

		/// <summary>
		/// split off some portion from range r and return it, r is modified to contain the rest
		/// </summary>
		public abstract Range Split(Range r);
		
		/// <summary>
		/// append delimiter to output
		/// </summary>
		public abstract void AppendDelimiter(Appender output);
	}
	
	/// <summary>
	/// Split at given position
	/// </summary>
	public class SplitAtPosition : Splitter
	{
		private int position;
			
		/// <summary>
		/// constructor
		/// </summary>
		public SplitAtPosition(int pos)
		{
			position = pos;
		}
		
		/// <summary>
		/// implementation of split for this splitter
		/// </summary>
		public override Range Split(Range range)
		{
			Range result;
			if (position < 0) // from right
			{
				int n = Math.Min(-position, range.Length);
				result = new Range(range.GetContent(), range.end - n, range.end);
			}
			else // from left
				result = new Range(range.GetContent(), range.start, range.start+Math.Min(position, range.Length));
			range.start = result.end;
			return result;
		}
		
		/// <summary>
		/// nop - no delimiter here
		/// </summary>
		public override void AppendDelimiter(Appender output)
		{}
	}
	
	/// <summary>
	/// Split number of lines from top or bottom
	/// </summary>
	public class SplitLines : Splitter
	{
		private int nLines;
		private bool removeDelimiter;
	
		/// <summary>
		/// constructor
		/// </summary>
		public SplitLines(int nLines, bool removeDelimiter)
		{
			this.nLines = nLines;
			this.removeDelimiter = removeDelimiter;
		}
		/// <summary>
		/// constructor
		/// </summary>
		public SplitLines(int nLines) : this(nLines, false) {}
		
		/// <summary>
		/// implementation of split for this instance
		/// </summary>
		public override Range Split(Range range)
		{
			string content = range.GetContent();
			Range result = new Range(content, range.start, range.start);
			int p = 0;
			
			if (nLines >= 0)
			{
				// count from top
				p = result.end;
				for (int nLinesLeft = nLines; nLinesLeft > 0 && p != range.end; ++p)
				{
					if (content\[p\] == CR || content\[p\] == LF)
					{
						if (content\[p\]  == CR && p != range.end-1 && content\[p+1\] == LF)
							++p;
						--nLinesLeft;
					}
				}
			}
			else
			{
				// count from bottom
				result.end = range.end;
				p = result.end;
				int nLinesLeft = -nLines;
				if (result.IsValid() && (content\[p-1\] == CR || content\[p-1\] == LF))
					nLinesLeft++;

				for (; p > range.start; --p)
				{
					if (content\[p-1\] == CR || content\[p-1\] == LF)
					{
						if (--nLinesLeft == 0)
							break;
						if (nLinesLeft > 0 && content\[p-1\] == LF && p > range.start+1 && content\[p-2\] == CR)
							--p;
					}
				}
			}
			result.end = p;
			range.start = result.end;
			if (removeDelimiter)
			{
				if (result.EndsWith(LF))
					--result.end;
				if (result.EndsWith(CR))
					--result.end;
			}
			return result;
		}
		
		/// <summary>
		/// append delimiter (if configured to remove at reading)
		/// </summary>
		public override void AppendDelimiter(Appender output)
		{
			if (removeDelimiter)
				output.AppendText("\\r\\n");
		}
	}
	/// <summary>
	/// Split text around delimiter string
	/// </summary>
	public class SplitAtDelimiter : Splitter
	{
		/// <summary>
		/// delimiter used in this splitter
		/// </summary>
		protected string delimiter;
		
		/// <summary>
		/// true if searching backwards
		/// </summary>
		protected bool reverse;
		
		/// <summary>
		/// constructor
		/// </summary>
		public SplitAtDelimiter(String delimiter, bool reverse)
		{
			this.delimiter = delimiter;
			this.reverse = reverse;
		}

		/// <summary>
		/// constructor
		/// </summary>                                   
		public SplitAtDelimiter(String delimiter) : this(delimiter, false)
		{
		}
		
		/// <summary>
		/// split implementation for this splitter
		/// </summary>
		public override Range Split(Range range)
		{
			Range result = new Range(range);
			
			if (delimiter.Length == 0)
			{
				range.start = range.end;
				return result;
			}
			
			result.end = range.start;
					
			int pos;
			if (reverse)
			{
				int start = range.end - delimiter.Length;
				int count = start - range.start;
				pos = (start >= 0 && count >= 0) ? range.GetContent().LastIndexOf(delimiter, start, count) : -1;
			}
			else
				pos = range.GetContent().IndexOf(delimiter, range.start, range.end - range.start);
			if (pos != -1)
			{
				result.end = pos;
				range.start = result.end + delimiter.Length;
			}
			else
			{
				result.end = range.end;
				range.start = result.end;
			}
			return result;
		}
		
		/// <summary>
		/// appends delimiter
		/// </summary>
		public override void AppendDelimiter(Appender output)
		{
			output.AppendText(delimiter);
		}
	}
	
	/// <summary>
	/// Split at start of line containing delimiter string
	/// </summary>
	public class SplitAtDelimiterLineBased : SplitAtDelimiter
	{
		/// <summary>
		/// constructor
		/// </summary>
		public SplitAtDelimiterLineBased(string delimiter, bool reverse) : base(delimiter, reverse)
		{
		}
		
		/// <summary>
		/// split implementation for this splitter
		/// </summary>
		public override Range Split(Range range)
		{
			if (delimiter.Length == 0)
			{
				Range result1 = new Range(range);
				range.start = range.end;
				return result1;
			}
			
			Range result = base.Split(range);
			
			String content = range.GetContent();
			while (result.IsValid() && content\[result.end-1\] != CR && content\[result.end-1\] != LF)
				--result.end;
			range.start = result.end;
			return result;
		}
		
		/// <summary>
		/// nop - delimiter is in content
		/// </summary>
		public override void AppendDelimiter(Appender output)
		{}
	}
	
	/// <summary>
	/// Split at start of line containing delimiter string (ignoring delimiter in the first line)
	/// </summary>
	public class SplitAtDelimiterLineBasedMultiple : SplitAtDelimiterLineBased
	{
		/// <summary>
		/// constructor
		/// </summary>
		public SplitAtDelimiterLineBasedMultiple(string delimiter) : base(delimiter, false)
		{
		}
		
		/// <summary>
		/// split implementation for this splitter
		/// </summary>
		public override Range Split(Range range)
		{
			SplitLines splitAtFirstLine = new SplitLines(1);
			Range firstLine = splitAtFirstLine.Split(range);
			Range result = base.Split(range);
			result.start = firstLine.start;
			return result;
		}
	}
}
