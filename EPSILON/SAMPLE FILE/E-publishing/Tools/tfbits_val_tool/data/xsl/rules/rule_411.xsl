<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="things">

	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" exclude-result-prefixes="xlink"
		encoding="utf-8"/>
	<xsl:strip-space elements="*"/>
	
	<xsl:template name="rule_411">
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">411</xsl:variable>
		<xsl:variable name="rule_name">Check for series page.</xsl:variable>
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
			<!--<xsl:message>stuff:</xsl:message>-->
			<xsl:variable name="series_search_list"
				select="document('../../lists/series_search_list.xml')"/>
			
			<xsl:for-each select="//front-matter/front-matter-part/book-part-meta/title-group/title/text()">
				<xsl:variable name="item">
					<xsl:value-of select="normalize-space(.)"/>
				</xsl:variable>
				<xsl:variable name="check">
					<xsl:for-each select="$series_search_list//item/node()">
						<xsl:if test="current()=$item"> fail: <xsl:value-of select="."/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="contains($check,'fail:')">
						<tr>
							<xsl:copy-of select="$rule_details"/>
							<td class="fail">
								<xsl:value-of select="$check"/> – series title found
								in book-front</td>
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
