<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="things">

	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" exclude-result-prefixes="xlink"
		encoding="utf-8"/>
	<xsl:strip-space elements="*"/>
	
	<xsl:template name="rule_406">

		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<!-- check contrib-type matches list-->
		<xsl:variable name="rule_number">406</xsl:variable>
		<xsl:variable name="rule_name">Check contrib-type attribute.</xsl:variable>
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
			<xsl:for-each select=".//contrib[
				@contrib-type[not(matches(.,'^(associate-editor|contributor|editor|illustrator|lead-contributor|translator|author|series-editor)$'))] or not(@contrib-type)]">
						<tr>
							<xsl:copy-of select="$rule_details"/>
							<td class="fail">
								@contrib-type="<xsl:value-of select="./@contrib-type"/>": contrib elements must contain a contrib-type attribute and be one of these values:
								"associate-editor", "contributor", "editor", "illustrator", "lead-contributor", "translator", "author", "series-editor")</td>
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
