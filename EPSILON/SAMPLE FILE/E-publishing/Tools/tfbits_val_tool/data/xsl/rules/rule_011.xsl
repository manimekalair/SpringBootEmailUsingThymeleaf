<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="utf-8"/>
	<xsl:strip-space elements="*"/>
	<!--Sion refactor
	
	isbn/@pub-type to isbn/@publication-format
	-->

	<xsl:template name="rule_011">
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">011</xsl:variable>
		<xsl:variable name="rule_name">Check &lt;isbn&gt; publication-format
			attribute.</xsl:variable>
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

		<!-- SET VARIABLES AND DO RULE TESTING AND PROCESSING -->
		<!-- insert setting of variables, testing, and any processing of data here -->
		<!-- DETERMINE RESULTS TEXT -->
		<xsl:variable name="result">
			<xsl:for-each
				select="/book/book-meta/isbn[@publication-format][not(matches(./@publication-format, '^(hbk|pbk|ebk|set|epub|web|mobi|oeb|fc)$'))]">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail"> "<xsl:value-of select="./@publication-format"/>" does't match
						pub-type attribute list</td>
				</tr>
			</xsl:for-each>
			<xsl:for-each select="/book/book-meta/isbn[not(@publication-format)]">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail"> "<xsl:value-of select="."/>" does't have publication-format
						attribute</td>
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
