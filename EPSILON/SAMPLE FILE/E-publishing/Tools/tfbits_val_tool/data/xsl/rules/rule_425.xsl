<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="things">

	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" exclude-result-prefixes="xlink"
		encoding="utf-8"/>
	<xsl:strip-space elements="*"/>
	
	<xsl:template name="rule_425">

		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">425</xsl:variable>
		<xsl:variable name="rule_name">Check for replication of style from print book.</xsl:variable>
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
			<xsl:for-each select=".//*[bold][not(ancestor::tbody)]|.//*[italic][not(ancestor::tbody)]|.//*[underline][not(ancestor::tbody)]|.//*[sc][not(ancestor::tbody)]">
				<xsl:variable name="style">
					<xsl:choose>
						<xsl:when test="./bold">bold</xsl:when>
						<xsl:when test="./italic">italic</xsl:when>
						<xsl:when test="./underline">underline</xsl:when>
						<xsl:when test="./sc">sc</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="count(child::node()) = 1">
						<tr>
							<xsl:copy-of select="$rule_details"/>
							<td class="warning">
								&lt;<xsl:value-of select="./name()"/>&gt;: "<xsl:value-of select="."/>" – is all <xsl:value-of select="$style"/>
							</td>
						</tr>
					</xsl:when>
					<xsl:when test="(count(child::node()) = 2) and (./target[@target-type = 'page' and matches(@id,'page_')])">
						<tr>
							<xsl:copy-of select="$rule_details"/>
							<td class="warning">
								&lt;<xsl:value-of select="./name()"/>&gt;: "<xsl:value-of select="."/>" – is all <xsl:value-of select="$style"/>
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
