<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="things">

	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" exclude-result-prefixes="xlink"
		encoding="utf-8"/>
	<xsl:strip-space elements="*"/>
	
	<xsl:template name="rule_420">
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">420</xsl:variable>
		<xsl:variable name="rule_name">Check for empty elements.</xsl:variable>
		<xsl:variable name="error_type">warning</xsl:variable>
		
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

		<!-- insert setting of variables, testing, and any processing of data here -->
		<xsl:variable name="result">
			<xsl:for-each select="//*[not(node())]">
				<xsl:choose>
					<xsl:when test="local-name()=('series','break','etal','anonymous','colspec','graphic','inline-graphic','entry')"/>
					<xsl:when test="local-name()='p' and parent::entry"/>
					<xsl:when test="(local-name()='target') and ./@target-type='page' and ./@id"/>
					<!-- not sure about this ask Chris -->
					<xsl:when test="(local-name()='xref') and ./@ref-type='bio' and ./@rid"/>
					<!--these are exceptions due to being errors in Rule 430-->
					<xsl:when test="local-name()=('volume','issue','fpage','article-title','chapter-title','source','year','string-name','conf-name','uri','publisher-name','publisher-loc','edition','impression','publisher','publisher-loc','isbn','pub-date','permissions','copyright-statement','copyright-year','sec','notes','mml','bold','italic','sc','underline')"/>
					<!--these are exceptions due to being possible empty elements in MathML -->
					<xsl:when test="local-name()=('mspace','mtd')"/>
					<xsl:otherwise>
						<tr>
							<xsl:copy-of select="$rule_details"/>
							<td class="warning">
&lt;<xsl:value-of select="local-name(.)"/>
								<xsl:for-each select="@*">
									<xsl:choose>
										<xsl:when test="local-name()=('lang','indexed','pageref','printqv','type')"/>
										<xsl:otherwise>
											<xsl:text> </xsl:text>
											<xsl:value-of select="local-name()"/>="<xsl:value-of select="."/>"</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>&gt;no content&lt; in: /<xsl:value-of select="local-name(.)"/>&gt; 
								<xsl:for-each select="ancestor-or-self::*">
									<xsl:text>/</xsl:text>
									<xsl:value-of select="name()"/>
								</xsl:for-each>
								<xsl:text>/</xsl:text>
							</td>
						</tr>
					</xsl:otherwise>
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
