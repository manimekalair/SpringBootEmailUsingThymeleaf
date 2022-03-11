<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="utf-8"/>
	<xsl:strip-space elements="*"/>
	<!-- Sion as is-->
	<!--007 Check abstract-type attribute in <abstract> element. •<abstract> element must have abstract-type attribute
	•The abstract-type attribute must have one of the following values: 
	◦blurb
	◦abstract
-->
	<xsl:template name="rule_007">
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">007</xsl:variable>
		<xsl:variable name="rule_name">Check abstract-type attribute in &lt;abstract&gt;
			element.</xsl:variable>
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
			<xsl:for-each select="//abstract">
				<xsl:choose>
					<xsl:when test="not(./@abstract-type)">
						<tr>
							<xsl:copy-of select="$rule_details"/>
							<td class="fail">&lt;<xsl:value-of select="local-name()"/>
								<xsl:for-each select="./@*">
									<xsl:text> </xsl:text>
									<xsl:value-of select="local-name()"/>="<xsl:value-of select="."
									/>"</xsl:for-each>&gt;: abstract-type attribute missing</td>
						</tr>
					</xsl:when>
					<xsl:when
						test="not(./@abstract-type = ('blurb', 'abstract', 'scope-abstract'))">
						<tr>
							<xsl:copy-of select="$rule_details"/>
							<td class="fail">&lt;<xsl:value-of select="local-name()"/>
								<xsl:for-each select="./@*">
									<xsl:text> </xsl:text>
									<xsl:value-of select="local-name()"/>="<xsl:value-of select="."
									/>"</xsl:for-each>&gt;: The abstract-type attribute must have
								one of the following values: blurb; abstract. </td>
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
