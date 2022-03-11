<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="things">

	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" exclude-result-prefixes="xlink"
		encoding="utf-8"/>
	<xsl:strip-space elements="*"/>
	
	<xsl:template name="rule_430">

		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">430</xsl:variable>
		<xsl:variable name="rule_name">Check for empty mandatory and reference elements.</xsl:variable>
		<xsl:variable name="error_type">fail</xsl:variable>
		
		<!-- DISPLAY MESSAGE -->
		<xsl:call-template name="message">
			<xsl:with-param name="rule_number" select="$rule_number"/>
		</xsl:call-template>

		<!-- SET GENERIC RULE DETAILS TEXT -->
		<xsl:variable name="rule_details">
			<xsl:call-template name="rule_details">
				<xsl:with-param name="rule_number" select="$rule_number"/>
				<xsl:with-param name="rule_name" select="$rule_name"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- DETERMINE RESULTS TEXT -->
		<xsl:variable name="result">
			<xsl:for-each select=".//*[not(node())][not(self::notes[@notes-type='tfb-origin'])]">
				<xsl:choose>
					<xsl:when test="local-name()=('volume', 'issue', 'fpage', 'article-title', 'chapter-title', 'source', 'year', 'string-name', 'conf-name', 'uri', 'publisher-name', 'publisher-loc', 'edition', 'impression', 'publisher', 'publisher-loc', 'isbn', 'pub-date', 'permissions', 'copyright-statement', 'copyright-year', 'imprint-text', 'notes', 'bold', 'italic', 'sc', 'underline', 'sec')">
						<tr>
							<xsl:copy-of select="$rule_details"/>
							<td class="fail">
&lt;<xsl:value-of select="local-name(.)"/>
								<xsl:for-each select="@*">
									<xsl:choose>
										<xsl:when test="local-name()=('lang', 'indexed', 'pageref', 'printqv', 'type')"/>
										<xsl:otherwise>
											<xsl:text> </xsl:text>
											<xsl:value-of select="local-name()"/>="<xsl:value-of select="."/>"</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>&gt;no content&lt;/<xsl:value-of select="local-name(.)"/>&gt;
							</td>
						</tr>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>	
		</xsl:variable>

		<!-- DISPLAY RESULTS -->
		<xsl:call-template name="display_result">
			<xsl:with-param name="result" select="$result"/>
			<xsl:with-param name="rule_details" select="$rule_details"/>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>
