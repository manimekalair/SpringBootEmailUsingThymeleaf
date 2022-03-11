<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<!--isbn templates here-->
	<!-- isbn 13 validator -->
	<xsl:template name="isbn13Validator">
		<xsl:param name="myPassedISBN"/>
		<xsl:param name="type"/>
		<xsl:analyze-string select="$myPassedISBN" regex="(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)">
			<xsl:matching-substring>
				<!-- Length: <xsl:value-of select="string-length($myPassedISBN)"/>-->
				<xsl:variable name="base">
					<xsl:value-of select="(number(regex-group(1))*1)
     +
     (number(regex-group(2))*3)
     +
     (number(regex-group(3))*1)
     +
     (number(regex-group(4))*3)
     +
     (number(regex-group(5))*1)
     +
     (number(regex-group(6))*3)
     +
     (number(regex-group(7))*1)
     +
     (number(regex-group(8))*3)
     +
     (number(regex-group(9))*1)
     +
     (number(regex-group(10))*3)
     +
     (number(regex-group(11))*1)
     +
     (number(regex-group(12))*3)
     "/>
				</xsl:variable>
				<xsl:text>
				</xsl:text>
				<xsl:variable name="checkDigit" select="number(regex-group(13))"/>
				<xsl:variable name="remainder" select="10-(number($base mod 10))"/>
				<xsl:choose>
					<xsl:when test="$remainder eq $checkDigit">
						<xsl:text>valid</xsl:text>
					</xsl:when>
					<xsl:when test="$remainder = 10 and $checkDigit = 0">
						<xsl:text>valid</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>invalid</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:template>

	<!-- isbn 10 validator -->
	<xsl:template name="isbn10Validator">
		<xsl:param name="myPassedISBN"/>
		<xsl:param name="type"/>
		<xsl:analyze-string select="$myPassedISBN" regex="(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d|X|x)">
			<xsl:matching-substring>
				<!-- Length: <xsl:value-of select="string-length($myPassedISBN)"/>-->
				<xsl:variable name="base">
					<xsl:value-of select="(number(regex-group(1))*10)
      +
      (number(regex-group(2))*9)
      +
      (number(regex-group(3))*8)
      +
      (number(regex-group(4))*7)
      +
      (number(regex-group(5))*6)
      +
      (number(regex-group(6))*5)
      +
      (number(regex-group(7))*4)
      +
      (number(regex-group(8))*3)
      +
      (number(regex-group(9))*2)
      "/>
				</xsl:variable>
				<xsl:text>
				</xsl:text>
				<xsl:variable name="checkDigit">
					<xsl:choose>
						<xsl:when test="regex-group(10)='x'">10</xsl:when>
						<xsl:when test="regex-group(10)='X'">10</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="number(regex-group(10))"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="remainder" select="11 - number($base mod 11)"/>
				<xsl:choose>
					<xsl:when test="$remainder = $checkDigit">
						<tr>
							<td>
								<span class="rule">Rule 010</span>: Validate ISBNs – <xsl:value-of select="$myPassedISBN"/>
							</td>
							<td class="pass">pass</td>
						</tr>
					</xsl:when>
					<xsl:when test="$remainder = 11 and $checkDigit = 0">
						<tr>
							<td>
								<span class="rule">Rule 010</span>: Validate ISBNs – <xsl:value-of select="$myPassedISBN"/>
							</td>
							<td class="pass">pass</td>
						</tr>
					</xsl:when>
					<xsl:otherwise>
						<tr>
							<td>
								<span class="rule">Rule 010</span>: Validate ISBNs – <xsl:value-of select="$myPassedISBN"/>
        ( does (<xsl:value-of select="$base"/> / 11 = <xsl:value-of select="$remainder"/>)=<xsl:value-of select="$checkDigit"/>)</td>
							<td class="fail" id="010">
								<bold>Rule 010:</bold> Validate ISBNs – <em>
									<xsl:value-of select="$myPassedISBN"/>
								</em> is invalid</td>
						</tr>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:template>
</xsl:stylesheet>
