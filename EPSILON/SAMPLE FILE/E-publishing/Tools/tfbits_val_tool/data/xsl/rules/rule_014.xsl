<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="utf-8"/>
	<xsl:strip-space elements="*"/>

	<xsl:template name="rule_014">
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">014</xsl:variable>
		<xsl:variable name="rule_name">Check &lt;publisher-name&gt; element.</xsl:variable>
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
			<xsl:if test="//book-meta/publisher">
				<xsl:variable name="publisher-names" select="document('../../lists/publisher-name_search_list.xml')"/>
				<xsl:for-each select="//book-meta/publisher">
					<xsl:variable name="item">
						<xsl:value-of select="publisher-name"/>
					</xsl:variable>
					<xsl:variable name="check" select="$publisher-names/xml/item[.= $item]"/>
					<xsl:if test="not($check/node())">
						<tr>
							<xsl:copy-of select="$rule_details"/>
							<td class="fail">
								<em>
									<xsl:value-of select="./publisher-name"/>
								</em> Doesn't match list</td>
						</tr>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
			<xsl:if test="not(//book-meta/publisher)">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail">no publisher</td>
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