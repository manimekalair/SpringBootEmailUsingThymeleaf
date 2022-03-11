<?xml version="1.0" encoding="UTF-8"?>
<!--Book frontmatter

203 	List of abbreviations / acronyms tagging check. 	Any elements tagged <sec sec-type="abbreviations"> must contain at least one<def-list> element. 	Warning
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" omit-xml-declaration="yes" indent="no" encoding="utf-8"/>
	<xsl:strip-space elements="*"/>

	<xsl:template name="rule_203">
		<xsl:variable name="rule_number">203</xsl:variable>
		<xsl:variable name="rule_name">List of abbreviations / acronyms tagging check.</xsl:variable>
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

		<!-- DETERMINE RESULTS TEXT -->
		<xsl:variable name="result">
			<xsl:if test=".//glossary[@content-type='abbreviations'][not(def-list)]">
					<tr>
						<xsl:copy-of select="$rule_details"/>
						<td class="warning">glossary missing &lt;def-list&gt; element</td>
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