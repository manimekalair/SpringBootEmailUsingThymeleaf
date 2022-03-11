<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="utf-8"/>
	<xsl:strip-space elements="*"/>
<!--
	Sion refactor
	/book-meta/imprint-meta/imprint-text[@type='BritishLibrary']
	to 
	//book-meta/notes[@notes-type='imprint-page']/"
	-->
	<xsl:template name="rule_108">
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">108</xsl:variable>
		<xsl:variable name="rule_name">Check British Library data.</xsl:variable>
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
			<xsl:for-each select="./book-meta/notes[@notes-type='imprint-page']/sec
				[matches(.,'british library cataloguing in publication data', 'i')]">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail">&lt;/sec sec-type="imprint-bl-data"&gt; contains text "British Library Cataloguing in Publication Data"</td>
				</tr>
			</xsl:for-each>
			<xsl:for-each select="./book-meta/notes[@notes-type='imprint-page']/sec
				[matches(.,'british library cataloguing-in-publication data', 'i')]">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail">&lt;/sec sec-type="imprint-bl-data"&gt; contains text "British Library Cataloguing-in-Publication Data"</td>
				</tr>
			</xsl:for-each>
			<xsl:if test="count(./book-meta/notes[@notes-type='imprint-page']/sec[@sec-type='imprint-bl-data']) &gt; 1">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail">More than one &lt;/sec sec-type="imprint-bl-data"&gt; element</td>
				</tr>
			</xsl:if>
		</xsl:variable>
		<!-- DISPLAY RESULTS -->
		<xsl:call-template name="display_result">
			<xsl:with-param name="result" select="$result"/>
			<xsl:with-param name="rule_details" select="$rule_details"/>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>