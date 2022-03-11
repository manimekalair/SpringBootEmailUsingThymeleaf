<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" omit-xml-declaration="yes" indent="no" encoding="utf-8"/>
	<xsl:strip-space elements="*"/>

	<xsl:template name="rule_304">
		<!--&lt;title&gt; must not contain chapter or part label/number -->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">304</xsl:variable>
		<xsl:variable name="rule_name">Check for labels in &lt;title&gt;.</xsl:variable>
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
			<xsl:variable name="titleGrep">
				<xsl:for-each select=".//title-group/title">
					<xsl:variable name="testStr">
						<xsl:for-each select="./node()[not(self::target)]">
							<xsl:value-of select="lower-case(.)"/>
						</xsl:for-each>
					</xsl:variable>
					<xsl:variable name="test">
						<xsl:analyze-string select="$testStr" regex="^([0-9]|chapter|part[^a-z]|section|letter|entry)">
							<xsl:matching-substring>
								fail: <xsl:value-of select="(regex-group(1))"/>
							</xsl:matching-substring>
						</xsl:analyze-string>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="contains($test,'fail')">
							<tr>
								<td>
									<span class="rule">Rule 304</span>: Check for labels in &lt;title&gt;</td>
								<td class="warning">"<xsl:value-of select="$testStr"/>"</td>
							</tr>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="$titleGrep=''">
					<tr>
						<td>
							<span class="rule">Rule 304</span>: Check for labels in &lt;title&gt;</td>
						<td class="pass">pass</td>
					</tr>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="$titleGrep"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- DISPLAY RESULTS -->
		<xsl:call-template name="display_result">
			<xsl:with-param name="result" select="$result"/>
			<xsl:with-param name="rule_details" select="$rule_details"/>
		</xsl:call-template>
	</xsl:template>	
</xsl:stylesheet>