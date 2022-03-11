<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="utf-8"/>
	<xsl:strip-space elements="*"/>
<!--
	Sion refactor
	/book-meta/imprint-meta/imprint-text[@type='CIP']
	to 
	/book-meta/notes[@notes-type='imprint-page']/sec[@sec-type='imprint-cip-data']/"
	-->
	<xsl:template name="rule_457">
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">457</xsl:variable>
		<xsl:variable name="rule_name">Check that all book-parts have abstracts.</xsl:variable>
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

		<!-- SET VARIABLES AND DO RULE TESTING AND PROCESSING -->
		<!-- insert setting of variables, testing, and any processing of data here -->
		
		<xsl:variable name="abstracts" select="boolean(/book/book-body//book-part[@book-part-type = 'chapter']/book-part-meta/abstract[@abstract-type = 'abstract'])"/>
		
		<!-- DETERMINE RESULTS TEXT -->
		<xsl:variable name="result">
			<xsl:for-each select="/book/book-body//book-part[@book-part-type = 'chapter']/book-part-meta[not(./abstract[@abstract-type = 'abstract'])][$abstracts = true()]">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail">
						<xsl:text>Found a &lt;book-part&gt; that has no abstract, but at least one other &lt;book-part&gt; does have an abstract. Possible missing book-part abstract: </xsl:text>
						<xsl:choose>
							<xsl:when test="./ancestor::*[@id][1]">
								<xsl:text>in element &lt;</xsl:text>
								<xsl:value-of select="name(./ancestor::*[@id][1])"/>
								<xsl:text> id="</xsl:text>
								<xsl:value-of select="./ancestor::*[@id][1]/@id"/>
								<xsl:text>"&gt;</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>at XPath </xsl:text>
								<xsl:for-each select="ancestor::*">
									<xsl:text>/</xsl:text>
									<xsl:value-of select="name()"/>
								</xsl:for-each>
								<xsl:text>/</xsl:text>
								<xsl:value-of select="name()"/>
							</xsl:otherwise>
						</xsl:choose>
					</td>
				</tr>
			</xsl:for-each>
		</xsl:variable>
		<!-- DISPLAY RESULTS -->
		<xsl:call-template name="display_result">
			<xsl:with-param name="result" select="$result"/>
			<xsl:with-param name="rule_details" select="$rule_details"/>
		</xsl:call-template>
	</xsl:template>
</xsl:stylesheet>
